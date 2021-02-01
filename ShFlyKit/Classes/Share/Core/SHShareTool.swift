//
//  SHShareTool.swift
//  SHLibrary
//
//  Created by hsh on 2018/7/18.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import MessageUI


//分享的方式
public enum ShareType{
      case  WeChatZone,             //朋友圈
            WeChat,                 //微信好友
            WeChatMiniPM,           //微信小程序
            QQzone,                 //QQ空间
            QQ,                     //QQ
            Weibo,                  //微博
            SMS,                    //短信
            System                  //隔空投放
}

//分享的媒体类型
public enum ShareMediaType{
     case Text,Picture,Web,Music,Vedio
}

//第三方登录的方式
public enum LoginType{
    case WeChat,QQ,Weibo
}


//登录的回调Block
public typealias LoginBlock = ((_ type:LoginType, _ logined:Bool,_ msg:String)->Void)


///第三方分享、登录的工具类
class SHShareTool: NSObject,MFMessageComposeViewControllerDelegate,
WeiboSDKDelegate,WXApiDelegate,TencentLoginDelegate,TencentSessionDelegate{
    //Variable
    public static let shared = SHShareTool()
    private var tencentOauth:TencentOAuth!          //腾讯oauth认证
    private var wbToken:String!                     //微博的token
    private var shareObject:ShareObjct!             //分享的模型,包括回调
    private var loginBlock:LoginBlock!              //登录的回调
    private var qqInterfacePair = QQInterfacePair() //QQ代理的处理类
    
    
    ///Interface
    //判断是否登录
    class public func isAppInstalled(_ type:LoginType)->Bool{
        switch type {
        case .WeChat:
            return WXApi.isWXAppInstalled()
        case .QQ:
            return QQApiInterface.isQQInstalled();
        case .Weibo:
            return WeiboSDK.isWeiboAppInstalled();
        }
    }
    

    //注册APPID、key
    public func registerAppkey(appkey:String,appType:LoginType){
        switch appType {
        case .WeChat:
            WXApi.registerApp(appkey, universalLink: "");
        case .QQ:
            self.tencentOauth = TencentOAuth.init(appId: appkey, andDelegate: self);
        case .Weibo:
            WeiboSDK.registerApp(appkey);
        }
    }
    

    ///发起第三方登录
    public func login(_ loginBlock:@escaping LoginBlock,type:LoginType,scope:String = "all",state:String = "")->Void{
        self.loginBlock = loginBlock;
        switch type {
        case .Weibo:
            let authRequest:WBAuthorizeRequest = WBAuthorizeRequest()
            //这里的地址必须要与微博开发平台设置的地址相同
            authRequest.redirectURI = "https://api.weibo.com/oauth2/default.html";
            authRequest.scope = scope;
            WeiboSDK.send(authRequest);
            break;
        case .WeChat:
            let authReq = SendAuthReq()
            authReq.scope = scope;
            authReq.state = state;
            if (SHShareTool.isAppInstalled(.WeChat)){
                 WXApi.send(authReq);
            }else{
                //没有安装微信app的
                let vc:UIViewController = (UIApplication.shared.delegate?.window?!.rootViewController)!;
                WXApi.sendAuthReq(authReq, viewController: vc, delegate: self);
            }
            break;
        case .QQ:
            let array = [kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,kOPEN_PERMISSION_ADD_SHARE];
            tencentOauth.authorize(array);
            break;
        }
    }
    
    
    
    ///第三方分享
    public func share(type:ShareType,dataObject:ShareObjct)->Void{
        //保存数据
        self.shareObject = dataObject;
        self.qqInterfacePair.shareObject = dataObject;
        self.shareObject.shareType = type;
        //分享的图片的二进制数据
        var imageData = Data();
        if dataObject.image != nil {
            imageData = UIImagePNGRepresentation(dataObject.image!)!;
        }
        switch type {
        case .WeChatZone,.WeChat://微信好友，朋友圈分享
            //消息模型
            let message:WXMediaMessage = WXMediaMessage()
            message.title = dataObject.title;
            message.description = dataObject.content;
            //设置缩略图
            if dataObject.image != nil {
                message.setThumbImage(dataObject.image!);
            }
            //分享的媒体类型
            if (dataObject.mediaType == .Vedio){
                let vedioObjct:WXVideoObject = WXVideoObject()
                vedioObjct.videoUrl = dataObject.url;
                message.mediaObject = vedioObjct;
            }else if (dataObject.mediaType == .Music){
                let musicObject:WXMusicObject = WXMusicObject()
                musicObject.musicUrl = dataObject.url;
                musicObject.musicDataUrl = dataObject.url;
                message.mediaObject = musicObject;
            }else if (dataObject.mediaType == .Picture){
                let imageObject = WXImageObject()
                imageObject.imageData = imageData;
                message.mediaObject = imageObject;
            }else if (dataObject.mediaType == .Web){
                let webObject:WXWebpageObject = WXWebpageObject()
                webObject.webpageUrl = dataObject.url;
                message.mediaObject = webObject;
            }
            //请求的信息模型
            let req:SendMessageToWXReq = SendMessageToWXReq()
            req.bText = false;
            //纯文本
            if (dataObject.mediaType == .Text){
                req.bText = true;//不能同时发送文本和多媒体
                req.text = dataObject.content;
            }else{
                req.message = message;
            }
            //分享到好友还是空间
            let scene:WXScene = (type == .WeChatZone) ? WXSceneTimeline : WXSceneSession;
            req.scene = Int32(scene.rawValue);
            WXApi.send(req);
        case .WeChatMiniPM://微信小程序
            let object:WXMiniProgramObject = WXMiniProgramObject()
            object.webpageUrl = dataObject.url;                     //网址 ""
            object.userName = dataObject.userName;                  //ID
            object.path = dataObject.path;                          //小程序的路径
            object.miniProgramType = WXMiniProgramType.release;     //正式版本
            if dataObject.envirment == .DEV{
                object.miniProgramType = WXMiniProgramType.test;    //测试版本
            }else if (dataObject.envirment == .PRE){
                object.miniProgramType = WXMiniProgramType.preview; //预发布版本
            }
            //图片
            object.hdImageData = imageData;
            //消息模型
            let message:WXMediaMessage = WXMediaMessage()
            message.title = dataObject.title;
            message.description = dataObject.content;
            message.mediaObject = object;
            //只能分享到好友
            let req:SendMessageToWXReq = SendMessageToWXReq()
            req.message = message;
            req.scene = Int32(WXSceneSession.rawValue);
            WXApi.send(req);
            break;
        case .QQ,.QQzone:
            let req:SendMessageToQQReq!
            if (dataObject.mediaType == .Text){//不支持空间
                let textObj = QQApiTextObject.init(text: dataObject.content);
                req = SendMessageToQQReq.init(content: textObj);
                QQApiInterface.send(req);
            }else if (dataObject.mediaType == .Picture){//不支持空间
                let imgObj = QQApiImageObject.init(data: imageData, previewImageData: imageData, title: dataObject.title, description: dataObject.content);
                req = SendMessageToQQReq.init(content: imgObj);
                QQApiInterface.send(req);
            }else if (dataObject.mediaType == .Web){
                let webObj = QQApiNewsObject.init(url: URL.init(string: dataObject.url), title: dataObject.title, description: dataObject.content, previewImageData: imageData, targetContentType: QQApiURLTargetTypeNews);
                if type == .QQ {
                    webObj?.cflag = UInt64(kQQAPICtrlFlagQQShare);
                    req = SendMessageToQQReq.init(content: webObj);
                    QQApiInterface.send(req);
                }else{
                    webObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart);
                    req = SendMessageToQQReq.init(content: webObj);
                    QQApiInterface.sendReq(toQZone: req);
                }
            }else if (dataObject.mediaType == .Music){
                let audioObj = QQApiAudioObject.init(url: URL.init(string: dataObject.url), title: dataObject.title, description: dataObject.content, previewImageURL: URL.init(string: dataObject.previewImageUrl ?? ""), targetContentType: QQApiURLTargetTypeAudio);
                req = SendMessageToQQReq.init(content: audioObj);
                if type == .QQ {
                    QQApiInterface.send(req);
                }else{
                    QQApiInterface.sendReq(toQZone: req);
                }
            }else if (dataObject.mediaType == .Vedio){
                let vedioObj = QQApiVideoObject.init(url: URL.init(string: dataObject.url), title: dataObject.title, description: dataObject.content, previewImageURL: URL.init(string: dataObject.previewImageUrl ?? ""), targetContentType: QQApiURLTargetTypeVideo);
                req = SendMessageToQQReq.init(content: vedioObj);
                if type == .QQ {
                    QQApiInterface.send(req);
                }else{
                    QQApiInterface.sendReq(toQZone: req);
                }
            }
            break;
        case .SMS:
            let msgVC = MFMessageComposeViewController()
            msgVC.messageComposeDelegate = self;
            msgVC.body = String(format: "%@%@", dataObject.content,dataObject.url!);
            if (dataObject.image != nil && MFMessageComposeViewController.canSendAttachments()) {
                let data:Data = UIImagePNGRepresentation(dataObject.image!)!;
                msgVC.addAttachmentData(data, typeIdentifier: "public.image", filename: "image.png");
            }
            let vc:UIViewController = (UIApplication.shared.delegate?.window?!.rootViewController)!;
            vc.present(msgVC, animated: true, completion: nil);
            break;
        case .Weibo:
            //微博客户端程序和第三方应用之间传递的消息结构
            let message:WBMessageObject = WBMessageObject()
            //图片
            if (dataObject.mediaType == .Picture){
                let imageObject:WBImageObject = WBImageObject()
                imageObject.imageData = imageData;
                message.imageObject = imageObject;
                message.text = dataObject.content;
            //视频
            }else if (dataObject.mediaType == .Vedio){
                let vidioObject:WBNewVideoObject = WBNewVideoObject()
                vidioObject.addVideo(URL.init(string: dataObject.url));
                message.videoObject = vidioObject;
            //网页链接分享
            }else{
                let webObject:WBWebpageObject = WBWebpageObject();
                webObject.objectID = "identifier";
                webObject.title = dataObject.title;
                webObject.description = dataObject.content;
                webObject.thumbnailData = imageData;
                webObject.webpageUrl = dataObject.url;
                message.mediaObject = webObject;
            }
            //认证
            let authRequest:WBAuthorizeRequest = WBAuthorizeRequest()
            authRequest.redirectURI = "https://api.weibo.com/oauth2/default.html";//微博推荐的默认地址
            authRequest.scope = "all";
            //分享请求
            let request:WBSendMessageToWeiboRequest = WBSendMessageToWeiboRequest.request(withMessage: message, authInfo: authRequest, access_token: wbToken) as! WBSendMessageToWeiboRequest;
            WeiboSDK.send(request);
        case .System:
            let vc:UIViewController = (UIApplication.shared.delegate?.window?!.rootViewController)!;
            SHShareTool.shareActivity(text: dataObject.title, urlStr: dataObject.url, image: dataObject.image, holdVC: vc);
        }
    }
    
    
    //系统原生的分享,text-文字，urlStr-分享的链接，image-分享的图片，holdVC-宿主控制器，airdrop,message,微信，钉钉，QQ，打印，保存图片
    static public func shareActivity(text:String,urlStr:String,image:UIImage?,holdVC:UIViewController)->Void{
        let finalURL = NSURL(string: urlStr as String);
        var activityItems:NSArray = [text,finalURL!];
        if  (image != nil) {
            activityItems =  [text,image!,finalURL!];
        }
        let activityVC = UIActivityViewController(activityItems: activityItems as! [Any], applicationActivities: nil);
        holdVC.present(activityVC, animated: true, completion: nil);
    }
    
    
    //MFMessageComposeViewController短信回调
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil);
        if shareObject != nil{
            if (result == MessageComposeResult.sent) {
                shareObject.success?(shareObject.shareType);
            }else if (result == MessageComposeResult.failed){
                shareObject.failure?(shareObject.shareType,MessageComposeResult.failed.rawValue,"发送短信失败");
            }else if (result == MessageComposeResult.cancelled){
                shareObject.failure?(shareObject.shareType,MessageComposeResult.cancelled.rawValue,"取消发送短信");
            }
        }
        shareObject = nil;
    }
    
    
    //HandleURL
    public func handleUrl(_ url:URL){
        let urlString = url.absoluteString;
        if (urlString.hasPrefix("wx") && (url.host == "pay") == false ) {
            //微信的分享/登录
            WXApi.handleOpen(url, delegate: self);
        }else if (urlString.hasPrefix("QQ") || (urlString.hasPrefix("tencent"))){
            //QQ的分享
            TencentOAuth.handleOpen(url);
            //QQ的登录
            QQApiInterface.handleOpen(url, delegate: self.qqInterfacePair);
        }else{
            //微博的分享/登录
            WeiboSDK.handleOpen(url, delegate: self);
        }
    }
    
    
    
    
    
    
    
    
    
    ///分享的回调
    //WXApiDelegate
    public func onResp(_ resp: BaseResp) {
        if resp.isKind(of: SendMessageToWXResp.self) {
            if shareObject != nil{
                if (resp.errCode == 0){
                    shareObject.success?(shareObject.shareType);
                }else{
                    shareObject.failure?(shareObject.shareType,Int(resp.errCode),resp.errStr)
                }
            }
        }else if (resp.isKind(of: SendAuthResp.self)){
            if (resp.errCode == 0){
                loginBlock?(.WeChat,true,"登录成功");
            }else{
                loginBlock?(.WeChat,false,resp.errStr );
            }
        }
    }
    
    
    //WeiBoSDK Delegate
    public func didReceiveWeiboRequest(_ request: WBBaseRequest!) {}
    
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        //如果能成功跳转微博客户端，分享会走if里面
        if (response.isKind(of: WBSendMessageToWeiboResponse.self)){
            let weiboResponse:WBSendMessageToWeiboResponse = response as! WBSendMessageToWeiboResponse;
            let accessToken = weiboResponse.authResponse.accessToken;
            if accessToken != nil{
                wbToken = accessToken;
            }
            if shareObject != nil{
                if (weiboResponse.statusCode == .success){
                    shareObject.success?(shareObject.shareType);
                }else{
                    shareObject.failure?(shareObject.shareType,weiboResponse.statusCode.rawValue,
                                         (weiboResponse.statusCode == .userCancel ? "用户取消发送" : "发送失败"));
                }
            }
        }else if (response.isKind(of: WBAuthorizeResponse.self)){
            //登录授权回调
            let autuResponse:WBAuthorizeResponse = response as! WBAuthorizeResponse;
            wbToken = autuResponse.accessToken;
            if autuResponse.statusCode == WeiboSDKResponseStatusCode.success{
                loginBlock?(.Weibo,true,"登录成功");
            }else{
                loginBlock?(.Weibo,true,"失败");
            }
        }
    }
    
    
    ///登录的回调
    //TencentSessionDelegate
    public func tencentDidLogin() {
        loginBlock?(.QQ,true,"登录成功");
    }
    
    public func tencentDidNotNetWork() {}
    
    public func tencentDidNotLogin(_ cancelled: Bool) {
        loginBlock?(.QQ,false,cancelled ? "用户取消登录" : "登录失败");
    }
    
}




//QQApiInterfaceDelegate的代理对象，因为WXApiDelegate和QQApiInterfaceDelegate方法取名重复冲突了
class QQInterfacePair:NSObject,QQApiInterfaceDelegate{
    //Variable
    public var shareObject:ShareObjct!             //分享的模型
    
    //QQApiInterfaceDelegate
    public func onReq(_ req: QQBaseReq!) {}
    
    public func isOnlineResponse(_ response: [AnyHashable : Any]!) {}
    
    
    public func onResp(_ resp: QQBaseResp!) {
        if (Int.init(resp.result) == 0) {
            shareObject.success?(shareObject.shareType);
        }else{
            shareObject.failure?(shareObject.shareType,Int.init(resp.result)!,resp.errorDescription);
        }
    }
}



//分享的内容模型
public class ShareObjct:NSObject{
    public var shareType:ShareType!                 //分享的类型
    public var mediaType:ShareMediaType!            //分享的内容类型
    public var title:String!                        //标题
    public var content:String!                      //内容
    public var image:UIImage?                       //缩略图
    public var url:String!                          //分享的链接
    //回调
    public var success:((_ type:ShareType)->Void)?
    public var failure:((_ type:ShareType,_ retCode:Int,_ msg:String)->Void)?
    
    //optional
    public var path:String!
    public var userName:String!
    public var previewImageUrl:String?              //预览图的URL
    public var envirment:Envirment = .PRD
    
    //数据环境--主要用于微信小程序
    public enum Envirment{
        case DEV,PRE,PRD
    }
    
    //初始化
    class public func initObject(_ type:ShareMediaType, _ title:String,_ content:String,_ url:String?,_ image:UIImage?,
                                 _ success:@escaping ((_ type:ShareType)->Void),failure:@escaping ((_ type:ShareType,_ retCode:Int,_ msg:String)->Void))->ShareObjct{
        let object = ShareObjct()
        object.mediaType = type;
        object.title = title;
        object.content = content;
        object.url = url;
        object.image = image;
        object.success = success;
        object.failure = failure;
        return object;
    }
}

