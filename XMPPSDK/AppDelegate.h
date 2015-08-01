//
//  AppDelegate.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmppCenter.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic ,strong)XmppCenter *xmppCenter;
@property (nonatomic,strong)UITabBarController *tabBarController;
@property(nonatomic,strong)UIView *tabBarBtnContainer;
@property(nonatomic,strong)UIButton *tabBarBtn;


@end

