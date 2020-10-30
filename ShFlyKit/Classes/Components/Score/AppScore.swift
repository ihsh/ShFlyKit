//
//  AppScore.swift
//  SHKit
//
//  Created by hsh on 2019/5/10.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import StoreKit


//应用商城评分类
public class AppScore: NSObject {
    
    
    //判断系统是否开了评分的入口
    class public func isResponseReview()->Bool{
        if #available(iOS 10.3, *) {
            return SKStoreReviewController.responds(to: #selector(SKStoreReviewController.requestReview))
        } else {
            // Fallback on earlier versions
            return false;
        };
    }
    
    
    //弹出一个询问弹框
    class public func dialog(_ title:String,reviewTitle:String,noActionTitle:String,scoreTitle:String,appID:String){
        //弹窗控制器
        let alertVC = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertController.Style.alert);
        //评论
        let reviewAction = UIAlertAction.init(title: reviewTitle, style: .default) { (action) in
            AppScore.openReviewOnAppStore(appID);
        }
        //不操作
        let noAction = UIAlertAction.init(title: noActionTitle, style: .cancel, handler: nil);
        alertVC.addAction(reviewAction);
        alertVC.addAction(noAction);
        //系统设置中是否打开了评分入口
        if #available(iOS 10.3, *) {
            if (SKStoreReviewController.responds(to: #selector(SKStoreReviewController.requestReview))) {
                let scoreAction = UIAlertAction.init(title: scoreTitle, style: .default) { (action) in
                    AppScore.appRequestReview();
                }
                alertVC.addAction(scoreAction);
            }
        } else {
            // Fallback on earlier versions
        }
        let vc:UIViewController = (UIApplication.shared.delegate?.window?!.rootViewController)!;
        vc.present(alertVC, animated: true, completion: nil);
    }
    

    //打开应用内评分--生产环境才可提交
    class public func appRequestReview(){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        };
    }
    
    
    //打开应用商城对应的界面
    class public func openAppOnAppStore(_ appID:String){
        let appUrl = String(format:"https://itunes.apple.com/cn/app/%@", appID);
        UIApplication.shared.open(URL.init(string: appUrl)!, options: Dictionary(), completionHandler: nil);
    }
    
    
    //打开应用商城中评论的界面
    class public func openReviewOnAppStore(_ appID:String){
        let appUrl = String(format:"https://itunes.apple.com/cn/app/%@?action=write-review", appID);
        UIApplication.shared.open(URL.init(string: appUrl)!, options: Dictionary(), completionHandler: nil);
    }
    
    
}
