//
//  CreateGroupViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "AppDelegate.h"
#import "RoomDelegate.h"
@interface CreateGroupViewController ()<RoomDelegate>

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.createBtn addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
}
-(void)createGroup
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.xmppCenter.roomDelegate = self;
    [app.xmppCenter createForeverRoom:self.groupName.text NickName:self.nickName.text];
}
-(void)roomCreateSuccess:(BOOL)isCreate
{
    if (isCreate)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
