//
//  IPConfig.h
//  CleanCar
//
//  Created by 丁海伟 on 14-3-26.
//  Copyright (c) 2014年 dhw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEVELOP_IP @"http://123.56.45.245:8080/files/user/res/company"

#define GET @"GET"
#define POST @"POST"
@interface IPConfig : NSObject

@property (nonatomic,copy) NSString *ip;
@property (nonatomic,copy) NSString *port;

@property (nonatomic,copy) NSString *apiPath;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) NSString *httpMethod;
@property (nonatomic,strong) NSDictionary * headerFields;
//全路径
@property (nonatomic,copy) NSString *allUrl;
//传给mk的hostname
@property (readonly) NSString *hostName;
@property (readonly) BOOL SSL;

-(id)initWithUrl:(NSString *)url;
@end
