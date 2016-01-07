//
//  AGChatViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/7.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGChatViewController.h"
#import "AGXMPPTool.h"
#import "AGUserInfo.h"
#import "AGSmallTools.h"
#import "AGChatCell.h"

@interface AGChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;
/** 结果控制器 */
@property (strong,nonatomic) NSFetchedResultsController *fetchControl;
@end

@implementation AGChatViewController

/** 加载聊天记录的方法 */
- (void) loadMsg{
    //1、获取context
    NSManagedObjectContext *context = [[AGXMPPTool sharedAGXMPPTool].xmppMsgArchStore mainThreadManagedObjectContext];
    
    //2、关联entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    //3、设置条件
    //当前用户 + 好友
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ and bareJidStr = %@", [AGUserInfo sharedAGUserInfo].jidStr, [self.friendJid bare]];
    
    //4、设置排序，以聊天时间排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.predicate = pre;
    request.sortDescriptors = @[sortDes];
    
    //5、执行得到结果
    self.fetchControl = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    self.fetchControl.delegate = self;
    NSError *error = nil;
    [self.fetchControl performFetch:&error];
    if (error) {
        MYLog(@"%@",error);
    }
}

#pragma mark tableViewDelegate

- (void)initTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fetchControl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AGChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCell"];
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.fetchControl.fetchedObjects[indexPath.row];
    
    if ([msgObject isOutgoing]) {
        cell.msgLabel.text = msgObject.body;
        
        //NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:self.friendJid];
        NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:[XMPPJID jidWithString:[AGUserInfo sharedAGUserInfo].jidStr]];
        if (data) {
            cell.headImageView.image =
            [UIImage imageWithData:data];
        }else{
            cell.headImageView.image =
            [UIImage imageNamed:@"微信"];
        }
        cell.headImageView.image = [UIImage imageWithData:data];
        
        return cell;
    }else{
        NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:self.friendJid];
        if (data) {
            cell.headImageView.image =
            [UIImage imageWithData:data];
        }else{
            cell.headImageView.image =
            [UIImage imageNamed:@"微信"];
        }
        cell.headImageView.image = [UIImage imageWithData:data];
        
        return cell;
    }
    
}

//这两行不管用，不知道为什么
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
*/

//
- (IBAction)clickSendBtn:(id)sender {
     [self sendMsg];
}

//用回车发送消息
- (IBAction)sendTextMethod:(id)sender {
    [self sendMsg];
}

- (void)sendMsg{
    NSString *msgText = self.msgTextField.text;
    //组装一条消息
    //第一个参数：chat room 等等
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:msgText];
    
    //发送消息
    [[AGXMPPTool sharedAGXMPPTool].xmppStream sendElement:msg];
    self.msgTextField.text = @"";
}

/** 结果集发生变化 刷新 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTableView];
    
    //适应自动布局
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    [self loadMsg];
    
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
    
    
}

#pragma mark- 设置键盘弹出时候输入框的位置

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)openKeyboard:(NSNotification *)notification{
    //键盘的高度
    CGRect keyboardFrame = [notification.userInfo [UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //键盘动画时间
    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //键盘节奏，先快后慢什么的
    UIViewAnimationOptions options = [notification.userInfo [UIKeyboardAnimationCurveUserInfoKey] intValue];
    //改变键盘约束
    self.heightForBottom.constant = keyboardFrame.size.height + 44;
    //简单动画
    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)closeKeyboard:(NSNotification *)notification{
    //键盘动画时间
    NSTimeInterval durations = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //键盘节奏，先快后慢什么的
    UIViewAnimationOptions options = [notification.userInfo [UIKeyboardAnimationCurveUserInfoKey] intValue];
    //改变键盘约束
    self.heightForBottom.constant = 0;
    //简单动画
    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        ;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
