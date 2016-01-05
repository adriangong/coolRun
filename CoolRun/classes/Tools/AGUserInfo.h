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
/** 登陆的用户名和密码 */
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userPasswd;
/** 注册的用户名和密码 */
@property (nonatomic,copy) NSString *userRegisterName;
@property (nonatomic,copy) NSString *userRegisterPasswd;
/** 为了区分 登陆还是注册 */
@property (nonatomic,assign,getter=isRegistType) BOOL registType;
@end
