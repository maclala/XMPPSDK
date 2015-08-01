//
//  LoginViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _name.text = @"dhw@localhost";
//    _password.text = @"dhw";
//    _serverID.text =  @"123.57.51.210";
//    _name.text = @"dhw2@mi.local";
//    _password.text = @"123456";
//    _serverID.text =  @"192.168.2.104";
    _name.text = @"lgl@123.57.51.210";
    _password.text = @"111111";
    _serverID.text =  @"123.57.51.210";
    
    [self.loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerBtn addTarget:self action:@selector(registerBtnAction) forControlEvents:UIControlEventTouchUpInside];
}
- (void)login:(id)sender {
    [self appDelegate].xmppCenter.loginDelegate = self;
    [[self appDelegate].xmppCenter connectName:_name.text Password:_password.text ServerID:_serverID.text];
    
}
-(void)LoginSuccess:(BOOL)loginState
{
    if (loginState) {
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
-(void)registerBtnAction
{
    RegisterViewController *registerVC=[[RegisterViewController alloc]init];
    [self.navigationController pushViewController:registerVC animated:YES];
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
