//
//  NSString+md5.m
//  CoolRun
//
//  Created by adrian gong on 16/1/4.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)
- (NSString *)md5Str{
    const char *myPasswd = [self UTF8String];
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        //把一个unsigned char变成两个16进制
        [md5String appendFormat:@"%02x",mdc[i]];
    }
    return [md5String copy];
}

//异或
- (NSString *)md5StrXor{
    const char *myPasswd = [self UTF8String];
    unsigned char mdc[16];
    CC_MD5(myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String = [NSMutableString string];
    //把第一个字符拿出来，把每个字符都变样
    [md5String appendFormat:@"%02x", mdc[0]];
    for (int i = 1; i < 16; i++) {
        //把一个unsigned char变成两个16进制
        [md5String appendFormat:@"%02x",mdc[i]^mdc[0]];
    }
    return [md5String copy];
}
@end
