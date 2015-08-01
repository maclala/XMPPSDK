//
//  LoginDelegate.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//


@protocol LoginDelegate <NSObject>
@optional
-(void)RegisterSuccess:(BOOL)registerState;
@optional
-(void)LoginSuccess:(BOOL)loginState;

@end