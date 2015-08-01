//
//  ChartContentView.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChartContentView,ChartMessage;
@protocol ChartContentViewDelegate <NSObject>

-(void)chartContentViewLongPress:(ChartContentView *)chartView content:(NSString *)content;
-(void)chartContentViewTapPress:(ChartContentView *)chartView content:(NSString *)content;

@end
@interface ChartContentView : UIView
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) ChartMessage *chartMessage;
@property (nonatomic,assign) id <ChartContentViewDelegate> delegate;

@end
