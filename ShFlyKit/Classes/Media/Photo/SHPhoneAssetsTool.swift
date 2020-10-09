//
//  SHPhoneAssetsTool.swift
//  SHKit
//
//  Created by hsh on 2019/6/6.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


//相机工具代理
@objc protocol SHPhoneAssetsToolDelegate:NSObjectProtocol {
    func permissionDenyed( _ msg:String);                       //没有权限
    @objc optional func pickerImage(_ image:UIImage)            //获取了一个图片
    @objc optional func pickerImageUrl(_ url:URL?)              //获取图片的URL
    @objc optional func pickerVedio(_ url:URL)                  //获取了一个视频
}


//多媒体类型
enum AssetType {
    case TakePhoto,ChoosePhoto,RecordMovie,ChooseMovie          //照相，相册选择照片，录像，相册选择视频
}


//调用相机相册工具类
class SHPhoneAssetsTool: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //Variable
    public var holdVC:UIViewController?                          //支撑的VC
    public var maxMovieDuration:TimeInterval = 10;               //录像最大时常
    public weak var delegate:SHPhoneAssetsToolDelegate?          //代理
    public var savedPhotosAlbum:Bool = false                     //是否保存到相册
    public var cameraFront:Bool = false                          //默认后置
    
    
    //Interface
    //拍照选择
    public func cameraPhotoAlert(vc:UIViewController){
        self.holdVC = vc;
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet);
        alertVC.addAction(UIAlertAction(title: "拍照", style: .default, handler: { (action) in
            self.useSystemCamera(type: .TakePhoto);
        }));
        alertVC.addAction(UIAlertAction(title: "从相册选取", style: .default, handler: { (action) in
            self.useSystemCamera(type: .ChoosePhoto);
        }));
        alertVC.addAction(UIAlertAction(title: "取消", style: .default, handler: { (action) in  }));
        DispatchQueue.main.async {
            self.holdVC?.present(alertVC, animated: true, completion: nil);
        }
    }
    
    
    
    public func cameraMovieAlert(vc:UIViewController){
        self.holdVC = vc;
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet);
        alertVC.addAction(UIAlertAction(title: "录制", style: .default, handler: { (action) in
            self.useSystemCamera(type: .RecordMovie);
        }));
        alertVC.addAction(UIAlertAction(title: "从视频库选取", style: .default, handler: { (action) in
            self.useSystemCamera(type: .ChooseMovie);
        }));
        alertVC.addAction(UIAlertAction(title: "取消", style: .default, handler: { (action) in  }));
        DispatchQueue.main.async {
            self.holdVC?.present(alertVC, animated: true, completion: nil);
        }
    }

    
    
    //使用系统相机
    public func useSystemCamera(type:AssetType){
        let cameraEnable = checkCameraAuthorised().0;
        let photoEnable = checkPhotoAuthorised().0;
        let cameraVC = UIImagePickerController()
        cameraVC.videoQuality = .typeHigh;
        
        if (type == .TakePhoto){
            cameraVC.sourceType = .camera;
            cameraVC.cameraDevice = cameraFront ? .front : .rear
            //可用或者未确定
            if (cameraEnable || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined) {
                AVCaptureDevice.requestAccess(for: .video) { (allowed) in
                    if (allowed){
                        DispatchQueue.main.async(execute: {
                            cameraVC.delegate = self;
                            self.holdVC?.present(cameraVC, animated: true, completion: nil);
                        })
                    }else{
                        self.delegate?.permissionDenyed(self.checkCameraAuthorised().1);
                    }
                }
            }else{
                delegate?.permissionDenyed(checkCameraAuthorised().1);
            }
        }else if (type == .ChoosePhoto){
            cameraVC.sourceType = .photoLibrary;
            //可用或者未确定
            if (photoEnable || PHPhotoLibrary.authorizationStatus() == .notDetermined) {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if (status == .authorized) {
                        DispatchQueue.main.async(execute: {
                            cameraVC.delegate = self;
                            self.holdVC?.present(cameraVC, animated: true, completion: nil);
                        })
                    }else{
                        self.delegate?.permissionDenyed(self.checkPhotoAuthorised().1);
                    }
                }
            }else{
                delegate?.permissionDenyed(checkPhotoAuthorised().1);
            }
        }else if (type == .RecordMovie){
            cameraVC.sourceType = .camera;
            cameraVC.cameraDevice = cameraFront ? .front : .rear
            let avaiMedia = UIImagePickerController.availableMediaTypes(for: .camera);
            if (avaiMedia!.count > 1) {
                cameraVC.mediaTypes = [avaiMedia![1]];      //选择public.movie，0是public.image
                cameraVC.videoMaximumDuration = maxMovieDuration;
                //可用或者未确定
                if (cameraEnable || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined) {
                    AVCaptureDevice.requestAccess(for: .video) { (allowed) in
                        if (allowed){
                            DispatchQueue.main.async(execute: {
                                cameraVC.delegate = self;
                                self.holdVC?.present(cameraVC, animated: true, completion: nil);
                            })
                        }else{
                            self.delegate?.permissionDenyed(self.checkCameraAuthorised().1);
                        }
                    }
                }else{
                    delegate?.permissionDenyed(checkCameraAuthorised().1);
                }
            }
        }else if (type == .ChooseMovie) {
            cameraVC.sourceType = .photoLibrary;
            let avaiMedia = UIImagePickerController.availableMediaTypes(for: .camera);
            if (avaiMedia!.count > 1) {
                cameraVC.mediaTypes = [avaiMedia![1]];
                if (photoEnable || PHPhotoLibrary.authorizationStatus() == .notDetermined){
                    PHPhotoLibrary.requestAuthorization { (status) in
                        if (status == .authorized) {
                            DispatchQueue.main.async(execute: {
                                cameraVC.delegate = self;
                                self.holdVC?.present(cameraVC, animated: true, completion: nil);
                            })
                        }else{
                            self.delegate?.permissionDenyed(self.checkPhotoAuthorised().1);
                        }
                    }
                }else{
                    delegate?.permissionDenyed(checkPhotoAuthorised().1);
                }
            }
        }
    }
    
    
    //取消选择
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    
    
    //获取图片或者视频
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let key:String = info[UIImagePickerControllerMediaType] as! String;
        if (key == "public.image") {
            let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage;
            var url:URL?
            if #available(iOS 11.0, *) {
                url = info[UIImagePickerControllerImageURL] as! URL
            } else {
                // Fallback on earlier versions
            };
            if savedPhotosAlbum{
                image.savePhotoToAlbum();
            }
            delegate?.pickerImageUrl?(url);
            delegate?.pickerImage?(image);
        }else if (key == "public.movie") {
            let url:URL = info[UIImagePickerControllerMediaURL] as! URL;
            if savedPhotosAlbum{
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil);
            }
            delegate?.pickerVedio?(url);
        }
        picker.dismiss(animated: true, completion: nil);
    }
    
    
    
    //相机权限检测
    public func checkCameraAuthorised()->(Bool,String){
        let status:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video);
        if status == .authorized {
            return (true,"相机权限已授权");
        }else if (status == .denied){
            return (false,"相机权限已拒绝");
        }else if (status == .notDetermined){
            return (false,"相机权限未决定");
        }else if (status == .restricted){
            return (false,"用户不能使用");
        }else{
            return (false,"");
        }
    }
    
    
    //相册权限检测
    public func checkPhotoAuthorised()->(Bool,String){
        if #available(iOS 11.0, *) {
            return (true,"相册权限已打开");
        }else{
            let status:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus();
            if status == .authorized {
                return (true,"相机权限已授权");
            }else if (status == .denied){
                return (false,"相机权限已拒绝");
            }else if (status == .notDetermined){
                return (false,"相机权限未决定");
            }else if (status == .restricted){
                return (false,"用户不能使用");
            }else{
                return (false,"");
            }
        }
    }
    
    
}
