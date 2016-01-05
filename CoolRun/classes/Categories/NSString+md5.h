//
//  NSString+md5.h
//  CoolRun
//
//  Created by adrian gong on 16/1/4.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//  pmd5:

#import <Foundation/Foundation.h>

@interface NSString (md5)
- (NSString *)md5Str;
- (NSString *)md5StrXor;
//a^b^a是b， a^b^b是a
@end
