//
//  AGRosterTableViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/6.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGRosterTableViewController.h"
#import "AGXMPPTool.h"
#import "AGUserInfo.h"
#import "AGSmallTools.h"
#import "AGRosterCell.h"
#import "AGChatViewController.h"

@interface AGRosterTableViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic,copy) NSArray *friends;
@property (nonatomic,strong) NSFetchedResultsController *fetchController;
@end

@implementation AGRosterTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //加载好友
    //[self loadFriends1];
    [self loadFriends2];
}

- (void)loadFriends2{
    /** 获取上下文  */
    NSManagedObjectContext *context =
    [[AGXMPPTool sharedAGXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    /** 关联实体 */
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    /** 设置过滤条件 */
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[AGUserInfo sharedAGUserInfo].jidStr];
    request.predicate = pre;
    // 排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
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


- (void)loadFriends1{
    /** 获取上下文  */
    NSManagedObjectContext *context =
    [[AGXMPPTool sharedAGXMPPTool].xmppRosterStore mainThreadManagedObjectContext];
    /** 关联实体 */
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    /** 设置过滤条件 */
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",[AGUserInfo sharedAGUserInfo].jidStr];
    request.predicate = pre;
    // 排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sortDes];
    // 获取数据
    NSError *error = nil;
        self.friends = [context executeFetchRequest:request error:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.friends.count;
    return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AGRosterCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"friendCell"];
//    XMPPUserCoreDataStorageObject *friend = self.friends[indexPath.row];
    XMPPUserCoreDataStorageObject *friend = self.fetchController.fetchedObjects[indexPath.row];
    NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:friend.jid];
    if (data) {
        cell.headImageView.image =
        [UIImage imageWithData:data];
    }else{
        cell.headImageView.image =
        [UIImage imageNamed:@"微信"];
    }
    [AGSmallTools setRoundImage:cell.headImageView];
    cell.nameLabel.text = friend.jidStr;
    switch ([friend.sectionNum intValue]) {
        case 0:
            cell.onLineLabel.text = @"在线";
            break;
        case 1:
            cell.onLineLabel.text = @"离开";
            break;
        case 2:
            cell.onLineLabel.text = @"离线";
        default:
            break;
    }
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
