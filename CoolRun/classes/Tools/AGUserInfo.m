//
//  AGUserInfo.m
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import "AGUserInfo.h"

@implementation AGUserInfo
singleton_implementation(AGUserInfo)

- (NSString *)jidStr{
    return [NSString stringWithFormat:@"%@@%@",self.userName,AGXMPPDOMAIN];
}

@end
