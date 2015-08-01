//
//  NSString+DocumentPath.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-24.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "NSString+DocumentPath.h"

@implementation NSString(DocumentPath)
+(NSString *)documentPathWith:(NSString *)fileName
{
    
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
}
@end
