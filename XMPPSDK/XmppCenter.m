//
//  XmppCenter.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "XmppCenter.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPMessageArchiving.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPCapabilities.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "UIView+Toast.h"
@interface XmppCenter ()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPRoomDelegate,XMPPRoomStorage,XMPPReconnectDelegate,XMPPvCardTempModuleDelegate,XMPPvCardTempModuleStorage,UIAlertViewDelegate>

{
    BOOL _isRegister;
    NSString * _password;
    BOOL _isOpen; //_xmppStream是否开着
}

@property BOOL isLogin;
@property (nonatomic,strong)XMPPJID *lastFetchedvCard;
@property (nonatomic,strong)XMPPStream * xmppStream;
@property (nonatomic,strong)XMPPRoster * roster;
@property (nonatomic,strong)XMPPRosterCoreDataStorage*rosterSave;
@property (nonatomic,strong)XMPPRoomCoreDataStorage *roomSave;
@property (nonatomic,strong)XMPPRoom *createRoom;
@property (nonatomic,strong)XMPPReconnect *xmppReconnect;
@property (nonatomic,strong)XMPPMessageArchivingCoreDataStorage*xmppMessageArchivingCoreDataStorage;
@property (nonatomic,strong)XMPPMessageArchiving*xmppMessageArchivingModule;
@property (nonatomic,strong)XMPPvCardCoreDataStorage*xmppvCardStorage;
@property (nonatomic,strong)XMPPvCardTempModule*xmppvCardTempModule;
@property (nonatomic,strong)XMPPvCardAvatarModule*xmppvCardAvatarModule;
@property (nonatomic,strong)XMPPCapabilitiesCoreDataStorage*xmppCapabilitiesStorage;
@property (nonatomic,strong)XMPPCapabilities*xmppCapabilities;

@end

@implementation XmppCenter

-(void)setupStream
{
    self.messageRecordDic = [[NSMutableDictionary alloc] init];//聊天信息的读取写在认证通过里面
    //    self.myCardInfo = [[NSMutableDictionary alloc] init];
    self.rosterInfoDic = [[NSMutableDictionary alloc]init];
    self.rosterArray =[[NSMutableArray alloc] initWithCapacity:10];
    self.messageSenders=[[NSMutableDictionary alloc] initWithCapacity:10];
    self.allUsersDataDic=[[NSMutableDictionary alloc] initWithCapacity:10];;
    //初始化XMPPStream
    // 初始化 xmppStream
    if (_xmppStream) {
        return;
    }
    _xmppStream = [[XMPPStream alloc]init];
#if !TARGET_IPHONE_SIMULATOR
    {
        // 想要xampp在后台也能运行?
        //
        // P.S. - 虚拟机不支持后台
        
        _xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    // 初始化 reconnect
    //
    // 这东西可以帮你把意外断开的状态连接回去...具体看它的头文件定义
    
    _xmppReconnect = [[XMPPReconnect alloc] init];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //初始化花名册
    _rosterSave = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterSave];
    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _roster.autoFetchRoster = YES;//是否自动获取花名册
    _roster.autoAcceptKnownPresenceSubscriptionRequests = NO;

    // 初始化 vCard support
    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
    [_xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 初始化 capabilities
    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];
    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // 初始化 message
    _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage];
    [_xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [_xmppMessageArchivingModule activate:_xmppStream];
    [_xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 激活xmpp的模块
    [_xmppReconnect         activate:_xmppStream];
    [_roster                activate:_xmppStream];
    [_xmppvCardTempModule   activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    [_xmppCapabilities      activate:_xmppStream];
    //下面这两个根据你自己配置需要来设置
    //    allowSelfSignedCertificates = NO;
    //    allowSSLHostNameMismatch = NO;
}
-(void)goOnline
{
    //发送在线状态 //简单上线
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
-(void)goOffLine
{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}
-(BOOL)registerName:(NSString *)name Password:(NSString *)password ServerID:(NSString *)serverId
{
    _isRegister = YES;
    [self connectName:name Password:password ServerID:serverId];
    
    return YES;
}
-(BOOL)connectName:(NSString *)name Password:(NSString *)password ServerID:(NSString *)serverId
{
    if (!self.xmppStream) {
        [self setupStream];
    }
    if (![_xmppStream isDisconnected]) {
        return YES;
    }
    if (name == nil || password == nil) {
        return NO;
    }
    [self.rosterInfoDic removeAllObjects];
    [self.allUsersDataDic removeAllObjects];
    [self.rosterArray removeAllObjects];
    
    //设置用户
    [_xmppStream setMyJID:[XMPPJID jidWithString:name]];
    //设置服务器
    [_xmppStream setHostName:serverId];
    [_xmppStream setHostPort:5333];

    //密码
    _password = password;
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:2.0 error:&error]) {
        NSLog(@"cant connect %@", serverId);
        return NO;
    }
    return YES;
}
-(void)disconnect
{
    [self goOffLine];
    [_xmppStream disconnect];
}
-(void)removeBuddy:(NSString *)buddyID
{
    XMPPJID *jid = [XMPPJID jidWithString:buddyID];
    [self.roster removeUser:jid];
    
}
-(void)addBuddy:(NSString *)buddyID
{
    XMPPJID *friendJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",buddyID,LOCALHOST]];
    [self.roster subscribePresenceToUser:friendJID];
//    if(![_rosterSave userExistsWithJID:friendJID xmppStream:_xmppStream])
//    {
//        
//    }
//    else
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"已经加过好友了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//    }
    
}
-(void)createForeverRoom:(NSString *)roomName NickName:(NSString *)nickName
{
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",roomName,LOCALHOST]];
    if (self.roomSave==nil) {
        self.roomSave = [[XMPPRoomCoreDataStorage alloc] init];
    }
    self.createRoom = [[XMPPRoom alloc] initWithRoomStorage:self.roomSave jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [self.createRoom  activate:self.xmppStream];
    if (nickName==nil||[nickName isEqualToString:@""]) {
        nickName = [[NSString alloc]initWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:NAME]];
    }
    // 在聊天是显示的昵称
//    [self.createRoom  fetchConfigurationForm];
    [self.createRoom  joinRoomUsingNickname:nickName history:nil];
    [self.createRoom  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    

}
-(void)getExistRoom
{
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:NAME]];
    [iqElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"conference.%@",[[NSUserDefaults standardUserDefaults]objectForKey:SERVERID]]];
    [iqElement addAttributeWithName:@"id" stringValue:@"getexistroomid"];
    [iqElement addChild:queryElement];
    [_xmppStream sendElement:iqElement];
}
- (void)getMyQueryRoster//Request FriendList
{
    NSLog(@"request friendlist...");
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = self.xmppStream.myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:nil];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
    
}
-(void)joinRoom:(NSString *)nickName
{
    [self.createRoom joinRoomUsingNickname:@"abc" history:nil];
}
-(void)sendMessage:(NSDictionary *)messageDic
{
    //本地输入框中的信息
    NSString *message = [messageDic objectForKey:@"content"];
    if (message.length > 0) {
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:[messageDic objectForKey:@"to"]];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:NAME]];
        //组合
        [mes addChild:body];
        //发送消息
        [[self xmppStream] sendElement:mes];
    }
}
#pragma mark xmppstreamDelegate
//连接服务器
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    if (_isRegister) {
        // 将用户密码发送给服务器，进行用户注册
        NSError *error = nil;
        [self.xmppStream registerWithPassword:_password error:&error];
        _isRegister = NO;
    }
    else
    {
        _isOpen = YES;
        NSError *error = nil;
        //验证密码
        [self.xmppStream authenticateWithPassword:_password error:&error];
    }
    
}
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    _isRegister = NO;
    NSString *str=[NSString stringWithFormat:@"服务器连接失败%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    NSLog(@"%s--=%@---\n error =%@",__func__,str,error);
    NSLog(@"error.userInfo =%@",error.userInfo);
    //登陆不到服务器
    //    error.userInfo ={
    //        NSLocalizedDescription = "nodename nor servname provided, or not known";
    //    }
    [self disconnect];
    if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
//        [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }
    else
    {
//        [SVProgressHUD showErrorWithStatus:@"好友服务器连接失败！"];
    }
    if ([self.loginDelegate respondsToSelector:@selector(LoginSuccess:)]) {
        [self.loginDelegate LoginSuccess:NO];
    }
    if ([self.chatDelegate respondsToSelector:@selector(didDisconnect)]) {
        [self.chatDelegate didDisconnect];
    }
   
    
    NSLog(@"%@",error.description);
}
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"验证通过%s--\nsender.hostName=%@ remoteJID.description=%@   sender.keepAliveInterval=%f",__func__,sender.hostName,sender.remoteJID.description,sender.keepAliveInterval);
    self.lastFetchedvCard=_xmppStream.myJID;
//    self.rosterInfoDic=[DataPlist openPlistFromDocumentWithName:xmppStream.myJID.user AndTheType:@"plist"];//我的（xmppStream.myJID.user的）好友信息
    [self goOnline];
    [_roster fetchRoster];//获取花名册
    [self.loginDelegate LoginSuccess:YES];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error//授权失败
{
    NSLog(@"%s",__func__);
    [[self keyWindow]makeToast:@"验证密码失败"];
}
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *type = [[message attributeForName:@"type"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    DDXMLElement *pros = [message elementForName:@"properties"];
    if (pros != nil) {
        DDXMLElement *pro = [pros elementForName:@"property"];

        if (pro != nil ) {
        NSString *imgData = [[pro elementForName:@"name"] stringValue] ;
        
        }
        
    }
    NSRange range=[from rangeOfString:@"@"];
    if(range.length==0)return;
    NSString *fromSimple=[from substringToIndex:range.location];
    NSLog(@"接受%@的消息： %@ (消息类型:%@)",fromSimple,msg,type);
    NSLog(@"接受消息%@",message);
    if ([message isChatMessageWithBody])//message
    {
        NSLog(@"%@",message);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:type forKey:@"attribute"];
        [dict setObject:msg forKey:@"content"];
        [dict setObject:from forKey:@"sender"];
        //消息委托
        [self.messageDelegate newMessageReceived:dict];
        if (![self.messageRecordDic objectForKey:fromSimple]&&dict) {
            NSMutableArray *array=[[NSMutableArray alloc]init];
            [array addObject:dict];
            [self.messageRecordDic setObject:array forKey:fromSimple];
            //按照名字存储信息
        }
        else
        {
            NSMutableArray *array1=[self.messageRecordDic objectForKey:fromSimple];
            [array1 addObject:dict];
        }
        //未读消息来源者
        if (![self.messageSenders objectForKey:fromSimple])
        {
            [self.messageSenders setObject:@"1" forKey:fromSimple];
        }
        else
        {
            int number=[[self.messageSenders objectForKey:fromSimple] intValue]+1;
            [self.messageSenders setObject:[NSString stringWithFormat:@"%d",number] forKey:fromSimple];
        }
        
    }
    else//语音、图片类
    {
        NSLog(@"其他信息");
    }
    
}
-(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSLog(@"didSendIQ:%@",iq.description);
    //    1、  didSendIQ:
    //    2、  didSendIQ:
    //    3、（手动发送好友列表请求）  didSendIQ:
}
-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq//返回IQ(好友列表)
{
    //获取好友列表
    NSLog(@"--type:%@",iq.type);
    NSLog(@"--%@",[iq.childElement children]);
    NSLog(@"--child:%@",iq.childElement );

    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        NSXMLElement *aitem=[[query children] lastObject];
        NSString *ajid = [aitem attributeStringValueForName:@"jid"];
        NSLog(@"ajid=%@",ajid);
        if ([@"query" isEqualToString:query.name]&&ajid) {
            NSArray *items = [query children];
            NSLog(@"iq.to=%@  items.count=%d ",iq.to,items.count);
            [self.rosterArray removeAllObjects];
            for (NSXMLElement *item in items) {
                //"\U9510\U6770\U7f51\U683c",
                NSString *groupName;
                if (item.children.count>0) {
                    groupName= [[item.children objectAtIndex:0]stringValue];
                }
                else
                {
                    groupName = @"friends";
                }
                NSString *jid = [item attributeStringValueForName:@"jid"];
                NSLog(@"分组groupName=%@",groupName);
                XMPPJID *object = [XMPPJID jidWithString:jid];
                NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:jid,@"object",@"no",@"presenceType",groupName,@"group", nil];
                [self.rosterArray addObject:dic];
                //
                if (![self.rosterInfoDic objectForKey:object.user]&&object)//if本地数据没有该好友信息，就请求fetchvCardTempForJID
                {
                    self.lastFetchedvCard=nil,
                    self.lastFetchedvCard=object;
                    [_xmppvCardTempModule fetchvCardTempForJID:object ignoreStorage:YES];
                }
                NSLog(@"FAMILY=%@\n self.lastFetchedvCard=%@ \nobject.description=%@ ",[[self.rosterInfoDic objectForKey:object.user] objectForKey:@"FAMILY"],self.lastFetchedvCard,object.description);
                
            }
            //更新好友列表
            if ([self.chatDelegate respondsToSelector:@selector(buddyRoster:)]) {
                [self.chatDelegate buddyRoster:self.rosterArray];
            }
            
        }
        if ([@"vCard" isEqualToString:query.name])
        {
            
        }
    }
    return YES;
}
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"didFailToSendMessage:%@",error.description);
}
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *to = [[message attributeForName:@"to"] stringValue];
    NSString *type= [[message attributeForName:@"type"] stringValue];
    NSRange range=[to rangeOfString:@"@"];
    if(range.length==0)return;
    NSString *toSimple=[to substringToIndex:range.location];
    NSLog(@"发送给%@的消息： %@ (消息类型：%@)",toSimple,msg,type);
    if ([message isChatMessageWithBody])//message
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:from forKey:@"sender"];
        [dict setObject:msg forKey:@"msg"];
        [dict setObject:@"text" forKey:@"type"];
        [dict setObject:[NSDate date] forKey:@"date"];
        
        if (![self.messageRecordDic objectForKey:toSimple]&&dict) {
            NSMutableArray *array=[[NSMutableArray alloc]init];
            [array addObject:dict];
            [self.messageRecordDic setObject:array forKey:toSimple];
        }
        else
        {
            NSMutableArray *array1=[self.messageRecordDic objectForKey:toSimple];
            [array1 addObject:dict];
        }
        [self.messageSenders setObject:@"0" forKey:toSimple];//将最近联系人放入messageSenders中
        NSNotification *notificationObject =[NSNotification notificationWithName:@"messageGetting"object:nil];
        [[NSNotificationCenter defaultCenter]postNotification:notificationObject];
    }
}
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence//接收上下线通知
{
//available: 表示处于在线状态(通知好友在线)
//unavailable: 表示处于离线状态（通知好友下线）
//subscribe: 表示对方发出添加好友的申请（添加好友请求）
//unsubscribe: 表示对方发出删除好友的申请（删除好友请求）
//unsubscribed: 表示对方拒绝添加我为好友
//error: 表示presence信息报中包含了一个错误消息。（出错）
    NSLog(@"presence = %@", presence);
    //取得好友状态
    NSString *presenceType = [presence type]; //online/offline
    //当前用户
    NSString *userId = [[sender myJID] user];
    //在线用户
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:userId]) {
        //在线状态
        //        presence 的状态：
        //
        //        available 上线
        //
        //        away 离开
        //
        //        do not disturb 忙碌
        //
        //         unavailable 下线
        if ([presenceType isEqualToString:@"available"]) {
            //用户列表委托 //在线状态
            //用户列表委托
            for (NSMutableDictionary *dic in self.rosterArray) {
                NSString *jid = [dic objectForKey:@"object"];
                XMPPJID *object = [XMPPJID jidWithString:jid];
                if ([object.user hasPrefix:presenceFromUser]) {
                    [dic setObject:@"yes" forKey:@"presenceType" ];
                }
            }
            NSLog(@"%@上线了",presenceFromUser);
//            [self.chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, LOCALHOST]];
        }else if ([presenceType isEqualToString:@"unavailable"]) {
            //用户列表委托
            //用户列表委托
            for (NSMutableDictionary *dic in self.rosterArray) {
                
                NSString *jid = [dic objectForKey:@"object"];
                XMPPJID *object = [XMPPJID jidWithString:jid];
                if ([object.user hasPrefix:presenceFromUser]) {
                    [dic setObject:@"no" forKey:@"presenceType" ];
                }
            }
            NSLog(@"%@下线了",presenceFromUser);
//            [self.chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, LOCALHOST]];
        }
        else if ([presenceType isEqualToString:@"subscribed"]) {
            [[self keyWindow]makeToast:@"对方已验证"];
        }
        else if ([presenceType isEqualToString:@"unsubscribed"])
        {
            [[self keyWindow]makeToast:@"对方拒绝"];
        }
        else if ([presenceType isEqualToString:@"unsubscribe"])
        {
            [[self keyWindow]makeToast:@"对方已经删除您为好友"];
        }
        else if ([presenceType isEqualToString:@"subscribe"])
        {
            [[self keyWindow]makeToast:@"有对方申请做您好友信息"];
        }
        
    }
    else
    {
//        跟自己一样的用户登录了
    }
    [self updateallUsersDataDic_Group_Presence];
    
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"didReceiveError  description: %@",error.description);
    DDXMLNode *errorNode = (DDXMLNode *)error;
    for(DDXMLNode *node in [errorNode children])
    {
        //若错误节点有【冲突】
        if([[node name] isEqualToString:@"conflict"])
        {
            //停止轮训检查链接状态
            //[_timer invalidate];
            [self disconnect];
//            if ([self.chatDelegate respondsToSelector:@selector(buddyRoster:)]) {
//                [self.chatDelegate buddyRoster:self.rosterInfoDic];
//            }
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您的账户已在其他手机上登录，您已被挤下线，请确定是否是您本人操作!是否重新登录？" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}
//[xmppStream disconnect]时会执行；掉线、断网故障时不执行
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWasToldToDisconnect");
}
//注册成功时调用

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    if ([self.loginDelegate respondsToSelector:@selector(RegisterSuccess:)]) {
        [self.loginDelegate RegisterSuccess:YES];
    }
}

//注册失败时调用

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    if ([self.loginDelegate respondsToSelector:@selector(RegisterSuccess:)]) {
        [self.loginDelegate RegisterSuccess:NO];
    }
}
#pragma mark _roster delegate
//处理加好友回调,加好友
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"好友状态更改--%s",__func__);
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSString *presenceFrom =[NSString stringWithFormat:@"%@", [presence from]];
    NSLog(@"presenceType:%@",presenceType);
    
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"对方申请做您好友" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"拒绝",@"暂不处理，下次提示", nil];
    alert.tag = 1;
    alert.accessibilityIdentifier = presenceFrom;
    [alert show];
}
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq
{
    NSLog(@"添加成功!!!didReceiveRosterPush -> :%@",iq.description);
    
    DDXMLElement *query = [iq elementsForName:@"query"][0];
    DDXMLElement *item = [query elementsForName:@"item"][0];
    
    NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
    // 对方请求添加我为好友且我已同意
    if ([subscription isEqualToString:@"from"]) {// 对方关注我
        NSLog(@"我已同意对方添加我为好友的请求");
    }
    // 我成功添加对方为好友
    else if ([subscription isEqualToString:@"to"]) {// 我关注对方
        NSLog(@"我成功添加对方为好友，即对方已经同意我添加好友的请求");
    } else if ([subscription isEqualToString:@"remove"]) {
        // 删除好友
//        if (self.completionBlock) {
//            self.completionBlock(YES, nil);
//        }  
    } else if([subscription isEqualToString:@"none"])
    {
//        [[self keyWindow]makeToast:@"申请已发送"];
    }
}
// 已经互为好友以后，会回调此
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item {
    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    if ([subscription isEqualToString:@"both"]) {
        NSLog(@"双方已经互为好友");
//        if (self.buddyListBlock) {
//            // 更新好友列表
//            [self fetchBuddyListWithCompletion:self.buddyListBlock];
//        }
        [self getMyQueryRoster];
    }
    
}
// 收到花名册
- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence//接受好友请求
{
    NSLog(@"%s",__func__);
    XMPPUserCoreDataStorageObject *user = [_rosterSave userForJID:[presence from]
                                                             xmppStream:_xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare]){
        body = [NSString stringWithFormat:@"Buddy request from %@ <</span>%@>", displayName, jidStrBare];
    }else{
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    } else {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}
//获取到一个好友节点
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item
{
    
}
//获取完好友列表
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"%@",sender);
    NSLog(@"获取完毕好友列表");
//    [SVProgressHUD showSuccessWithStatus:@"登录成功"];
    if ([self.lastFetchedvCard.user isEqualToString:_xmppStream.myJID.user]) {
//        [SVProgressHUD dismiss];
    }
    [self updateallUsersDataDic_Group_Presence];
    //发给BigDesktopViewController
    NSNotification *notificationObject_1 =[NSNotification notificationWithName:@"DidAuthenticate"object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject_1];
    
    //更新好友列表
//    if([self.chatDelegate respondsToSelector:@selector(buddyRoster:)])
//    {
//        [self.chatDelegate buddyRoster:self.rosterInfoDic];
//    }
}

#pragma mark card//没弄懂
//获取联系人的名片，如果数据库有就返回，没有返回空，并到服务器上抓取
- (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid shouldFetch:(BOOL)shouldFetch
{
    return nil;
}
//更新自己的名片信息
- (void)updateMyvCardTemp:(XMPPvCardTemp *)vCardTemp
{
    
}
//到服务器上请求联系人名片信息
- (void)fetchvCardTempForJID:(XMPPJID *)jid;
{
    
}
//请求联系人的名片，如果数据库有就不请求，没有就发送名片请求
- (void)fetchvCardTempForJID:(XMPPJID *)jid ignoreStorage:(BOOL)ignoreStorage
{
    
}

#pragma mark roomDelegate
-(void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    [self ConfigureNewRoom:self.createRoom];
}
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"%s",__func__);
}

- (void)xmppRoom:(XMPPRoom *)sender willSendConfiguration:(XMPPIQ *)roomConfigForm
{
    NSLog(@"%@",roomConfigForm);
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"seccuss" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    if ([self.roomDelegate respondsToSelector:@selector(roomCreateSuccess:)]) {
        [self.roomDelegate roomCreateSuccess:YES];
    }
}
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"failed" message:iqResult.description delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    if ([self.roomDelegate respondsToSelector:@selector(roomCreateSuccess:)]) {
        [self.roomDelegate roomCreateSuccess:NO];
    }
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
//    [self.createRoom fetchConfigurationForm];
//    [self.createRoom fetchBanList];
//    [self.createRoom fetchMembersList];
//    [self.createRoom fetchModeratorsList];
    
}
//[xmppRoom deactivate:xmppStream];
//离开聊天室
- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"%@",sender.description);
}
//新人加入群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
}
//有人退出群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"jid:%@  presence ; %@",occupantJID,presence);
    
}

/**
 * Invoked when a message is received.
 * The occupant parameter may be nil if the message came directly from the room, or from a non-occupant.
 **/
//有人在群里发言
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    
}
// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"%@",items);
    //    [_roomVC  listMemberWithData:items type:memberType_ban];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}
// 收到好友名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"%@",items);
    //    [_roomVC listMemberWithData:items type:memberType_members];
    
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}
// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"%@",items);
    //    [_roomVC listMemberWithData:items type:memberType_moderators];
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
    
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    NSLog(@"%@",iqResult);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotEditPrivileges:(XMPPIQ *)iqError
{
    NSLog(@"%@",iqError);
}
#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}
#pragma mark-XMPPvCardTempModuleDelegate名片信息
//获取到一盒联系人的名片信息的回调
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    //    NSLog(@"%s",__func__);
    NSXMLElement *xmlData=(NSXMLElement *)vCardTemp;
    NSString *titleString = @"这个用户很懒，没有签名！";
    NSString *familyString = @"无名用户";
    NSString *photoString = @"";
    for(id myItem in [xmlData children])
    {
        NSLog(@"myItem name=%@",[myItem name]);
        if([myItem stringValue].length <= 100)
        {
            NSLog(@"valuelalala:%@",[myItem stringValue]);
        }
        else
        {
            NSLog(@"too long");
        }
        if([[myItem name] isEqualToString:@"TITLE"])
        {
            titleString = [myItem stringValue];
        }
        else if([[myItem name] isEqualToString:@"N"])
        {
            familyString = [myItem stringValue];
        }
        else if([[myItem name] isEqualToString:@"PHOTO"])
        {
            photoString = [[myItem stringValue] substringFromIndex:5];
        }
    }
    //    头像image 写入本地
//    NSString *PHOTOImagePath=[self writeDateBase_64Image:photoString WithFileName:jid.user Size:CGSizeMake(88, 88)];
//    NSMutableDictionary *dicObject=[[NSMutableDictionary alloc]initWithObjectsAndKeys:titleString,@"TITLE",familyString,@"FAMILY",PHOTOImagePath,@"PHOTO", nil];
    NSMutableDictionary *dicObject=[[NSMutableDictionary alloc]initWithObjectsAndKeys:titleString,@"TITLE",familyString,@"FAMILY", nil];
    [self.rosterInfoDic setObject:dicObject forKey:jid.user];//
    //family photopath title 写入本地
    NSLog(@"forJID:(XMPPJID *)jid=%@   \n self.lastFetchedvCard=%@   \n ",jid.user,self.lastFetchedvCard.user);
    if ([self.lastFetchedvCard.user isEqualToString:jid.user])//(在最后一次名片请求的时候,写入本地,)
    {
        //        [DataPlist writeDP:self.rosterInfoDic WithName:xmppStream.myJID.user AndTheType:@"plist"];
//        [DataPlist writePlistToDocumentWithDic:self.rosterInfoDic WithName:xmppStream.myJID.user AndTheType:@"plist"];
    }
//    if ([self.chatDelegate respondsToSelector:@selector(buddyRoster:)]) {
//        [self.chatDelegate buddyRoster:self.rosterInfoDic];
//    }
}
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule//更新名片
{
    NSLog(@"%s--%@",__func__,vCardTempModule);
}
#pragma mark Core Data
- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [_roomSave mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [_xmppCapabilitiesStorage mainThreadManagedObjectContext];
}
#pragma mark Private

-(void)sendDefaultRoomConfig
{
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    
    NSXMLElement *fieldowners = [NSXMLElement elementWithName:@"field"];
    NSXMLElement *valueowners = [NSXMLElement elementWithName:@"value"];
    
    
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];  // 永久属性
    [fieldowners addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomowners"];  // 谁创建的房间
    
    
    [field addAttributeWithName:@"type" stringValue:@"boolean"];
    [fieldowners addAttributeWithName:@"type" stringValue:@"jid-multi"];
    
    [value setStringValue:@"1"];
    [valueowners setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:NAME]]; //创建者的Jid
    
    [x addChild:field];
    [x addChild:fieldowners];
    [field addChild:value];
    [fieldowners addChild:valueowners];
    
    [self.createRoom configureRoomUsingOptions:x];
    
}
-(void)ConfigureNewRoom:(XMPPRoom*)xmppRoom{
    //[xmppRoom fetchConfigurationForm];
    //配置
    
    
    NSLog(@"123---%@",xmppRoom.myNickname);
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"label" stringValue:@"Make Room Persistent?"];
    [field addAttributeWithName:@"type" stringValue:@"boolean"];
    [field addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    [value setStringValue:@"1"];
    [field addChild:value];
    [x addChild:field];
    
    NSXMLElement *fieldMaxInviteMember = [NSXMLElement elementWithName:@"field"];
    [fieldMaxInviteMember addAttributeWithName:@"label" stringValue:@"Allow Occupants to Invite Others?"];
    [fieldMaxInviteMember addAttributeWithName:@"type" stringValue:@"boolean"];
    [fieldMaxInviteMember addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];
    NSXMLElement *inViteValue = [NSXMLElement elementWithName:@"value"];
    [inViteValue setStringValue:@"1"];
    [fieldMaxInviteMember addChild:inViteValue];
    [x addChild:fieldMaxInviteMember];
    //仅仅会员开放
    NSXMLElement *fieldOnlyMember = [NSXMLElement elementWithName:@"field"];
    [fieldOnlyMember addAttributeWithName:@"label" stringValue:@"Make Room Members-Only?"];
    [fieldOnlyMember addAttributeWithName:@"type" stringValue:@"boolean"];
    [fieldOnlyMember addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    NSXMLElement *onlyMemberValue = [NSXMLElement elementWithName:@"value"];
    [onlyMemberValue setStringValue:@"1"];
    [fieldOnlyMember addChild:onlyMemberValue];
    [x addChild:fieldOnlyMember];
    //是否要密码
    //    NSXMLElement *fieldneedPWord = [NSXMLElement elementWithName:@"field"];
    //    [fieldneedPWord addAttributeWithName:@"label" stringValue:@"Password Required to Enter?"];
    //    [fieldneedPWord addAttributeWithName:@"type" stringValue:@"boolean"];
    //    [fieldneedPWord addAttributeWithName:@"var" stringValue:@"muc#roomconfig_passwordprotectedroom"];
    //    NSXMLElement *fieldneedPWordValue = [NSXMLElement elementWithName:@"value"];
    //    [fieldneedPWordValue setStringValue:@"1"];
    //    [fieldneedPWord addChild:fieldneedPWordValue];
    //    [x addChild:fieldneedPWord];
    
    //desciption
    NSXMLElement *fieldesc = [NSXMLElement elementWithName:@"field"];
    [fieldesc addAttributeWithName:@"label" stringValue:@"Short Description of Room"];
    [fieldesc addAttributeWithName:@"type" stringValue:@"text-single"];
    [fieldesc addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
    NSXMLElement *fieldescValue = [NSXMLElement elementWithName:@"value"];
    [fieldescValue setStringValue:xmppRoom.roomSubject];
    [fieldesc addChild:fieldescValue];
    [x addChild:fieldesc];
    
    
    //    NSXMLElement *fielpassword= [NSXMLElement elementWithName:@"field"];
    //    [fielpassword addAttributeWithName:@"label" stringValue:@"The Room Password"];
    //    [fielpassword addAttributeWithName:@"type" stringValue:@"text-single"];
    //    [fielpassword addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomsecret"];
    //    NSXMLElement *fielpasswordValue = [NSXMLElement elementWithName:@"value"];
    //    [fielpasswordValue setStringValue:@"123"];
    //    [fielpassword addChild:fielpasswordValue];
    //    [x addChild:fielpassword];
    
    //    <field
    //    var='muc#roomconfig_roomsecret'
    //    type='text-private'
    //    label='The Room Password'/>
    //    <field
    
    
    
    //最大成员
    NSXMLElement *fieldMaxMember = [NSXMLElement elementWithName:@"field"];
    [fieldMaxMember addAttributeWithName:@"label" stringValue:@"Allow Occupants to Invite Others?"];
    [fieldMaxMember addAttributeWithName:@"type" stringValue:@"list-single"];
    [fieldMaxMember addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];
    NSXMLElement *maxvVlue = [NSXMLElement elementWithName:@"value"];
    [maxvVlue setStringValue:@"30"];
    [fieldMaxMember addChild:maxvVlue];
    [x addChild:fieldMaxMember];
    
    [xmppRoom configureRoomUsingOptions:x];
    
    
}
#pragma mark alertdelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1) {
        if (buttonIndex==0) {
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",alertView.accessibilityIdentifier]];
            [_roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
            
        }
        else
        {
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",alertView.accessibilityIdentifier]];
            [_roster rejectPresenceSubscriptionRequestFrom:jid];
        }
        
    }
}
#pragma mark Private
- (void)myTeardownStream//
{
    [_xmppStream removeDelegate:self];
    [_roster removeDelegate:self];
    
    [_xmppReconnect         deactivate];
    [_roster            deactivate];
    [_xmppvCardTempModule   deactivate];
    [_xmppvCardAvatarModule deactivate];
    [_xmppCapabilities      deactivate];
    
    [_xmppStream disconnect];
    _xmppStream = nil;
    _xmppReconnect = nil;
    _roster = nil;
    _roomSave = nil;
    _xmppvCardStorage = nil;
    _xmppvCardTempModule = nil;
    _xmppvCardAvatarModule = nil;
    _xmppCapabilities = nil;
    _xmppCapabilitiesStorage = nil;
}
- (void)myDeleteRecord//清楚聊天，信息记录
{
    [self.messageRecordDic removeAllObjects];
    [self.messageSenders removeAllObjects];
    
}
- (void)updateallUsersDataDic_Group_Presence//更新分组+在线、离线状态好友数据
{
    [self.allUsersDataDic removeAllObjects];
    for(int i = 0; i < self.rosterArray.count; i++)
    {
        
        NSMutableDictionary *adic = [self.rosterArray objectAtIndex:i];
        NSString *jid = [adic objectForKey:@"object"];
        XMPPJID *ajid = [XMPPJID jidWithString:jid];
        if ([ajid.user isEqualToString:_xmppStream.myJID.user])
        {
            continue;
        }
        NSString *groupName=[adic objectForKey:@"group"];//分组名
        NSString *presenceType=[adic objectForKey:@"presenceType"];//状态
        NSMutableArray *arrayWithgroupName=[self.allUsersDataDic objectForKey:groupName];//该关键字的数组
        if (arrayWithgroupName)//存在该关键字的数组
        {
            
            if ([presenceType isEqualToString:@"yes"])
            {
                [arrayWithgroupName insertObject:[NSNumber numberWithInt:i] atIndex:0];//在线好友加到数组第一个
            }
            else
            {
                [arrayWithgroupName addObject:[NSNumber numberWithInt:i]];//离线的好友，加到数组最后一个
            }
        }
        else//不存在该关键字的数组
        {
            NSMutableArray *newArray=[[NSMutableArray alloc]init];
            [newArray addObject:[NSNumber numberWithInt:i]];//在线或者离线的好友，加到空白数组里面
            [self.allUsersDataDic setObject:newArray forKey:groupName];//groupName=newArray,添加到allUsersDataDic
        }
        
        
    }
}
- (UIWindow *)keyWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    return keyWindow;
}
@end
