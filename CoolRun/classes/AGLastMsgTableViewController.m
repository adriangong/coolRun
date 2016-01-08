//
//  AGRosterTableViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/6.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGLastMsgTableViewController.h"
#import "AGXMPPTool.h"
#import "AGUserInfo.h"
#import "AGSmallTools.h"
#import "AGRosterCell.h"
#import "AGChatViewController.h"
#import "AGChatCell.h"


@interface AGLastMsgTableViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic,copy) NSArray *msgs;
@property (nonatomic,strong) NSFetchedResultsController *fetchController;
@end

@implementation AGLastMsgTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //加载最新信息
    [self loadLatestMsgs];
}

- (void)loadLatestMsgs{
    /** 获取上下文  */
    NSManagedObjectContext *context =
    [[AGXMPPTool sharedAGXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    /** 关联实体 */
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    /** 设置过滤条件 */
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[AGUserInfo sharedAGUserInfo].jidStr];
    request.predicate = pre;
    // 排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:YES];
    request.sortDescriptors = @[sortDes];
    // 获取数据
    NSError *error = nil;
    self.fetchController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchController.delegate = self;
    [self.fetchController performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.fetchController.fetchedObjects[indexPath.row];
    
    AGChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCell2"];
    cell.msgLabel.text = msgObject.body;
    cell.nameLabel.text = msgObject.bareJidStr;
    
    NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:self.friendJid];
    if (data) {
        cell.headImageView.image = [UIImage imageWithData:data];
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"微信"];
    }
    cell.headImageView.image = [UIImage imageWithData:data];
    [AGSmallTools setRoundImage:cell.headImageView];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

//数据变化
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

//删除模式
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除好友
        [[AGXMPPTool sharedAGXMPPTool].xmppRoster removeUser:friend.jid];
    }
}

//跳转之前 设置参数
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id desVC = segue.destinationViewController;
    if ([desVC isKindOfClass: [AGChatViewController class]]) {
        AGChatViewController *des = (AGChatViewController *)desVC;
        des.friendJid = sender;
    }
}

//选中某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *f = self.fetchController.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"chatSegue" sender:f.jid];
    MYLog(@"%@",f.jid);
}
@end
