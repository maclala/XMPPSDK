//
//  ChartMessage.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    
    kMessageFrom=0,
    kMessageTo
    
}ChartMessageType;
typedef enum {
    kMessageText=0,
    kMessageAudio,
    kMessageImage,
    
}ChartMessageAttribute;
@interface ChartMessage : NSObject
//发送还是接收方
@property (nonatomic,assign) ChartMessageType messageType;
//属于那种格式
@property (nonatomic,assign) ChartMessageAttribute messageAttribute;
@property (nonatomic, copy) NSString *icon;
//@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSDictionary *dict;
@end
