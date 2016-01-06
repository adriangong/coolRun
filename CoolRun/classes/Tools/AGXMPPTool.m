//
//  AGXMPPTool.m
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import "AGXMPPTool.h"
#import "AGUserInfo.h"

#import "DDLog.h"
#import "DDTTYLogger.h"


@interface AGXMPPTool() <XMPPStreamDelegate>
{
    //为了保持住属性，创建变量
    AGResultBlock _resultblock;

    //_resultblock可以被赋值
    //_resultblock = ^(AGXMPPResultType type) {
    //
    //};
}

@end

@implementation AGXMPPTool
singleton_implementation(AGXMPPTool)

/** 设置XMPP流 */
- (void)setXmpp{
    if (self.xmppStream) return;
    
    self.xmppStream = [[XMPPStream alloc] init];
    
    /** 设置代理 */
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //开启底层发送数据的日志 xml文件
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    /** 给 电子名片模块 和 头像模块 赋值 */
    self.xmppvCardCoreDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardCoreDataStorage];
    self.xmppvCardAvarta = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCard];
    
    /** 激活名片 */
    [self.xmppvCard activate:self.xmppStream];
    [self.xmppvCardAvarta activate:self.xmppStream];
    
    /** 给 好友列表模块对象 和 存储对象 赋值 */
    self.xmppRosterStore = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStore];
    
    /** 激活好友列表 */
    [self.xmppRoster activate:self.xmppStream];
    
}

/** 连接到服务器 */
- (void)connectHost{
    [self setXmpp];
    /** 给xmppstream 做一些属性的赋值 */
    self.xmppStream.hostName = AGXMPPHOSTNAME;
    self.xmppStream.hostPort = AGXMPPPORT;
    /** 构建一个JID 根据登录名还是注册名 */
    NSString *uname = nil;
    if ([[AGUserInfo sharedAGUserInfo] isRegistType]) {
        uname = [AGUserInfo sharedAGUserInfo].userRegisterName;
        
    }else{
        uname = [AGUserInfo sharedAGUserInfo].userName;
    }
    XMPPJID *myJid = [XMPPJID jidWithUser:uname domain:AGXMPPDOMAIN resource:@"iphone5s"];
    self.xmppStream.myJID = myJid;
    /** 连接服务器 */
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

/** 连接成功 发送密码 */
- (void)sendPasswdToHost{
    NSString *pwd = nil;
    NSError *error = nil;
    if ([AGUserInfo sharedAGUserInfo].isRegistType) {
        pwd = [AGUserInfo sharedAGUserInfo].userRegisterPasswd;
        /** 用密码进行注册 */
        [self.xmppStream registerWithPassword:pwd error:&error];
    }else{
        pwd = [AGUserInfo sharedAGUserInfo].userPasswd;
        /** 用密码进行授权 */
        [self.xmppStream authenticateWithPassword:pwd error:&error];
    }
    if (error) {
        MYLog(@"%@",error);
    }
}

/** 授权成功后 发送在线消息 */
- (void)sendOnLine{
    /** presence默认在线 */
    XMPPPresence *presence = [XMPPPresence presence];
    /** 用流对象发出去 */
    [self.xmppStream sendElement:presence];
}

- (void)userLogin:(AGResultBlock)block{
    _resultblock = block;
    /** 无论之前有没有登录 都断开一次 */
    [self.xmppStream disconnect];
    /** 调用连接 */
    [self connectHost];
}

- (void)userRegist:(AGResultBlock)block{
    _resultblock = block;
    [self.xmppStream disconnect];
    [self connectHost];
}

//////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
//////////////////////////////////////////////////////////////////////////
/** 注册成功还是失败 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    if (_resultblock) {
        _resultblock(AGXMPPResultTypeRegistSuccess);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    if (_resultblock && error) {
        _resultblock(AGXMPPResultTypeRegistFaild);
    }
}

/** 连接服务器成功 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    /** 发送密码 */
    [self sendPasswdToHost];
}

/** 连接服务器失败 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if (error && _resultblock) {
        _resultblock(AGXMPPResultTypeNetError);
        //void(^_resultblock)(AGXMPPResultType type)
        MYLog(@"%@",error);
    }
}

/** 授权成功 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    _resultblock(AGXMPPResultTypeLoginSuccess);
    /** 发送在线消息 */
    [self sendOnLine];
}

/** 授权失败 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    MYLog(@"%@",error);
    if (error && _resultblock) {
        _resultblock(AGXMPPResultTypeLoginFaild);
    }
}



@end









