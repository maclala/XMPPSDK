//
//  Communication.h
//  PinganBankiPad
//
//  Created by dhw on 13-9-12.
//  Copyright (c) 2013年 dhw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkEngine.h"

@interface Communication : NSObject
{
    MKNetworkEngine*networkEngine;
    MKNetworkOperation *op;
}
//普通交易
-(void)PostToServerParams:(id)bodyDic
               ActionName:(NSString *)action
                 HostName:(NSString*)hostName
                     path:(NSString *)path
             HeaderFields:(NSDictionary*)headerDic
                      SSL:(BOOL)ssl
               HttpMethod:(NSString*)method
     CallBackSuccessBlock:(void(^)(id response))callbackSuccessBlock
       CallBackErrorBlock:(void(^)(NSString *errorCode, NSString *errorMSG))callbackErrorBlock
    CallBackProgressBlock:(void(^)(double progress))callbackProgressBlock;
//上传data类型
-(void)UploadToServerData:(NSData*)data
                      Key:(NSString*)key
                   Params:(id)bodyDic
               ActionName:(NSString *)action
                 HostName:(NSString *)hostName
                     path:(NSString *)path
             HeaderFields:(NSDictionary *)headerDic
                      SSL:(BOOL)ssl
               HttpMethod:(NSString *)method
     CallBackSuccessBlock:(void (^)(id))callbackSuccessBlock
       CallBackErrorBlock:(void (^)(NSString *errorCode, NSString *errorMSG))callbackErrorBlock
    CallBackProgressBlock:(void (^)(double progress))callbackProgressBlock;
//上传zip类型，本地压缩路径
-(void)UploadToServerPath:(NSString*)zipPathStr
                       Key:(NSString*)key
                    Params:(id)bodyDic
                ActionName:(NSString *)action
                  HostName:(NSString *)hostName
                      path:(NSString *)path
              HeaderFields:(NSDictionary *)headerDic
                       SSL:(BOOL)ssl
                HttpMethod:(NSString *)method
      CallBackSuccessBlock:(void (^)(id))callbackSuccessBlock
        CallBackErrorBlock:(void (^)(NSString *errorCode, NSString *errorMSG))callbackErrorBlock
     CallBackProgressBlock:(void (^)(double progress))callbackProgressBlock;
@end
