//
//  KKMessageDelegate.h
//  XMPP
//
//  Created by 丁海伟 on 15-2-3.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//


@protocol MessageDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary*)messageContent;
-(void)sendMessageSuccessed:(BOOL)isSuccess;

@end