//
//  AGMyProfileViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/5.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGMyProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "AGXMPPTool.h"
#import "AGUserInfo.h"
#import "AGEditMyProfileViewController.h"
#import "AGSmallTools.h"

@interface AGMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end


@implementation AGMyProfileViewController
- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /** XMPP */
    XMPPvCardTemp *vCardTemp = [AGXMPPTool sharedAGXMPPTool].xmppvCard.myvCardTemp;
    if (vCardTemp.photo) {
        self.headImageView.image = [UIImage imageWithData:vCardTemp.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"微信"];
    }
    [AGSmallTools setRoundImage:self.headImageView];
    
    self.nameLabel.text = [AGUserInfo sharedAGUserInfo].userName;
    self.nickNameLabel.text = vCardTemp.nickname;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    id destVC = segue.destinationViewController;
    
    if ([destVC isKindOfClass:[AGEditMyProfileViewController class]]) {
        AGEditMyProfileViewController *editVC = (AGEditMyProfileViewController *)destVC;
        editVC.myProfile = [AGXMPPTool sharedAGXMPPTool].xmppvCard.myvCardTemp;
    }
}



@end
