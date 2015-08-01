//
//  ChartMessage.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "ChartMessage.h"

@implementation ChartMessage
-(void)setDict:(NSDictionary *)dict
{
    _dict=dict;
    self.messageAttribute = [dict[@"attribute"] intValue];
    self.icon=dict[@"icon"];
    //    self.time=dict[@"time"];
    self.content=dict[@"content"];
    self.messageType=[dict[@"type"] intValue];
}
@end
