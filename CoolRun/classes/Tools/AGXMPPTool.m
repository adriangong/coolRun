//
//  AGXMPPTool.m
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import "AGXMPPTool.h"
#import "AGUserInfo.h"
@interface AGXMPPTool() <XMPPStreamDelegate>

@end

@implementation AGXMPPTool
singleton_implementation(AGXMPPTool)

/** 设置XMPP流 */
- (void)setXmpp{
    if (self.xmppStream) return;
    self.xmppStream = [[XMPPStream alloc] init];
    /** 设置代理 */
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

/** 连接到服务器 */
- (void)connectHost{
    [self setXmpp];
    /** 给xmppstream 做一些属性的赋值 */
    self.xmppStream.hostName = AGXMPPHOSTNAME;
    self.xmppStream.hostPort = AGXMPPPORT;
    /** 构建一个JID */
    XMPPJID *myJid = [XMPPJID jidWithUser:[AGUserInfo sharedAGUserInfo].userName domain:AGXMPPDOMAIN resource:@"iphone5s"];
    self.xmppStream.myJID = myJid;
    /** 连接服务器 */
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

/** 连接成功 发送密码 */
- (void)sendPasswdToHost{
    NSString *pwd = nil;
    NSError *error = nil;
    pwd = [AGUserInfo sharedAGUserInfo].userPasswd;
    [self.xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

/** 授权成功后 发送在线消息 */
- (void)sendOnLine{
    /** presence默认在线 */
    XMPPPresence *presence = [XMPPPresence presence];
    /** 用流对象发出去 */
    [self.xmppStream sendElement:presence];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
//////////////////////////////////////////////////////////////////////////

/** 连接服务器成功 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    /** 发送密码 */
    [self sendPasswdToHost];
}

/** 连接服务器失败 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if (error) {
        NSLog(@"%@",error);
    }
}

/** 授权成功 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    /** 发送在线消息 */
    [self sendOnLine];
}

/** 授权失败 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"%@",error);
}

-(void)userLogin{
    /** 无论之前有没有登录 都断开一次 */
    [self.xmppStream disconnect];
    /** 调用连接 */
    [self connectHost];
}

@end









