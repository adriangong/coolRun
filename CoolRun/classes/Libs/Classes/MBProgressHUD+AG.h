//
//  MBProgressHUD+AG.h
//  CoolRun
//
//  Created by adrian gong on 16/1/5.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (AG)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
