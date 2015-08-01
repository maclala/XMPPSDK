//
//  Communication.m
//  PinganBankiPad
//
//  Created by dhw on 13-9-12.
//  Copyright (c) 2013年 dhw. All rights reserved.
//

#import "Communication.h"
@implementation Communication
-(NSString *)getErrorMessage:(NSString *)englishErrorMessage{
    
    if ([englishErrorMessage isEqualToString:@"Could not connect to the server."]) {
        return @"网络连接失败，请检查网络连接!";
    }
    else if([englishErrorMessage isEqualToString:@"The request timed out."]){
        return @"网络不给力啊,请求超时了!";
    }
    else if([englishErrorMessage isEqualToString:@"The network connection was lost."]){
        return @"网络丢失,交易状态不明,请查询该交易状态！";
    }
    
    else if([englishErrorMessage rangeOfString:@"400"].location!=NSNotFound){
        return @"Bad Request！";
    }
    else if([englishErrorMessage rangeOfString:@"401"].location!=NSNotFound){
        return @"Unauthorized！";
    }
    else if([englishErrorMessage rangeOfString:@"402"].location!=NSNotFound){
        return @"Payment Required！";
    }
    else if([englishErrorMessage rangeOfString:@"403"].location!=NSNotFound){
        return @"Forbidden!";
    }
    else if([englishErrorMessage rangeOfString:@"404"].location!=NSNotFound){
        return @"连接服务器失败!";
    }
    else if([englishErrorMessage rangeOfString:@"405"].location!=NSNotFound){
        return @"Method NotAllowed！";
    }
    else if([englishErrorMessage rangeOfString:@"406"].location!=NSNotFound){
        return @"Not Acceptable！";
    }
    else if([englishErrorMessage rangeOfString:@"407"].location!=NSNotFound){
        return @"Proxy AuthenticationRequired！";
    }
    else if([englishErrorMessage rangeOfString:@"408"].location!=NSNotFound){
        return @"Request Time-out！";
    }
    else if([englishErrorMessage rangeOfString:@"409"].location!=NSNotFound){
        return @"Conflict！";
    }
    else if([englishErrorMessage rangeOfString:@"410"].location!=NSNotFound){
        return @"Gone！";
    }
    else if([englishErrorMessage rangeOfString:@"411"].location!=NSNotFound){
        return @"Length Required！";
    }
    else if([englishErrorMessage rangeOfString:@"412"].location!=NSNotFound){
        return @"PreconditionFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"413"].location!=NSNotFound){
        return @"PreconditionFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"414"].location!=NSNotFound){
        return @"Request-URI TooLarge！";
    }
    else if([englishErrorMessage rangeOfString:@"415"].location!=NSNotFound){
        return @"Unsupported MediaType！";
    }
    else if([englishErrorMessage rangeOfString:@"416"].location!=NSNotFound){
        return @"Requested range notsatisfiable！";
    }
    else if([englishErrorMessage rangeOfString:@"417"].location!=NSNotFound){
        return @"ExpectationFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"500"].location!=NSNotFound){
        return @"服务器内部错误！";
    }
    else if([englishErrorMessage rangeOfString:@"501"].location!=NSNotFound){
        return @"Not Implemented！";
    }
    else if([englishErrorMessage rangeOfString:@"502"].location!=NSNotFound){
        return @"网关错误！";
    }
    else if([englishErrorMessage rangeOfString:@"503"].location!=NSNotFound){
        return @"ServiceUnavailable！";
    }
    else if([englishErrorMessage rangeOfString:@"504"].location!=NSNotFound){
        return @"网关超时!";
    }
    else if([englishErrorMessage rangeOfString:@"505"].location!=NSNotFound){
        return @"HTTP Version notsupported！";
    }
    else if([englishErrorMessage rangeOfString:@"The Internet connection appears to be offline"].location!=NSNotFound){
        return @"网络连接失败！";
    }
    else if([englishErrorMessage rangeOfString:@"A server with the specified hostname could not be found"].location!=NSNotFound){
        return @"网络异常！";
    }
    return englishErrorMessage;
}
-(void)PostToServerParams:(id)bodyDic
               ActionName:(NSString *)action
                 HostName:(NSString *)hostName
                     path:(NSString *)path
             HeaderFields:(NSDictionary *)headerDic
                      SSL:(BOOL)ssl
               HttpMethod:(NSString *)method
     CallBackSuccessBlock:(void (^)(id))callbackSuccessBlock
       CallBackErrorBlock:(void (^)(NSString *, NSString *))callbackErrorBlock
    CallBackProgressBlock:(void (^)(double))callbackProgressBlock
{
    NSString *pathStr;
    if ([path isEqualToString:@""]||path == nil) {
        pathStr = [NSString stringWithFormat:@"%@",action];
    }
    else
    {
        pathStr = [NSString stringWithFormat:@"%@/%@",path,action];
    }
    networkEngine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:headerDic];
    op = [networkEngine operationWithPath:pathStr params:bodyDic httpMethod:method ssl:ssl];
    [op onDownloadProgressChanged:^(double progress) {
        callbackProgressBlock(progress);
        
    }];
    Communication* tempSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if ([completedOperation responseJSON]) {
            callbackSuccessBlock([completedOperation responseJSON]);
            return ;
        }
        else if ([completedOperation responseString])
        {
            callbackSuccessBlock([completedOperation responseString]);
            return;
        }
        else if ([completedOperation responseData])
        {
            callbackSuccessBlock([completedOperation responseData]);
            return;
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回数据为空，请检查请求或服务器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString*errorStr=[tempSelf getErrorMessage:[error localizedDescription]];
        callbackErrorBlock([error localizedDescription],errorStr);

    }];
//    op.shouldContinueWithInvalidCertificate = YES;
    [networkEngine enqueueOperation:op];
}
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
       CallBackErrorBlock:(void (^)(NSString *, NSString *))callbackErrorBlock
    CallBackProgressBlock:(void (^)(double))callbackProgressBlock
{
    NSString *pathStr;
    if ([path isEqualToString:@""]||path == nil) {
        pathStr = [NSString stringWithFormat:@"%@",action];
    }
    else
    {
        pathStr = [NSString stringWithFormat:@"%@/%@",path,action];
    }
    networkEngine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:headerDic];
    op = [networkEngine operationWithPath:pathStr params:bodyDic httpMethod:method ssl:ssl];
    [op addData:data forKey:key];
    op.freezable = YES;
    [op onUploadProgressChanged:^(double progress) {
        callbackProgressBlock(progress);
    }];
    Communication* tempSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        DLog(@"%@",completedOperation);
        if ([completedOperation responseJSON]) {
            callbackSuccessBlock([completedOperation responseJSON]);
            return ;
        }
        else if ([completedOperation responseString])
        {
            callbackSuccessBlock([completedOperation responseString]);
            return;
        }
        else if ([completedOperation responseData])
        {
            callbackSuccessBlock([completedOperation responseData]);
            return;
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回数据为空，请检查请求或服务器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString*errorStr=[tempSelf getErrorMessage:[error localizedDescription]];
        callbackErrorBlock([error localizedDescription],errorStr);
        
    }];
    //    op.shouldContinueWithInvalidCertificate = YES;
    [networkEngine enqueueOperation:op];
}
-(void)UploadToServerPath:(NSString *)zipPathStr Key:(NSString *)key Params:(id)bodyDic ActionName:(NSString *)action HostName:(NSString *)hostName path:(NSString *)path HeaderFields:(NSDictionary *)headerDic SSL:(BOOL)ssl HttpMethod:(NSString *)method CallBackSuccessBlock:(void (^)(id))callbackSuccessBlock CallBackErrorBlock:(void (^)(NSString *, NSString *))callbackErrorBlock CallBackProgressBlock:(void (^)(double))callbackProgressBlock
{
    NSString *pathStr;
    if ([path isEqualToString:@""]||path == nil) {
        pathStr = [NSString stringWithFormat:@"%@",action];
    }
    else
    {
        pathStr = [NSString stringWithFormat:@"%@/%@",path,action];
    }
    networkEngine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:headerDic];
    op = [networkEngine operationWithPath:pathStr params:bodyDic httpMethod:method ssl:ssl];
    [op addFile:zipPathStr forKey:key];
    op.freezable = YES;
    [op onUploadProgressChanged:^(double progress) {
        callbackProgressBlock(progress);
    }];
    Communication* tempSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        DLog(@"%@",completedOperation);
        if ([completedOperation responseJSON]) {
            callbackSuccessBlock([completedOperation responseJSON]);
            return ;
        }
        else if ([completedOperation responseString])
        {
            callbackSuccessBlock([completedOperation responseString]);
            return;
        }
        else if ([completedOperation responseData])
        {
            callbackSuccessBlock([completedOperation responseData]);
            return;
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回数据为空，请检查请求或服务器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString*errorStr=[tempSelf getErrorMessage:[error localizedDescription]];
        callbackErrorBlock([error localizedDescription],errorStr);
        
    }];
    //    op.shouldContinueWithInvalidCertificate = YES;
    [networkEngine enqueueOperation:op];
}
@end
