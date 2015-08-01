//
//  XmppCenter.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginDelegate.h"
#import "ChatDelegate.h"
#import "MessageDelegate.h"
#import "RoomDelegate.h"

@interface XmppCenter : NSObject
@property(nonatomic,strong)NSMutableDictionary*messageRecordDic;
@property(nonatomic,strong)NSMutableArray*rosterArray;
@property(nonatomic,strong)NSMutableDictionary*messageSenders;
@property(nonatomic,strong)NSMutableDictionary*allUsersDataDic;
@property(nonatomic,strong)NSMutableDictionary*cacheinfo;
@property(nonatomic,strong)NSMutableDictionary*settinginfo;
@property(nonatomic,strong)NSMutableDictionary*serverInfo;
@property(nonatomic,strong)NSMutableDictionary*userInfo;
@property(nonatomic,strong)NSMutableDictionary*rosterInfoDic;

@property(nonatomic,weak)id<LoginDelegate> loginDelegate;
@property(nonatomic,weak)id<ChatDelegate> chatDelegate;
@property (weak,nonatomic)id <MessageDelegate> messageDelegate;
@property(weak,nonatomic)id<RoomDelegate>roomDelegate;

-(BOOL)registerName:(NSString*)name Password:(NSString*)password ServerID:(NSString *)serverId;
-(BOOL)connectName:(NSString*)name Password:(NSString*)password ServerID:(NSString *)serverId;
-(void)disconnect;
-(void)setupStream;
-(void)goOnline;
-(void)goOffLine;
-(void)removeBuddy:(NSString *)buddyID;
-(void)addBuddy:(NSString*)buddyID;
-(void)createForeverRoom:(NSString *)roomName NickName:(NSString*)nickName;
-(void)getExistRoom;
-(void)joinRoom:(NSString *)nickName;
-(void)sendMessage:(NSDictionary *)messageDic;
@end
