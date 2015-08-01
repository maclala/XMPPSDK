//
//  KKChatDelegate.h
//  XMPP
//
//  Created by 丁海伟 on 15-2-3.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

@protocol ChatDelegate <NSObject>


-(void)buddyRoster:(NSMutableArray*)rosterArray;
-(void)didDisconnect;

@end