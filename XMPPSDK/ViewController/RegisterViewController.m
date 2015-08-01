//
//  RegisterViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-30.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "LoginDelegate.h"
@interface RegisterViewController ()<LoginDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _name.text = @"dhw2@mi.local";
    _password.text = @"123456";
    _serverID.text =  @"192.168.2.104";
    //    _name.text = @"dhw@123.57.51.210";
    //    _password.text = @"123456";
    //    _serverID.text =  @"123.57.51.210";
    
    [self.registerBtn addTarget:self action:@selector(registerBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)registerBtn:(id)sender {
    [self appDelegate].xmppCenter.loginDelegate = self;
    [[self appDelegate].xmppCenter registerName:_name.text Password:_password.text ServerID:_serverID.text];
    
}
-(void)RegisterSuccess:(BOOL)registerState
{
    if (registerState) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.name.text forKey:NAME];
            [defaults setObject:self.password.text forKey:PASSWORD];
            [defaults setObject:self.serverID.text forKey:SERVERID];
            //保存
            [defaults synchronize];
        }];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"shibaile" message:@"shibai" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
    
}
//取得当前程序的委托
-(AppDelegate *)appDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
