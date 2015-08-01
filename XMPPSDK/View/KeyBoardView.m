//
//  KeyBoardView.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "KeyBoardView.h"
#import "UIImage+StrethImage.h"
@interface KeyBoardView()<UITextViewDelegate>

@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIButton *voiceBtn;
@property (nonatomic,strong) UIButton *imageBtn;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UIButton *speakBtn;
@property (nonatomic,strong) UITextView *textView;

@end
@implementation KeyBoardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSubView];
    }
    return self;
}
-(UIButton *)buttonWith:(NSString *)noraml hightLight:(NSString *)hightLight action:(SEL)action
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:noraml] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void)initialSubView
{
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.backImageView=[[UIImageView alloc]initWithFrame:self.bounds];
    self.backImageView.image=[UIImage strethImageWith:@"toolbar_bottom_bar.png"];
    [self addSubview:self.backImageView];
    
    self.voiceBtn=[self buttonWith:@"chat_bottom_voice_nor.png" hightLight:@"chat_bottom_voice_press.png" action:@selector(voiceBtnPress:)];
    [self.voiceBtn setFrame:CGRectMake(0,0, 33, 33)];
    [self.voiceBtn setCenter:CGPointMake(30, self.frame.size.height*0.5)];
    [self addSubview:self.voiceBtn];
    
    self.textView=[[UITextView alloc]initWithFrame:CGRectMake(0, 0, screenWidth-160, self.frame.size.height*0.8)];
    self.textView.returnKeyType=UIReturnKeySend;
    self.textView.center=CGPointMake(screenWidth/2-30, self.frame.size.height*0.5);
    self.textView.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
//    self.textView.placeholder=@"请输入...";
//    self.textView.background=[UIImage imageNamed:@"chat_bottom_textfield.png"];
    self.textView.delegate=self;
    [self addSubview:self.textView];
    
    self.imageBtn=[self buttonWith:@"chat_bottom_smile_nor.png" hightLight:@"chat_bottom_smile_press.png" action:@selector(imageBtnPress:)];
    [self.imageBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.imageBtn setCenter:CGPointMake(screenWidth - 33 - 40, self.frame.size.height*0.5)];
    [self addSubview:self.imageBtn];
    
    self.addBtn=[self buttonWith:@"chat_bottom_up_nor.png" hightLight:@"chat_bottom_up_press.png" action:@selector(addBtnPress:)];
    [self.addBtn setFrame:CGRectMake(0, 0, 33, 33)];
    [self.addBtn setCenter:CGPointMake(screenWidth - 33, self.frame.size.height*0.5)];
    [self addSubview:self.addBtn];
    
    self.speakBtn=[self buttonWith:nil hightLight:nil action:@selector(speakBtnPress:)];
    [self.speakBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.speakBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakBtn addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.speakBtn setTitleColor:[UIColor redColor] forState:(UIControlState)UIControlEventTouchDown];
    [self.speakBtn setBackgroundColor:[UIColor whiteColor]];
    [self.speakBtn setFrame:self.textView.frame];
    self.speakBtn.hidden=YES;
    [self addSubview:self.speakBtn];

}
-(void)touchDown:(UIButton *)voice
{
    //开始录音
    
    if([self.delegate respondsToSelector:@selector(beginRecord)]){
        
        [self.delegate beginRecord];
    }
    NSLog(@"开始录音");
}
-(void)speakBtnPress:(UIButton *)voice
{
    //结束录音
    
    if([self.delegate respondsToSelector:@selector(finishRecord)]){
        
        [self.delegate finishRecord];
    }
    NSLog(@"结束录音");
}
-(void)voiceBtnPress:(UIButton *)voice
{
    NSString *normal,*hightLight;
    if(self.speakBtn.hidden==YES){
        [self.textView resignFirstResponder];
        self.speakBtn.hidden=NO;
        self.textView.hidden=YES;
        normal=@"chat_bottom_keyboard_nor.png";
        hightLight=@"chat_bottom_keyboard_press.png";
        
        
    }else{
        [self.textView becomeFirstResponder];
        self.speakBtn.hidden=YES;
        self.textView.hidden=NO;
        normal=@"chat_bottom_voice_nor.png";
        hightLight=@"chat_bottom_voice_press.png";
        
    }
    [voice setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [voice setImage:[UIImage imageNamed:hightLight] forState:UIControlStateHighlighted];
}
-(void)imageBtnPress:(UIButton *)image
{
    
    
}
-(void)addBtnPress:(UIButton *)image
{
    
    
}
#pragma mark textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([self.delegate respondsToSelector:@selector(KeyBoardView:textViewBegin:)]){
        
        [self.delegate KeyBoardView:self textViewBegin:textView];
    }
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if([self.delegate respondsToSelector:@selector(KeyBoardView:textViewReturn:)]){
            
            [self.delegate KeyBoardView:self textViewReturn:textView];
        }
        return NO;
    }
    return YES;
}
@end
