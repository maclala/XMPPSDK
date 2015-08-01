//
//  FriendsViewController.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatDelegate.h"
@interface FriendsViewController : UITableViewController<ChatDelegate>
//所有用户信息
@property(nonatomic,strong)NSMutableArray * rosterArray;
@end
