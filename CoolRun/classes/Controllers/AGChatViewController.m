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

@interface AGChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;
/** 结果控制器 */
@property (strong,nonatomic) NSFetchedResultsController *fetchControl;

@property (strong,nonatomic) UIImage *sendImage;

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
    //适应自动布局
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
//    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //
    return self.fetchControl.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XMPPMessageArchiving_Message_CoreDataObject *msgObject = self.fetchControl.fetchedObjects[indexPath.row];
    
    if ([msgObject isOutgoing]) {
        AGChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMsgCell"];
        
        if ([msgObject.body hasPrefix:@"text:"]) {
            cell.msgLabel.text = [msgObject.body substringFromIndex:5];
            
        }else if([msgObject.body hasPrefix:@"image:"]){
            cell.msgLabel.text = @"";
            NSString *base64Str = [msgObject.body substringFromIndex:6];
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:0];
            cell.msgImageView.image = [UIImage imageWithData:imageData];
        }
        
        cell.nameLabel.text = @"me";
        
        //NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:self.friendJid];
        NSData *data = [[AGXMPPTool sharedAGXMPPTool].xmppvCardAvarta photoDataForJID:[XMPPJID jidWithString:[AGUserInfo sharedAGUserInfo].jidStr]];
        if (data) {
            cell.headImageView.image = [UIImage imageWithData:data];
        }else{
            cell.headImageView.image = [UIImage imageNamed:@"微信"];
        }
        cell.headImageView.image = [UIImage imageWithData:data];
        [AGSmallTools setRoundImage:cell.headImageView];
        
        return cell;
    }else{
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
     //弹出相册，保存一张图片
    //相机和相册是一个控制器
    UIImagePickerController *pc = [UIImagePickerController new];
    pc.allowsEditing = YES;
    pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pc.delegate = self;
    [self presentViewController:pc animated:YES completion:nil];
}

//选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //可以选择发送原图，一般的PNG缩略图，和JPEG缩略图
    
    //拿原图
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    MYLog(@"image length = %ld", UIImagePNGRepresentation(image).length);
    // 1228590
    
    /** 生成缩略图 */
    //先写100，100，后面再处理细节，等比例缩放
    UIImage *image2 = [self thumbnaiWithImage:image size:CGSizeMake(100, 100)];
    MYLog(@"image2 length = %ld", UIImagePNGRepresentation(image2).length);
    //28952
    
    //JPEG图片，第二个参数，1.0是最高的
    NSData *data = UIImageJPEGRepresentation(image2, 0.05);
    MYLog(@"image3 length = %ld", data.length);
    
    [self sendImage:data];
    //self.sendImage;
    //__weak typeof (self) vc = self;
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    
}
/** 生成缩略图 */
- (UIImage *)thumbnaiWithImage:(UIImage *)image size:(CGSize)size{
    UIImage *img = nil;
    if (image == nil) {
        img = nil;
    }else{
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return img;
}

/** 发送图片 */
- (void)sendImage:(NSData *)data{
    //把图片变成文本,用base64编码
    // 3个8位 -> 4个6位
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    //组装消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //一个小协议，
    NSString *dataStr = [NSString stringWithFormat:@"image:%@",base64Str];
    
    [msg addBody:dataStr];
    
    //发送消息
    [[AGXMPPTool sharedAGXMPPTool].xmppStream sendElement:msg];
    
}

//用回车发送消息
- (IBAction)sendTextMethod:(id)sender {
    [self sendMsg];
}

//发送消息
- (void)sendMsg{
    NSString *msgText = self.msgTextField.text;
    //组装一条消息
    //第一个参数：chat room 等等
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    //自定义简单的数据标准，为了区分 消息 是图片还是文字，各种在前面加个字的符号，"image:", "text:"
    NSString *dataStr = [NSString stringWithFormat:@"text:%@",msgText];
    [msg addBody:dataStr];
    
    //发送消息
    [[AGXMPPTool sharedAGXMPPTool].xmppStream sendElement:msg];
    
    //把输入清零
    self.msgTextField.text = @"";
}

/** 结果集发生变化 刷新 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
    [self msgDisplayLastRow];
    
    
    //[self.tableView reloadData];
}

/** tableView显示最下面的信息 */
- (void)msgDisplayLastRow{
    NSInteger n = self.fetchControl.fetchedObjects.count - 1;
    if (n < 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:n inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initTableView];
    
    [self loadMsg];
    
    [self msgDisplayLastRow];
    
//    [self.tableView reloadData];
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
    self.heightForBottom.constant = keyboardFrame.size.height;//这里可以添加自己的view
    //简单动画
    __weak typeof (self) vc = self;
    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
        [vc.tableView layoutIfNeeded];
        [vc msgDisplayLastRow];
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
    __weak typeof (self) vc = self;
    [UIImageView animateWithDuration:durations delay:0 options:options animations:^{
        [vc.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.msgTextField resignFirstResponder];
    MYLog(@"选了第%ld行",(long)indexPath.row);
    MYLog(@"%@",self.fetchControl.fetchedObjects[indexPath.row]);
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
