//
//  ViewController.m
//  ChoosePhoto
//
//  Created by 薛泽军 on 2017/12/21.
//  Copyright © 2017年 薛泽军. All rights reserved.
//

#import "ViewController.h"
#import "JKImagePickerController.h"
#import "WXApiManager.h" //微信管理类
@interface ViewController ()<JKImagePickerControllerDelegate,WXApiManagerDelegate>
@property(nonatomic,strong) NSMutableArray *selectionPhotoArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)xiangceClick:(id)sender {
    [self upLoadUserImage];
}
- (void)upLoadUserImage
{
    JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.showsCancelButton = YES;//是否显示取消按钮
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.minimumNumberOfSelection = 1;//最少选取几张
    imagePickerController.maximumNumberOfSelection = 1;//最多选取几张照骗
    imagePickerController.selectedAssetArray = self.selectionPhotoArray;//已经选取的照片 如果不需要注释即可
    UINavigationController*navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];//给页面套一个导航 这个导航可以是你自定义的 在此修改
    [self presentViewController:navigationController animated:YES completion:NULL];
}
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
   
}
- (IBAction)weiChatLogin:(UIButton *)sender
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
    req.state = @"1";
    req.openID = @"e90ab5f01dc054db9798df28bf93395f";
    [WXApi sendAuthReq:req viewController:self delegate:[WXApiManager sharedManager]];
    WXApiManager *wm=[WXApiManager sharedManager];
    wm.delegate=self;
}
- (void)mangerDidSendAuthRespUserInfo:(NSMutableDictionary *)userInfo
{
    NSLog(@"userInfo~~~%@",userInfo);
}
- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
