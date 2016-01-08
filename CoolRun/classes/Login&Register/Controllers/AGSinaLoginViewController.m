//
//  SinaLoginViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/5.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGSinaLoginViewController.h"
#import "AFNetworking.h"
#import "AGUserInfo.h"
#import "AGXMPPTool.h"
#import "NSString+md5.h"

#define APPKEY @"2075708624"
#define REDIRECT_URI @"http://www.tedu.cn"
#define APPSECRET @"36a3d3dec55af644cd94a316fdd8bfd8"

#define SINAURL @"https://api.weibo.com/oauth2/authorize?client_id=1220872528&redirect_uri=http://www.example.com/response&response_type=code"
#define BAIDUURL @"https://baidu.com"

@interface AGSinaLoginViewController()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AGSinaLoginViewController
- (IBAction)clickBackBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SINAURL]]];
    NSString *str = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI];
    self.webView.delegate = self;
    NSURL *url = [NSURL URLWithString:str];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    MYLog(@"%@",request.URL.absoluteString);
    NSString *urlPath = request.URL.absoluteString;
    /** 把urlPath ?code= 后面的内容截取*/
    NSRange range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@/?code=",REDIRECT_URI]];
    NSString *code = nil;
    if (range.length > 0) {
        code = [urlPath substringFromIndex:range.length];
        /** 使用code 换取access_token */
        //可以做很多事情，比如说头像，姓名，等等，还能获取微博，还能发微博等等，不过高级功能要交钱
        [self accessTokenWithCode:code];
        return NO;
    }
    return YES;
}

- (void) accessTokenWithCode:(NSString *)code{
    /** 导入AFN 发请求， */
    NSString *str = @"https://api.weibo.com/oauth2/access_token";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"client_id"] = APPKEY;
    dic[@"client_secret"] = APPSECRET;
    dic[@"grant_type"] = @"authorization_code";
    dic[@"code"] = code;
    dic[@"redirect_uri"] = REDIRECT_URI;
    [manager POST:str parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
        /*//<
         "access_token" = "2.00H8oG1G3d9TQC7ddc334884tPCHqC";
         "expires_in" = 132087;
         "remind_in" = 132087;
         uid = 5793947561;
         */
        /** 拿到信息后，把uid做用户名，把access_toke用m5d加密，做密码 */
        [AGUserInfo sharedAGUserInfo].userRegisterName = responseObject[@"uid"];
        [AGUserInfo sharedAGUserInfo].userRegisterPasswd = responseObject[@"access_token"];
        [AGUserInfo sharedAGUserInfo].registType = YES;
        
        __weak typeof (self) vc = self;
        [[AGXMPPTool sharedAGXMPPTool] userRegist:^(AGXMPPResultType type) {
            //处理
            [vc handleRegisterResultType:type];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MYLog(@"%@",error);
    }];
    
}

/** 处理注册的逻辑 */
- (void) handleRegisterResultType:(AGXMPPResultType)type{
    switch (type) {
        case AGXMPPResultTypeRegistSuccess:
            /** XMPP登陆成功后 继续注册web */
            [self webRegister];
        case AGXMPPResultTypeRegistFaild:{
            /** 无论成功失败都登陆上去 */
            //
            [AGUserInfo sharedAGUserInfo].userName =  [AGUserInfo sharedAGUserInfo].userRegisterName;
            [AGUserInfo sharedAGUserInfo].userPasswd = [AGUserInfo sharedAGUserInfo].userRegisterPasswd;
            [AGUserInfo sharedAGUserInfo].registType = NO;
            //
            [[AGXMPPTool sharedAGXMPPTool]userLogin:^(AGXMPPResultType type) {
                [self handleLoginResultType:type];
            }];
        }
            break;
        case AGXMPPResultTypeNetError:{
            MYLog(@"sina register net error");
        }
            break;
        default:
            break;
    }
}

/** 处理登录的返回 */
- (void)handleLoginResultType:(AGXMPPResultType)type{
    switch (type) {
        case AGXMPPResultTypeLoginSuccess:{
            //切换到主界面
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //第二个参数，传nil就代表mainBundle
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
            //跳转界面以后要销毁登录界面
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

- (void)webRegister{
    MYLog(@"webRegister");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *url = CONNECTURL;
    //[NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",AGXMPPHOSTNAME];
    
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
