//
//  AGLoginViewController.m
//  CoolRun
//
//  Created by adrian gong on 15/12/31.
//  Copyright © 2015年 Adrian Gong. All rights reserved.
//

#import "AGLoginViewController.h"
#import "AGUserInfo.h"
#import "AGXMPPTool.h"
#import "MBProgressHUD+AG.h"

@interface AGLoginViewController ()<MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UILabel *webIndicatorLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchS;

@end

@implementation AGLoginViewController
- (IBAction)clickLogin:(id)sender {
    MYLog(@"click login");
    [AGUserInfo sharedAGUserInfo].registType = NO;
    AGUserInfo *userInfo = [AGUserInfo sharedAGUserInfo];
    userInfo.userName = self.nameTextField.text;
    userInfo.userPasswd = self.pwdTextField.text;
    if ([userInfo.userName isEqualToString:@""] || [userInfo.userPasswd isEqualToString:@""]) {
        [MBProgressHUD showError:@"用户名密码不能为空"];
        return;
    }
    /** 点击登录按钮 调用工具类的登录方法 */
    //下面这句是为了调用self方法 并且 防止内存泄露
    __weak typeof (self) vc = self;
    //通过设置断点调试，发现会先执行userLogin里面的内容，然后再执行block括号里面的内容
    [[AGXMPPTool sharedAGXMPPTool] userLogin:^(AGXMPPResultType type) {
        //外面要拿里面的状态
        //什么状态做什么事
        //在block里面用self有风险，会出现“循环引用”问题，这是一个非常严重的问题，内存泄露。
        //[self handleLoginResultType:type];
        [vc handleLoginResultType:type];
    }];
    //[AGXMPPTool sharedAGXMPPTool] userLogin:<#^(AGXMPPResultType type)block#>
}

/** 处理登录的返回状态 */
- (void)handleLoginResultType:(AGXMPPResultType) type{
    switch (type) {
        case AGXMPPResultTypeLoginSuccess:{
            MYLog(@"登录成功");
            //切换到主界面
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                //第二个参数，传nil就代表mainBundle
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
            //跳转界面以后要销毁登录界面
            MYLog(@"abcd!@#$ abcd!@#$");
        }
            break;
        case AGXMPPResultTypeLoginFaild:{
            MYLog(@"登录失败");
        }
            break;
        case AGXMPPResultTypeNetError:{
            MYLog(@"网络错误");
        }
            break;
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
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nameTextField.leftView = leftN;
    
    
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc] initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 55, 40);
    leftP.contentMode = UIViewContentModeCenter;
    self.pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    self.pwdTextField.leftView = leftP;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 证明这个控制器释放了 */
- (void)dealloc{
    MYLog(@"%@ 销毁了",self);
}

- (IBAction)switchChangeValue:(id)sender {
    if ([self.switchS isOn]) {
        NSLog(@"1");
        self.webIndicatorLabel.text = @"外网";
        //外网服务器
//        connectionURL =@"http:124.207.192.18:8080/allRunServerNew/register.jsp";
//        agxmppDOMAIM = @"tarena.com";
//        agxmppHOSTNAME =@"124.207.192.18";
        
    }else  {
        self.webIndicatorLabel.text = @"内网";
        NSLog(@"0");
        //内网服务器
//        connectionURL =@"http:172.16.7.195:8080/allRunServer/register.jsp";
//        agxmppDOMAIM = @"tarena.com";
//        agxmppHOSTNAME =@"172.16.7.195";
        
    }
    [self.view layoutIfNeeded];
}

@end
