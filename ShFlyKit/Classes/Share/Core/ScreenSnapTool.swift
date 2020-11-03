//
//  ScreenSnapTool.swift
//  SHKit
//
//  Created by hsh on 2019/5/10.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Photos


//截屏的代理
@objc public protocol ScreenSnapToolDelegate:NSObjectProtocol {
    //发生了截屏操作
    func DidTakeScreenshot(image:UIImage,window:UIWindow)
    //录屏状态改变
    @objc optional func CaptureStatusChange(_ capture:Bool);
}


//截屏控制类
public class ScreenSnapTool: NSObject {
    //Variable
    public static let shared = ScreenSnapTool()             //单例
    private var delegates:[ScreenSnapModel] = []            //代理对象数组
    
    
    //注册截屏通知
    public func registerSnapNotifa(delegate:ScreenSnapToolDelegate?){
        //添加监听者
        if delegate != nil {
            let model = ScreenSnapModel()
            model.delegate = delegate;
            delegates.append(model);
        }
        //添加系统监听
        NotificationCenter.default.addObserver(self, selector: #selector(userDidTakeScreenshot),
                                               name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil);
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(screenCaptureChange),
                                                   name: NSNotification.Name.UIScreenCapturedDidChange, object: nil)
        } else {
            // Fallback on earlier versions
        };
    }
    
    
    
    //屏幕正在录制
    @objc private func screenCaptureChange(){
        var isCapture:Bool = false
        if #available(iOS 11.0, *) {
            isCapture = UIScreen.main.isCaptured
        } else {
            // Fallback on earlier versions
        };
        for model in delegates {
            model.delegate?.CaptureStatusChange?(isCapture);
        }
        recycleObserver();
    }
    
    
    
    //发生了截屏
    @objc private func userDidTakeScreenshot(){
        
        let window:UIWindow = UIApplication.shared.delegate!.window!!;
        //生成截图的图片
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, window.isOpaque, 0);
        window.layer.render(in: UIGraphicsGetCurrentContext()!);
        let snap:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage();
        UIGraphicsEndImageContext();
        //代理调用
        for model in delegates {
            model.delegate?.DidTakeScreenshot(image: snap, window: window);
        }
        recycleObserver();
    }
    
    
    //剔除已经释放者
    private func recycleObserver(){
        var tmp:[ScreenSnapModel] = [];
        var need:Bool = false;
        for model in delegates {
            if model.delegate != nil{
                tmp.append(model);
            }else{
                need = true;
            }
        }
        if need == true {
            delegates.removeAll();
            delegates.append(contentsOf: tmp);
        }
    }
    
    
}



//解除强引用用
public class ScreenSnapModel:NSObject{
    public weak var delegate:ScreenSnapToolDelegate?
}
