//
//  AGXMPPTool.h
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
@interface AGXMPPTool : NSObject
singleton_interface(AGXMPPTool)
/** 负责和服务器进行交互的主要对象 */
@property (strong,nonatomic) XMPPStream *xmppStream;

/** 设置XMPP流 */
- (void)setXmpp;

/** 连接到服务器*/
- (void)connectHost;

/** 连接成功 发送密码*/
- (void)sendPasswdToHost;

/** 授权成功后 发送在线消息*/
- (void)sendOnLine;

- (void)userLogin;

@end
