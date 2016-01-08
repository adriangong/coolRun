//
//  AGLastMsgTableViewController.h
//  CoolRun
//
//  Created by adrian gong on 16/1/8.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface AGLastMsgTableViewController : UITableViewController
/** 要聊天对象的标识 */
@property (strong,nonatomic) XMPPJID *friendJid;//带用户名，带域名的
@end
