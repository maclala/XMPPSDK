//
//  UIImage+StrethImage.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-21.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "UIImage+StrethImage.h"

@implementation UIImage(StrethImage)
+(id)strethImageWith:(NSString *)imageName
{
    UIImage *image=[UIImage imageNamed:imageName];
    image=[image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    return image;
}
@end
