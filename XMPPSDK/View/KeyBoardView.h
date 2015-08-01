//
//  KeyBoardView.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KeyBoardView;

@protocol KeyBoardViewDelegate <NSObject>
@optional
-(void)KeyBoardView:(KeyBoardView *)keyBoardView textViewReturn:(UITextView *)textView;
@optional
-(void)KeyBoardView:(KeyBoardView *)keyBoardView textViewBegin:(UITextView *)textView;
@optional
-(void)beginRecord;
@optional
-(void)finishRecord;

@end
@interface KeyBoardView : UIView

@property (nonatomic,assign) id<KeyBoardViewDelegate>delegate;

@end
