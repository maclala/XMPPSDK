//
//  SearchFriendViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-22.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "AppDelegate.h"
@interface SearchFriendViewController ()

@end

@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.addBtn addTarget:self action:@selector(addBuddy) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)addBuddy
{
    AppDelegate*app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.xmppCenter addBuddy:self.friendID.text];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
