//
//  AppDelegate.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "AppDelegate.h"
#import "FriendsViewController.h"
#import "LoginViewController.h"
#import "GroupTableViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _xmppCenter = [[XmppCenter alloc]init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self addtabbarVC];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.tabBarController];
    self.tabBarController.navigationController.navigationBar.hidden = YES;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *loginNav = [[UINavigationController alloc]initWithRootViewController:login];
    [self.tabBarController presentViewController:loginNav animated:NO completion:^{
        
    }];
    return YES;
}
-(void)addtabbarVC
{
    self.tabBarController = [[UITabBarController alloc]init];
    
    FriendsViewController *friend = [[FriendsViewController alloc]init];
    self.xmppCenter.chatDelegate = friend;
    UINavigationController* friendNav = [[UINavigationController alloc]initWithRootViewController:friend];
    
    GroupTableViewController *group = [[GroupTableViewController alloc]init];
    UINavigationController *groupNav = [[UINavigationController alloc]initWithRootViewController:group];
    
    self.tabBarController.viewControllers = @[friendNav,groupNav,groupNav,groupNav];
    
    UIView *view = [[self.tabBarController.view subviews]objectAtIndex:0];
    view.frame = [UIScreen mainScreen].bounds;
    CGRect frame = self.tabBarController.tabBar.frame;
    frame.origin.y = frame.origin.y+1;
    frame.size.height = frame.size.height -1;
    NSLog(@"tabbar:%f,%f",frame.origin.y,frame.size.height);
    self.tabBarController.tabBar.frame = frame;
    self.tabBarBtnContainer = [[UIView alloc]initWithFrame:self.tabBarController.tabBar.bounds];
    self.tabBarBtnContainer.backgroundColor = [UIColor whiteColor];
    [self.tabBarController.tabBar addSubview:self.tabBarBtnContainer];
    //    self.tabBarController.tabBar.hidden = YES;
    NSArray * tabNameArray = @[@"我的好友",@"组群",@"查找好友",@"查找组群"];
    
    int width = [UIScreen mainScreen].bounds.size.width/tabNameArray.count;
    for (int i=0; i<tabNameArray.count; i++) {
        CGRect tempFrame = CGRectMake(width*i, 0, width, frame.size.height);
        [self addTabBarButton:tempFrame Normal:[NSString stringWithFormat:@"tabbar%d",i+1] selected:[NSString stringWithFormat:@"tabbar%d_s",i+1] tag:i+1];
        CGRect frame = tempFrame;
        frame.origin.y = frame.origin.y + 30;
        frame.size.height = 18;
        UILabel *label = [[UILabel alloc]initWithFrame:frame];
        label.tag = 11 + i;;
        label.text = tabNameArray[i];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        if (i==0) {
            label.textColor = [UIColor redColor];
        }
        else
        {
            label.textColor = [UIColor grayColor];
        }
        [self.tabBarBtnContainer addSubview:label];
    }
    self.tabBarController.preferredContentSize = [UIScreen mainScreen].bounds.size;
    self.tabBarBtn = (UIButton*)[self.tabBarBtnContainer viewWithTag:1];
    [self.tabBarBtn setSelected:YES];
    [self.tabBarController setSelectedIndex:0];
}
-(void)addTabBarButton:(CGRect)buttonFrame Normal:(NSString *)NormalImage selected:(NSString *)selectedImage tag:(int)buttonTag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = buttonFrame;
    btn.tag=buttonTag;
    [btn setBackgroundImage:[UIImage imageNamed:@"tabbar1_s"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageNamed:@"tabbar2_s"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tabBarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBarBtnContainer addSubview:btn];
}
-(void)tabBarBtnAction:(UIButton*)sender
{
    if (self.tabBarBtn.tag==sender.tag) {
        return;
    }
    self.tabBarBtn = sender;
    [self.tabBarBtn setSelected:YES];
    for (int i=0; i<4; i++) {
        UIButton * view = (UIButton*)[self.tabBarBtnContainer viewWithTag:i+1];
        if (self.tabBarBtn.tag!=view.tag) {
            [view setSelected:NO];
        }
        UILabel *label = (UILabel *)[self.tabBarBtnContainer viewWithTag:11+i];
        if (self.tabBarBtn.tag!=label.tag-10) {
            label.textColor = [UIColor grayColor];
        }
        else
        {
            label.textColor = [UIColor redColor];
        }
    }
    [self.tabBarController setSelectedIndex:self.tabBarBtn.tag-1];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
