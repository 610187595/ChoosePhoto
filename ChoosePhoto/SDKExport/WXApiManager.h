//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//
#define kWXAPP_ID @"wx3b797a944ddccb5e" //微信appid
#define kWXAPP_SECRET @"e85c1d2f420e107091694ed74bc61117"
#define qqAPPID @"1105772363"
/*
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
 */
#import <Foundation/Foundation.h>
#import "WXApi.h"
//#import "AFNetworking.h"
@protocol WXApiManagerDelegate <NSObject>

@optional

- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;
- (void)mangerDidSendAuthRespUserInfo:(NSMutableDictionary *)userInfo;
@end
//QQApiInterfaceDelegate
@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;
@property (strong,nonatomic)void (^block)(NSInteger index);
+ (instancetype)sharedManager;
-(void)weichatPay:(NSDictionary *)orderdict andBlock:(void(^)(NSInteger index))block;//如果后台签名使用这个方法  请求一个接口  接口需要什么 orderdict 传什么
- (void)weixinChooseActWithDict:(NSMutableDictionary *)dict andBlock:(void(^)(NSInteger index))block;//如果手机端签名使用这个方法  //dict 必传参数 subject 标题  price 价格单位分 orderNmuber 订单号 
- (void)wxshareTitleStr:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr;//微信分享文字
- (void)wxshareQuanTitle:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr;//微信分享链接
- (void)qqshareTitleStr:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr;
- (void)shareWeiChatText:(NSString *)title WithDescriPtion:(NSString *)description WithTexxt:(NSString *)text; //微信
- (void)shareWeiChatImage:(NSString *)title WithDescriPtion:(NSString *)description WithImage:(NSString *)imageUrl;//微信分享图片
@end
