//
//  HttpManager.h
//  ExampleProject
//
//  Created by 丁海伟 on 14-7-29.
//  Copyright (c) 2014年 丁海伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Communication.h"
#if NS_BLOCKS_AVAILABLE
#pragma mark - 定义一个http请求完成后，成功的回调block类型
typedef void(^SuccsessBlock)(id responseObject);
#pragma mark - 定义一个http请求完成后，失败的回调block类型
typedef void(^FailureBlock)(NSString *errorCode, NSString *errorMSG);
#pragma mark - 定义一个http请求进度回调block类型
typedef void(^UPProgressBlock)(double progress);
#endif



//网络请求响应码
typedef enum
{
    RESPONSE_CODE_SUCCESS = 0,          //成功
    RESPONSE_CODE_NET_FAILURE = -1,     //网络请求失败
    RESPONSE_CODE_SERVER_FAILURE = -2   //服务器返回异常
} RESPONSE_CODE;

//网络请求响应码键
#define KEY_RESPONSE_STATUS @"keyResponseStatus"

@class RequestModel;
@class ResponseDataModel;
@class IPConfig;
@interface HttpManager : NSObject

//@property (strong, nonatomic) User* currentUser;

+ (HttpManager *)sharedInstance;
-(int)deviceNetWorkState:(IPConfig *)config;//网络状态 0:没网络,1:3G网,2:wlan网
//登录
- (void)loginWithAccount:(NSString*)accountName
                password:(NSString*)password
           succsessBlock:(SuccsessBlock)succsessBlock
            failureBlock:(FailureBlock)failureBlock;

@end
