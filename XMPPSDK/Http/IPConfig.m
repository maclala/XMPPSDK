//
//  IPConfig.m
//  CleanCar
//
//  Created by 丁海伟 on 14-3-26.
//  Copyright (c) 2014年 dhw. All rights reserved.
//
#import "IPConfig.h"

@implementation IPConfig
@synthesize ip=_ip,port=_port,apiPath=_apiPath,url=_url,SSL=_SSL,httpMethod=_httpMethod,headerFields=_headerFields,allUrl = _allUrl;
-(id)initWithUrl:(NSString *)url
{
    self = [super init];
    [self getConfigPath:url];
    return self;
}

-(void)setIp:(NSString *)ip
{
    if([self isNull:ip] || _ip == ip){
        return;
    }else{
        _ip = ip;
       
    }
    
}

-(void)setPort:(NSString *)port
{
    if([self isNull:port] || _port == port){
        return;
    }else{
        _port = port;
       
    }
}

-(void)setApiPath:(NSString *)apiPath
{
    if([self isNull:apiPath] || _apiPath == apiPath){
        return;
    }else{
        _apiPath = apiPath;
       
    }
}

-(void)setUrl:(NSString *)url
{
    if([self isNull:url] || _url == url){
        return;
    }else{
        _url = url;
        _allUrl = [NSString stringWithFormat:@"%@",url];
        if ([url rangeOfString:@"http://"].length>0) {
            url = [url substringFromIndex:7];
            _SSL= NO ;
        }
        else if ([url rangeOfString:@"https://"].length>0) {
            url = [url substringFromIndex:8];
            _SSL = YES;
        }
        if ([url rangeOfString:@"/"].length>0) {
            NSString *apipath = [url substringFromIndex:[url rangeOfString:@"/"].location];
            _apiPath = [apipath substringFromIndex:1];
            url = [url stringByReplacingOccurrencesOfString:apipath withString:@""];
        }
        else
        {
            _apiPath =@"";
        }
        if ([url rangeOfString:@":"].length>0) {
            NSString *port = [url substringFromIndex:[url rangeOfString:@":"].location];
            _port = [port substringFromIndex:1];
            url = [url stringByReplacingOccurrencesOfString:port withString:@""];
        }
        else
        {
            _port = @"";
        }
        _ip = url;
       
        if (_port==nil||[_port isEqualToString:@""])
        {
            _hostName = [[NSString alloc]initWithFormat:@"%@",_ip];
        }
        else
        {
            _hostName = [[NSString alloc]initWithFormat:@"%@:%@",_ip,_port];
        }
        
    }
}
-(NSString *)url
{
    NSString *url = @"";
    if ([self isNull:self.ip]) {
        return @"";
    }else{
        url = [url stringByAppendingString:self.ip];
    }
    if (![self isNull:self.port]) {
        url = [url stringByAppendingFormat:@":%@",self.port];
    }
    if (![self isNull:self.apiPath]) {
        url = [url stringByAppendingFormat:@"/%@",self.apiPath];
    }
    
    return url;
}
-(void)setAllUrl:(NSString *)allUrl
{
    self.url = allUrl;
}
-(NSString *)allUrl
{
    return _allUrl;
}
-(BOOL)isNull:(id)arg
{
    if (!arg || [arg isEqual:[NSNull null]] || [arg isEqualToString:@""]) {
        //NSLog(@"set prams don't null");
        return YES;
    }
    return NO;
}
-(void)getConfigPath:(NSString *)url
{
    self.url =  url;
}
-(NSString *)httpMethod
{
    if (_httpMethod==nil||[_httpMethod isEqualToString:@""]) {
        _httpMethod = @"POST";
    }
    return _httpMethod;
}
-(void)setHttpMethod:(NSString *)httpMethod
{
    _httpMethod = httpMethod;
}

@end
