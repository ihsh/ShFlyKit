//
//  PayFunction.swift
//  SHKit
//
//  Created by hsh on 2019/4/1.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import PassKit


//支持的支付方式
enum PayType {
    case ZhiFubao,WeChat,Union,ApplePay, Wallet,Cash,Custom                   //支付宝，微信，银联(云闪付),ApplePay,个人钱包,现金,自定义
}


//支付的回调Block
typealias SuccessCall = ((_ result:Any)->Void)                  //成功回调
typealias FailureCall = ((_ ret:Int,_ msg:String?)->Void)       //失败回调


///回调调用对
class BlockPair: NSObject {
    //Variable
    public var successBlock:SuccessCall!
    public var failureBlock:FailureCall!
    public var type:PayType!                                    //支付方式
    
    //创建回调用对
    static public func initPair(success:@escaping SuccessCall,failure:@escaping FailureCall)->BlockPair{
        let pair = BlockPair()
        pair.successBlock = success;
        pair.failureBlock = failure;
        return pair;
    }
}



///支付控制单例
class PayFunction: NSObject,WXApiDelegate,UPAPayPluginDelegate{
    //Variable
    static  let shared = PayFunction.init()                     //单例
    private var blockArray:[BlockPair] = []                     //回调对数组
    //配置信息
    private var wechatAppId:String!                             //微信AppId
    private var wechatMchId:String!                             //微信商户ID
    private var alipayScheme:String!                            //支付宝UrlScheme
    private var unionPayScheme:String!                          //银联云闪付Scheme
    
    
    ///Interface
    //配置微信的appid和mchid
    public func configWechat(appId:String,mchId:String){
        if (appId != wechatAppId) {
           let result = [WXApi .registerApp(appId, enableMTA: false)];
            print(result);
        }
        wechatAppId = appId;
        wechatMchId = mchId;
    }
    
    
    //配置支付宝的scheme
    public func configAlipay(scheme:String){
        alipayScheme = scheme;
    }
    
    
    //银联云闪付Scheme
    public func configUnion(scheme:String){
        unionPayScheme = scheme;
    }
    
    
    //判断是否安装
    public func isInstalled(type:PayType)->Bool{
        switch type {
        case .WeChat:
            return WXApi.isWXAppInstalled()
        case .ZhiFubao:
            //请在info.plist中添加一个LSApplicationQueriesSchemes，注意不是URL Type(会导致别的app支付唤起支付宝，唤起了本应用)
            let url:URL = URL(string: "alipay")!;
            return UIApplication.shared.canOpenURL(url);
        case .Union:
            return UPPaymentControl.default()?.isPaymentAppInstalled() ?? false;
        case .ApplePay:
            return PKPaymentAuthorizationViewController.canMakePayments();
        default:
            return false;
        }
    }
    
    
    //支付宝支付---orderString(签名后的字符串)
    public func alipay(orderString:String,pair:BlockPair){
        addPair(pair, type: PayType.ZhiFubao);
        //发起支付
        AlipaySDK.defaultService()?.payOrder(orderString, fromScheme: alipayScheme, callback: { (result) in
            //支付宝wao支付回调
            self.alipayResultHandle(result: result as NSDictionary? ?? NSDictionary())
        })
    }
    
    
    //支付宝纯签约与免密支付中签约
    public func alipaySignOrPay(url:String){
        UIApplication.shared.open(URL(string: url)!, options: Dictionary(), completionHandler: nil);
    }
    
    
    
    //微信支付---普通支付和免密支付
    public func wechatPay(prepayId:String,nonceStr:String,timeStamp:UInt32,package:String,sign:String,pair:BlockPair){
        addPair(pair, type: PayType.WeChat);
        let req:PayReq = PayReq()
        req.openID = wechatAppId;       //appID
        req.partnerId = wechatMchId;    //商户号
        req.prepayId = prepayId;        //预支付订单
        req.nonceStr = nonceStr;        //随机串，防重发
        req.timeStamp = timeStamp;      //时间戳，防重发
        req.package = package;          //商家根据财付通文档填写的数据和签名
        req.sign = sign;                //商家根据微信开放平台文档对数据做的签名
        if (WXApi.send(req) == false) {
            let block:BlockPair = pairForType(PayType.WeChat);
            block.failureBlock(-999,"发起微信支付失败");
            deletePairForType(PayType.WeChat);
        }
    }
    
    
    //微信纯签约
    public func wechatSign(url:String){
        let open:OpenWebviewReq = OpenWebviewReq()
        open.url = url;
        WXApi.send(open);
    }
    
    
    //银联云闪付
    public func unionPay(tn:String,vc:UIViewController?,test:Bool = false,pair:BlockPair){
        if (unionPayScheme == nil) {
            return;
        }
        addPair(pair, type: PayType.Union);
        let presentVC = provideVC(vc: vc);
        let mode = test == true ? "01" : "00";
        let result = UPPaymentControl.default()?.startPay(tn, fromScheme: unionPayScheme, mode: mode, viewController: presentVC);
        if (result == false) {
            let pair:BlockPair = pairForType(PayType.Union);
            pair.failureBlock(-999,"发起银联支付失败");
            deletePairForType(PayType.Union);
        }
    }
    
    
    
    //ApplePay
    public func applePay(tn:String,merchantID:String,vc:UIViewController?,test:Bool = false,pair:BlockPair){
        addPair(pair, type: PayType.ApplePay);
        let presentVC = provideVC(vc: vc);
        let mode = test == true ? "01" : "00";
        let result = UPAPayPlugin.startPay(tn, mode: mode, viewController: presentVC, delegate: self, andAPMechantID: merchantID);
        if (result == false) {
            let pair:BlockPair = pairForType(PayType.ApplePay);
            pair.failureBlock(-999,"发起ApplePay失败");
            deletePairForType(PayType.ApplePay);
        }
    }
    
    
    
    ///Handle
    //支付返回app的回调用
    public func handleOpenUrl(url:URL)->Bool{
        let str:String = url.absoluteString;
        //处理微信的支付回调
        if (str.hasPrefix("wx")&&url.host == "pay"){
            WXApi.handleOpen(url, delegate: self );
            return true;
        }else if (url.host == "safepay"){
            //处理支付宝的支付回调
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: { (result) in
                self.alipayResultHandle(result: result as NSDictionary? ?? NSDictionary())
            })
            return true;
        }else if (str == "uppayresult"){
            //银联云闪付
            self.unionpayResultHandle(url: url);
            return true;
        }
        return false;
    }
    
    
    //支付宝回调处理
    private func alipayResultHandle(result:NSDictionary)->Void{
        let resultStatus:NSString? = result.value(forKey: "resultStatus") as? NSString;
        let pair:BlockPair = pairForType(PayType.ZhiFubao);
        if (resultStatus?.integerValue == 9000) {
            if (pair.successBlock != nil) {
                pair.successBlock(result.value(forKey: "result") ?? "");
            }
        }else{
            if (pair.failureBlock != nil) {
                let memo:String? = result.value(forKey: "memo") as? String;
                pair.failureBlock(resultStatus?.integerValue ?? -1,memo);
            }
        }
        deletePairForType(PayType.ZhiFubao);
    }
    
    
    //银联云闪付的回调
    private func unionpayResultHandle(url:URL){
        let pair:BlockPair = pairForType(PayType.Union);
        UPPaymentControl.default()?.handlePaymentResult(url, complete: { (code, data) in
            if (code == "success"){
                pair.successBlock(data as NSDictionary? ?? NSDictionary());
            }else if (code == "fail"){
                pair.failureBlock(-1,"交易失败");
            }else if (code == "cancel"){
                pair.failureBlock(-2,"交易取消");
            }
        });
    }
    
    
    //微信回调--WXApiDelegate
    private func onResp(_ resp: PayResp!) {
        let pair:BlockPair = pairForType(PayType.WeChat);
        if resp.errCode == WXSuccess.rawValue {
            pair.successBlock(resp.returnKey);
        }else{
            pair.failureBlock(Int(resp.errCode),resp.errStr);
        }
        deletePairForType(PayType.WeChat);
    }
    
    
    //ApplePay的回调  UPAPayPluginDelegate
    func upaPayPluginResult(_ payResult: UPPayResult!) {
        let pair = pairForType(PayType.ApplePay);
        switch payResult.paymentResultStatus {
        case .success:
            pair.successBlock(payResult.otherInfo);
        case .failure:
            pair.failureBlock(-1,payResult.errorDescription);
        case .cancel:
            pair.failureBlock(-2,payResult.errorDescription);
        case .unknownCancel:
            pair.failureBlock(-3,payResult.errorDescription);
        }
        deletePairForType(PayType.ApplePay);
    }
    
    
    
    //是否有银联卡
    public func hasUnionPayCard()->Bool{
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.chinaUnionPay]);
    }
    
    
    //是否有储蓄卡
    public func hasUnionPayDebitCard()->Bool{
        let merchantCapability:PKMerchantCapability = PKMerchantCapability(rawValue: PKMerchantCapability.capability3DS.rawValue |
                                                        PKMerchantCapability.capabilityEMV.rawValue |
                                                        PKMerchantCapability.capabilityDebit.rawValue);
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.chinaUnionPay], capabilities: merchantCapability);
    }
    
    
    //是否有信用卡
    public func hasUnionPayCreditCard()->Bool{
        let merchantCapability:PKMerchantCapability = PKMerchantCapability(rawValue: PKMerchantCapability.capability3DS.rawValue |
            PKMerchantCapability.capabilityEMV.rawValue |
            PKMerchantCapability.capabilityCredit.rawValue);
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [PKPaymentNetwork.chinaUnionPay], capabilities: merchantCapability);
    }
    
    
    
    
    
    
    ///Private
    //新增一个回调调用对
    private func addPair(_ pair:BlockPair,type:PayType){
        deletePairForType(type);
        //注意赋值类型,才能找到
        pair.type = type;
        blockArray.append(pair);
    }
    
    
    //获取对应的回调调用对
    private func pairForType(_ type:PayType)->BlockPair{
        for pair in blockArray {
            if pair.type == type {
                return pair;
            }
        }
        //没有的话，返回一个空回调对
        return BlockPair.initPair(success: { (any) in   }, failure: { (code, msg) in });
    }
    
    
    //清除该支付方式的回调对
    private func deletePairForType(_ type:PayType){
        var tmpArr:[BlockPair] = [];
        for pair in blockArray {
            if pair.type != type {
                tmpArr.append(pair);
            }
        }
        //没有保存的将会释放
        blockArray.removeAll();
        blockArray.append(contentsOf: tmpArr);
    }
    
    
    //提供一个控制器
    private func provideVC(vc:UIViewController?)->UIViewController{
        var presentVC = vc;
        if (presentVC == nil) {
            presentVC = UIApplication.shared.delegate?.window??.rootViewController;
        }
        return presentVC!;
    }
    
    
}

