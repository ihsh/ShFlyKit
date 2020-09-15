//
//  SHJsActionHandler.swift
//  SHKit
//
//  Created by hsh on 2019/6/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Photos
import AVFoundation


//通用的JS回调处理类
class SHJsActionHandler: NSObject ,SHPhoneAssetsToolDelegate {
    //Variable
    private var callBackName:String!                //通用回调的名称
    public  var callMoreName:String!                //更多回调的名称
    private var currentAction:String!               //当前执行的action
    private var webVC:SHWebBaseVC!                  //对应的WebVC
    private var photoTool:SHPhoneAssetsTool!        //相册工具类
    
    
    override init() {
        super.init();
        photoTool = SHPhoneAssetsTool()
        photoTool.delegate = self;
    }
    
    
    //Interface
    //所有未单独注册的将分发到这，可以定义子类进行处理
    public func handleJsAction(jsDict:NSDictionary,vc:SHWebBaseVC){
        webVC = vc;
        //action名称
        let action:String = jsDict.value(forKey: "action") as! String;
        currentAction = action;
        //传到一个空方法，返回值代表，在这个方法里面是否已经处理完毕，处理完毕，不执行默认逻辑
        if evaluateAction(action, jsDict: jsDict, vc: vc) {
            return;
        }
        //默认的字段都固定了，需要自定义重写evaluateAction方法
        let content:String = jsDict.value(forKey: "content") as! String;
        self.callBackName = jsDict.value(forKey: "callback") as? String;
        
        //默认通用的处理逻辑
        if (action == "openApp"){
            let url:String? = jsDict.value(forKey: "url") as? String;
            if (url != nil) {
                UIApplication.shared.open(URL(string: url!)!, options: [:], completionHandler: nil);
            }
        }else if (action == "camera"){
            photoTool.useSystemCamera(type: .TakePhoto);
        }else if (action == "picture"){
            photoTool.cameraPhotoAlert(vc: vc);
        }else if (action == "shoot"){
            photoTool.cameraMovieAlert(vc: vc);
        }else if (action == "paste"){
            UIPasteboard.general.string = content;
        }else if (action == "saveImage"){
            self.saveImage(content);
        }else if (action == "setTitle"){
            let title:String? = (jsDict.value(forKey: "title") as! String)
            vc.naviBar.titleL.text = title;
        }else if (action == "rightItem"){
            self.configRightItem(jsDic: jsDict);
        }else if (action == "closeWeb"){
            vc.backBtnClick();
        }else{
            handleCustom(jsDict: jsDict, vc: vc);
        }
    }

    
    //Override
    //使用默认的action，未涉及的action,由子类重写该方法进行拓展
    public func handleCustom(jsDict:NSDictionary,vc:SHWebBaseVC){
        
    }
    
    
    //用于接收所有的action，可以拦截action
    public func evaluateAction(_ action:String,jsDict:NSDictionary,vc:SHWebBaseVC)->Bool{
        return false;
    }
    
    
    //只需要自定义弹框时自定义类重写该方法就行
    public func showToust(_ msg:String,action:String,success:Bool){
        
    }
    
    
    
    //SHPhoneAssetsToolDelegate
    func permissionDenyed(_ msg: String) {
        showToust(msg, action: currentAction, success: false);
    }
    
    
    
    //获取了一张照片
    func pickerImage(_ image: UIImage) {
        let imageData:Data = UIImageJPEGRepresentation(image, 1.0) ?? Data();
        var base64Str:String = imageData.base64EncodedString(options: .lineLength64Characters);
        base64Str = base64Str.replacingOccurrences(of: "\r\n", with: "");
        let js:String = String(format: "%@('data:image/jpeg;base64,%@');", callBackName,base64Str);
        webVC.doJs(js, dataHandler: nil, errorHandler: nil);
    }
    
    
    
    //获取了视频地址
    func pickerVedio(_ url: URL) {
        
    }
    
    
    
    
    //Private Method
    //配置右上角按钮
    private func configRightItem(jsDic:NSDictionary){
        let name:String = jsDic.value(forKey: "name") as! String;
        let iconURL:String? = jsDic.value(forKey: "icon_url") as? String;
        self.callMoreName = jsDic.value(forKey: "callback") as? String;
        if (name.count > 0) {
            webVC.naviBar.configRightBarItem(.Word, title: name, url: nil);
        }else if((iconURL ?? "").count  > 0){
            webVC.naviBar.configRightBarItem(.Icon, title: nil, url: iconURL);
        }else{
            webVC.naviBar.configRightBarItem(.Word, title: "更多", url: nil);
        }
        webVC.naviBar.moreItem.isHidden = false;
    }
    
    
    //保存图片
    private func saveImage(_ base64ImgStr:String){
        if (base64ImgStr.count == 0) {
            return;
        }
        var tmpStr:String = base64ImgStr;
        if (base64ImgStr.hasPrefix("data:image")) {
            tmpStr = base64ImgStr.components(separatedBy: ",").last ?? "";
        }
        if (tmpStr.count > 0){
            guard let imageData = Data.init(base64Encoded: tmpStr) else { return };
            let image = UIImage.init(data: imageData);
            if (image != nil) {
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(didFinishSaveImage(_:error:)), nil);
            }
        }
    }
    
    
    //保存图片回调
    @objc private func didFinishSaveImage(_ image:UIImage,error:Error?){
        if (error != nil) {
            showToust("保存失败，可在设置中开启相册存储权限或截图保存图片",action: currentAction,success: false);
            if (callBackName != nil) {
                webVC.doJs(String(format: "%@(0)", callBackName), dataHandler: nil, errorHandler: nil)
            }
        }else{
            showToust("保存成功，可在手机相册查看图片",action: currentAction,success: true);
            if (callBackName != nil) {
                webVC.doJs(String(format: "%@(1)", callBackName), dataHandler: nil, errorHandler: nil);
            }
        }
    }
    
    
    
}
