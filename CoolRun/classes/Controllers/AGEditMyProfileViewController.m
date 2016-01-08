//
//  AGEditMyProfileViewController.m
//  CoolRun
//
//  Created by adrian gong on 16/1/6.
//  Copyright © 2016年 Adrian Gong. All rights reserved.
//

#import "AGEditMyProfileViewController.h"
#import "AGXMPPTool.h"
#import "AGSmallTools.h"

@interface AGEditMyProfileViewController()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)clickBtn:(id)sender;

@end

@implementation AGEditMyProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.myProfile.photo) {
        self.headImageView.image = [UIImage imageWithData:self.myProfile.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"微信"];
    }
    //
    [AGSmallTools setRoundImage:self.headImageView];
    self.nicknameTextField.text = self.myProfile.nickname;
    self.emailTextField.text = self.myProfile.mailer;
    
    /** 打开用户交互 */
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageTap)]];
    
}


- (void)headImageTap{
    NSLog(@"tap image");
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"使用相机拍摄" otherButtonTitles:@"从相册选择", nil];
    [sheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2 ) {
        MYLog(@"取消");
    }else if(buttonIndex == 1){
        MYLog(@"相册");
        //相机和相册是一个控制器
        UIImagePickerController *pc = [UIImagePickerController new];
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pc.delegate = self;
        [self presentViewController:pc animated:YES completion:nil];
        
    }else{
        MYLog(@"相机");
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return;
        }
        //相机和相册是一个控制器
        UIImagePickerController *pc = [UIImagePickerController new];
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerSourceTypeCamera;
        pc.delegate = self;
        [self presentViewController:pc animated:YES completion:nil];
        
    }
}

/** 选择图片 */
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo{
//    
//}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headImageView.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBtn:(id)sender {
    self.myProfile.nickname = self.nicknameTextField.text;
    self.myProfile.mailer = self.emailTextField.text;
    UIImage *image = self.headImageView.image;
    self.myProfile.photo = UIImagePNGRepresentation(image);
    //
    [[AGXMPPTool sharedAGXMPPTool].xmppvCard updateMyvCardTemp:self.myProfile];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
