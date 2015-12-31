//
//  AGUserInfo.h
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface AGUserInfo : NSObject
singleton_interface(AGUserInfo)
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userPasswd;

@end
