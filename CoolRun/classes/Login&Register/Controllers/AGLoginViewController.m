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

@interface AGLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;

@end

@implementation AGLoginViewController
- (IBAction)clickLogin:(id)sender {
    NSLog(@"click login");
    AGUserInfo *userInfo = [AGUserInfo sharedAGUserInfo];
    userInfo.userName = self.nameTextField.text;
    userInfo.userPasswd = self.pwdTextField.text;
    /** 点击登录按钮 调用工具类的登录方法 */
    [[AGXMPPTool sharedAGXMPPTool] userLogin];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
