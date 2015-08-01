//
//  ChartCell.h
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartCellFrame.h"
@class ChartCell;
@protocol ChartCellDelegate <NSObject>

-(void)chartCell:(ChartCell *)chartCell tapContent:(NSString *)content;

@end
@interface ChartCell : UITableViewCell
@property (nonatomic,strong) ChartCellFrame *cellFrame;
@property (nonatomic,assign) id<ChartCellDelegate> delegate;
@end
