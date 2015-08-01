//
//  RegisterViewController.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-30.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *serverID;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;


@end
