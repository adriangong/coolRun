//
//  AGSmallTools.m
//  CoolRun
//
//  Created by adrian gong on 16/1/6.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGSmallTools.h"

@implementation AGSmallTools
+ (void)setRoundImage:(UIImageView *)imageView{
    //
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = imageView.bounds.size.width * 0.5;
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
}
@end
