//
//  ChartCellFrame.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartMessage.h"
@interface ChartCellFrame : NSObject

@property (nonatomic,assign) CGRect iconRect;
@property (nonatomic,assign) CGRect chartViewRect;
@property (nonatomic,strong) ChartMessage *chartMessage;
@property (nonatomic, assign) CGFloat cellHeight; //cell高度

@end
