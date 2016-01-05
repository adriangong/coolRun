//
//  AGRegisterViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/4.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGRegisterViewController.h"
#import "AGUserInfo.h"
#import "AGXMPPTool.h"
#import "AFNetworking.h"
#import "NSString+md5.h"

@interface AGRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userRegisterNameField;
@property (weak, nonatomic) IBOutlet UITextField *userRegisterPwdField;

@end

@implementation AGRegisterViewController
- (IBAction)clickRegister:(id)sender {
    MYLog(@"点击注册");
    [AGUserInfo sharedAGUserInfo].registType = YES;
    AGUserInfo *userInfo = [AGUserInfo sharedAGUserInfo];
    userInfo.userRegisterName = self.userRegisterNameField.text;
    userInfo.userRegisterPasswd = self.userRegisterPwdField.text;
    /** 点击注册按钮 调用工具类的注册方法 */
    //下面这句是为了调用self方法 并且 防止内存泄露
    __weak typeof (self) vc = self;
    //通过设置断点调试，发现会先执行userLogin里面的内容，然后再执行block括号里面的内容
    [[AGXMPPTool sharedAGXMPPTool] userRegist:^(AGXMPPResultType type) {
        /** 处理注册的状态 */
        [vc handleRegistType:type];
    }];
    [self dismissModalViewControllerAnimated:YES];
}

/** 处理登录的返回状态 */
- (void)handleRegistType:(AGXMPPResultType)type{
    switch (type) {
        case AGXMPPResultTypeRegistSuccess:{
            MYLog(@"XMPP服务端注册成功");
            /** 发起向web服务端注册，产生web账号 */
            [self webRegister];
        }
            break;
        case AGXMPPResultTypeLoginFaild:{
            MYLog(@"注册失败");
        }
            break;
        case AGXMPPResultTypeNetError:{
            MYLog(@"注册网络错误");
        }
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftN = [[UIImageView alloc] initWithImage:imageN];
    leftN.frame = CGRectMake(0, 0, 55, 40);
    leftN.contentMode = UIViewContentModeCenter;
    self.userRegisterNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userRegisterNameField
    .leftView = leftN;
    
    
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc] initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 55, 40);
    leftP.contentMode = UIViewContentModeCenter;
    self.userRegisterPwdField.leftViewMode = UITextFieldViewModeAlways;
    self.userRegisterPwdField.leftView = leftP;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 用来产生web账号的注册方法 */
- (void)webRegister{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",AGXMPPHOSTNAME];
    
    //准备参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [AGUserInfo sharedAGUserInfo].userRegisterName;
    
    //e1eb3dd8a85bb84a5fb701b613ee69df
    
    parameters[@"md5password"] = [[AGUserInfo sharedAGUserInfo].userRegisterPasswd md5StrXor];
    parameters[@"nickname"] = @"";
    //parameters[@"gender"] = @"人妖";
    
    
    //头像在发请求的时候带过去
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //本地图片，如果是url可以用url那个方法
        UIImage *headImage = [UIImage imageNamed:@"sun.png"];
        //把图片转为二进制
        NSData *data = UIImagePNGRepresentation(headImage);
        /**
         *  第一个参数：data
         *  第二个参数：自定义的一个名字
         *  第三个参数：到服务器上的名称
         *  第四个参数：固定格式
         */
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //发送请求成功，但不一定是注册成功，可能没注册成功
        MYLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //发送请求失败，
        MYLog(@"%@",error);
    }];
}
@end
