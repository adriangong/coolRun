//
//  AGWechatLoginViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/5.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGWechatLoginViewController.h"

#define BAIDUURL @"https://baidu.com"

@interface AGWechatLoginViewController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AGWechatLoginViewController

- (IBAction)clickBackBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:BAIDUURL]]];
}

@end