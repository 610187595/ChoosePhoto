//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

//开户邮件中的（公众账号APPID或者应用APPID）
#define WX_AppID @"wx39e849d9f55d4dc6"

//安全校验码（MD5）密钥，商户平台登录账户和密码登录http://pay.weixin.qq.com 平台设置的“API密钥”，为了安全，请设置为以数字和字母组成的32字符串。
#define WX_PartnerKey @"36Gs4VjM5Sez9Nmx2UJLyj4M27eJqbbx"
//获取用户openid，可使用APPID对应的公众平台登录http://mp.weixin.qq.com 的开发者中心获取AppSecret。
#define WX_AppSecret @"e90ab5f01dc054db9798df28bf93395f"
#define MCH_ID  @"1348228001"//微信商户号
#define WEIXIN_URL @""//微信回调地址

#import "getIPhoneIP.h"
#import "XMLDictionary.h"
#import "DataMD5.h"
#import "WXApiManager.h"



@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
    }else  if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
      //  [[NetworkRequest sharedNetworkRequest] showHUDMessage:@"获取微信数据"];
        [self getAccess_token:temp.code];
    }else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp*response=(PayResp*)resp;  // 微信终端返回给第三方的关于支付结果的结构体
        self.block(response.errCode);
        switch (response.errCode) {
            case WXSuccess:
            {// 支付成功，向后台发送消息
                NSLog(@"支付成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WX_PaySuccess" object:nil];
            }
                break;
            case WXErrCodeCommon:
            { //签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
                NSLog(@"支付失败");
            }
                break;
            case WXErrCodeUserCancel:
            { //用户点击取消并返回
                NSLog(@"取消支付");
            }
                break;
            case WXErrCodeSentFail:
            { //发送失败
                NSLog(@"发送失败");
            }
                break;
            case WXErrCodeUnsupport:
            { //微信不支持
                NSLog(@"微信不支持");
            }
                break;
            case WXErrCodeAuthDeny:
            { //授权失败
                NSLog(@"授权失败");
            }
                break;
            default:
                break;
        }
    }
    
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

-(void)getAccess_token:(NSString *)code
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWXAPP_ID,kWXAPP_SECRET,code];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
                NSLog(@"%@~~~~~%@",[dic objectForKey:@"access_token"],[dic objectForKey:@"openid"]);
                if ([dic objectForKey:@"access_token"]) {
                    [self getUserInfoWith:[dic objectForKey:@"access_token"] With:[dic objectForKey:@"openid"]];
                }else
                {
                //    [[NetworkRequest sharedNetworkRequest] dismissHUD];
                }
            }else
            {
              //  [[NetworkRequest sharedNetworkRequest] dismissHUD];
            }
        });
    });
}
-(void)getUserInfoWith:(NSString *)token With:(NSString *)openid
{
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                NSLog(@"%@",dic);
            
                NSMutableDictionary *pare=[NSMutableDictionary dictionary];
//                [pare setValue:token forKey:@"token"];
                [pare setValue:openid forKey:@"weixin_token"];
                [pare setValue:dic[@"nickname"] forKey:@"username"];
                [pare setValue:dic[@"headimgurl"] forKey:@"header_img"];
              //  [[NetworkRequest sharedNetworkRequest] dismissHUD];
                if (_delegate
                    && [_delegate respondsToSelector:@selector(mangerDidSendAuthRespUserInfo:)]) {
                    [_delegate mangerDidSendAuthRespUserInfo:pare];
                }
            }
        });
        
    });
}
//dict 必传参数 subject 标题  price 价格单位分 orderNmuber 订单号
- (void)weixinChooseActWithDict:(NSMutableDictionary *)dict andBlock:(void(^)(NSInteger index))block
{
    self.block=block;
    NSString *appid,*mch_id,*nonce_str,*sign,*body,*out_trade_no,*total_fee,*spbill_create_ip,*notify_url,*trade_type,*partner;
    //应用APPID
    appid = WX_AppID;
    //微信支付商户号
    mch_id = MCH_ID;
    //产生随机字符串，这里最好使用和安卓端一致的生成逻辑
    nonce_str =[self generateTradeNO];
    body =dict[@"subject"];
    //随机产生订单号用于测试，正式使用请换成你从自己服务器获取的订单号
    out_trade_no =dict[@"orderNmuber"];
    //交易价格1表示0.01元，10表示0.1元
    total_fee = dict[@"price"];
    //获取本机IP地址，请再wifi环境下测试，否则获取的ip地址为error，正确格式应该是8.8.8.8
    spbill_create_ip =[getIPhoneIP getIPAddress];
    //交易结果通知网站此处用于测试，随意填写，正式使用时填写正确网站
    notify_url =@"微信回调必填后台提供";
    trade_type =@"APP";
    //商户密钥
    partner = WX_PartnerKey;
    //获取sign签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:appid mch_id:mch_id nonce_str:nonce_str partner_id:partner body:body out_trade_no:out_trade_no total_fee:total_fee spbill_create_ip:spbill_create_ip notify_url:notify_url trade_type:trade_type];
    sign = [data getSignForMD5];
    //设置参数并转化成xml格式
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:appid forKey:@"appid"];//公众账号ID
    [dic setValue:mch_id forKey:@"mch_id"];//商户号
    [dic setValue:nonce_str forKey:@"nonce_str"];//随机字符串
    [dic setValue:sign forKey:@"sign"];//签名
    [dic setValue:body forKey:@"body"];//商品描述
    [dic setValue:out_trade_no forKey:@"out_trade_no"];//订单号
    [dic setValue:total_fee forKey:@"total_fee"];//金额
    [dic setValue:spbill_create_ip forKey:@"spbill_create_ip"];//终端IP
    [dic setValue:notify_url forKey:@"notify_url"];//通知地址
    [dic setValue:trade_type forKey:@"trade_type"];//交易类型
    // 转换成xml字符串
    NSString *string = [dic XMLString];
    [self http:string];
}

#pragma mark - 拿到转换好的xml发送请求
- (void)http:(NSString *)xml {
    /*
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //这里传入的xml字符串只是形似xml，但是不是正确是xml格式，需要使用af方法进行转义
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"https://api.mch.weixin.qq.com/pay/unifiedorder" forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return xml;
    }];
    //发起请求
    [manager POST:@"https://api.mch.weixin.qq.com/pay/unifiedorder" parameters:xml progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        NSLog(@"responseString is %@",responseString);
        //将微信返回的xml数据解析转义成字典
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:responseString];
        //判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            //发起微信支付，设置参数
            PayReq *request = [[PayReq alloc] init];
            request.openID = [dic objectForKey:@"appid"];
            request.partnerId = [dic objectForKey:@"mch_id"];
            request.prepayId= [dic objectForKey:@"prepay_id"];
            request.package = @"Sign=WXPay";
            request.nonceStr= [dic objectForKey:@"nonce_str"];
            //将当前事件转化成时间戳
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            request.timeStamp= timeStamp;
            // 签名加密
            DataMD5 *md5 = [[DataMD5 alloc] init];
            request.sign=[md5 createMD5SingForPay:request.openID partnerid:request.partnerId prepayid:request.prepayId package:request.package noncestr:request.nonceStr timestamp:request.timeStamp];
            // 调用微信
            [WXApi sendReq:request];
        }else{
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
     */
}
-(void)weichatPay:(NSDictionary *)orderdict andBlock:(void(^)(NSInteger index))block;
{
    /*
    self.block=block;
    [orderdict setValue:[NSString stringWithFormat:@"%.0f",[orderdict[@"price"] doubleValue]*100] forKey:@"price"];
    if (![CESHIPRICE isEqualToString:@""]) {
        [orderdict setValue:[NSString stringWithFormat:@"1"] forKey:@"price"];
    }
    NSLog(@"%@",orderdict);
    [[NetworkRequest sharedNetworkRequest] postWithUrl:WEIXINPAY andParData:orderdict success:^(id dic, int code) {
        NSLog(@"%@",dic);
        //拿到的后台数据必须包含以下信息
        PayReq *request = [[PayReq alloc] init];
        request.openID = [dic objectForKey:@"appid"];
        request.partnerId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"partnerid"]];
        request.prepayId= [NSString stringWithFormat:@"%@",[dic objectForKey:@"prepayid"]];
        request.package = [dic objectForKey:@"package"];
        request.nonceStr= [dic objectForKey:@"noncestr"];
        request.timeStamp=[[dic objectForKey:@"timestamp"] intValue];
        request.sign=[dic objectForKey:@"sign"];
        [WXApi sendReq:request];
    } failure:^(NSError *error) {
        
    }];
     */
}
- (void)shareWeiChatText:(NSString *)title WithDescriPtion:(NSString *)description WithTexxt:(NSString *)text
{
    WXMediaMessage *message=[WXMediaMessage message];
    message.title=title;
    message.description=description;
    [message setThumbImage:[UIImage imageNamed:@"icon的副本"]];
    
    WXWebpageObject *webpageobject=[WXWebpageObject object];
    webpageobject.webpageUrl=text;
    
    
    message.mediaObject=webpageobject;
    
    SendMessageToWXReq *req=[[SendMessageToWXReq alloc]init];
    req.bText=YES;
    req.text=text;
    req.message=message;
    req.scene=WXSceneTimeline;
    [WXApi sendReq:req];
    NSLog(@"%d",[WXApi sendReq:req]);
}
- (void)shareWeiChatImage:(NSString *)title WithDescriPtion:(NSString *)description WithImage:(NSString *)imageUrl
{
    /*
    WXMediaMessage *message=[WXMediaMessage message];
    message.title=title;
    message.description=description;
    [message setThumbImage:[UIImage imageNamed:@"icon的副本"]];
    
    WXImageObject *webpageobject=[WXImageObject object];
    UIImage *myCachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:IMAGEURLWithStr(imageUrl)];
    if (myCachedImage) {
        webpageobject.imageData=UIImagePNGRepresentation(myCachedImage);
        message.mediaObject=webpageobject;
        SendMessageToWXReq *req=[[SendMessageToWXReq alloc]init];
        req.bText=NO;
        req.message=message;
        req.scene=WXSceneTimeline;
        [WXApi sendReq:req];
        NSLog(@"%d",[WXApi sendReq:req]);
    }
     */
}
- (void)wxshareQuanTitle:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr
{
    WXMediaMessage *message=[WXMediaMessage message];
    message.title=title;
    message.description=description;
    [message setThumbImage:[UIImage imageNamed:@"icon的副本"]];
    
    WXWebpageObject *webpageobject=[WXWebpageObject object];
    webpageobject.webpageUrl=urlstr;
    
    
    message.mediaObject=webpageobject;
    
    SendMessageToWXReq *req=[[SendMessageToWXReq alloc]init];
    req.bText=NO;
    req.message=message;
    req.scene=WXSceneTimeline;
    [WXApi sendReq:req];
    NSLog(@"%d",[WXApi sendReq:req]);

}
- (void)wxshareTitleStr:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr
{
    WXMediaMessage *message=[WXMediaMessage message];
    message.title=title;
    message.description=description;
    [message setThumbImage:[UIImage imageNamed:@"icon的副本"]];
    
    WXWebpageObject *webpageobject=[WXWebpageObject object];
    webpageobject.webpageUrl=urlstr;
    
    
    message.mediaObject=webpageobject;
    
    SendMessageToWXReq *req=[[SendMessageToWXReq alloc]init];
    req.bText=NO;
    req.message=message;
    req.scene=WXSceneSession;
    [WXApi sendReq:req];
    NSLog(@"%d",[WXApi sendReq:req]);
}
- (void)qqshareTitleStr:(NSString *)title withDescription:(NSString *)description withUrl:(NSString *)urlstr
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iocn3.png"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    NSURL* url = [NSURL URLWithString:urlstr];
  /*  QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:title description:description previewImageData:data];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    [QQApiInterface sendReq:req];
    NSLog(@"%d",[QQApiInterface sendReq:req]);
   */
}
- (NSString *)generateTradeNO {
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0)); // 此行代码有警告:
    for (int i = 0; i < kNumber; i++) {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end
