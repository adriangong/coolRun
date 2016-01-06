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

/** 定义枚举 代表登录状态 */
typedef enum{
    AGXMPPResultTypeLoginSuccess = 0,
    AGXMPPResultTypeLoginFaild,
    AGXMPPResultTypeNetError,
    AGXMPPResultTypeRegistSuccess,
    AGXMPPResultTypeRegistFaild,
}AGXMPPResultType;
/** 定义枚举 代表注册状态*/

/** 定义BLOCK */
typedef void(^AGResultBlock)(AGXMPPResultType type);

//谁要得到我的状态，谁就传一个block进来 ***
/** 测试BLOCK*/
typedef int(^AGTestBlock)(NSString *str);

@interface AGXMPPTool : NSObject
singleton_interface(AGXMPPTool)

/** 负责和服务器进行交互的主要对象 */
@property (strong,nonatomic) XMPPStream *xmppStream;

/** 增加电子名片模块 和 头像模块 */
@property (strong,nonatomic) XMPPvCardTempModule *xmppvCard;
@property (strong,nonatomic) XMPPvCardAvatarModule *xmppvCardAvarta;

/** 对电子名片数据管理的对象 */
@property (strong,nonatomic) XMPPvCardCoreDataStorage *xmppvCardCoreDataStorage;

/** 增加好友列表模块 和 对应的存储 */
@property (nonatomic,strong)XMPPRoster *xmppRoster;
@property (nonatomic,strong)XMPPRosterCoreDataStorage *xmppRosterStore;

/** 设置XMPP流 */
- (void)setXmpp;

/** 连接到服务器*/
- (void)connectHost;

/** 连接成功 发送密码*/
- (void)sendPasswdToHost;

/** 授权成功后 发送在线消息*/
- (void)sendOnLine;

- (void)userLogin:(AGResultBlock)block;
/** 用户注册调用的方法 */
- (void)userRegist:(AGResultBlock)block;

@end
