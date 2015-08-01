//
//  HttpManager.m
//  ExampleProject
//
//  Created by 丁海伟 on 14-7-29.
//  Copyright (c) 2014年 丁海伟. All rights reserved.
//

#import "HttpManager.h"
#import "IPConfig.h"
@interface HttpManager(private)

@end

@implementation HttpManager

static HttpManager * __sharedInstance__;
+ (HttpManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    __sharedInstance__ = [[self alloc] init];
    });
    return __sharedInstance__;
}

- (id)init
{
    if (!__sharedInstance__)
    {
        self = [super init];
        if (self)
        {
            
        }
        __sharedInstance__ = self;
    }
    
    return __sharedInstance__;
}
-(int)deviceNetWorkState:(IPConfig *)config;//网络状态 0:没网络,1:3G网,2:wlan网
{
    if (config) {
        
    }
    else
    {
        NSString *url = [NSString stringWithFormat:@"%@",DEVELOP_IP];
        config = [[IPConfig alloc]initWithUrl:url];
        config.httpMethod = GET;
    }
    int isExistenceNetwork = 0;
    Reachability *netWorkState=[Reachability reachabilityWithHostname:config.hostName];
    NSString *msg = @"";
    NSString *title=@"";
    
    switch ([netWorkState currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=0;
            title=@"提示信息";
            msg=@"没有检测到网络,请稍候重试";
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=1;
            title=@"提示";
            msg=@"正在使用3G网络";
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=2;
            title=@"提示";
            msg=@"正在使用wifi网络";
            break;
            
    }
    return isExistenceNetwork;
    
}

- (void)dealloc
{
    __sharedInstance__ = nil;
}

#pragma mark - public methods

- (void)loginWithAccount:(NSString*)accountName
                password:(NSString*)password
           succsessBlock:(SuccsessBlock)succsessBlock
            failureBlock:(FailureBlock)failureBlock
{
    NSString *url = [NSString stringWithFormat:@"%@",DEVELOP_IP];
    IPConfig *config = [[IPConfig alloc]initWithUrl:url];
    config.httpMethod = GET;
    
    Communication *com = [[Communication alloc]init];
    NSDictionary *dic = @{@"token":@"8126a296771e5287dc68edcb0c863b25",@"userId":@"aaa"};
    [com PostToServerParams:dic ActionName:@"regist.html" HostName:config.hostName path:config.apiPath HeaderFields:nil SSL:config.SSL HttpMethod:config.httpMethod CallBackSuccessBlock:^(id response){
        succsessBlock(response);
        
    }
    CallBackErrorBlock:^(NSString *errorCode, NSString *errorMSG) {
        failureBlock(errorCode,errorMSG);
    } CallBackProgressBlock:^(double progress) {
        
    }];
}


@end
