//
//  QRCodeRecognizer.swift
//  SHKit
//
//  Created by hsh on 2018/11/23.
//  Copyright © 2018 hsh. All rights reserved.
//

import CoreImage
import AVFoundation


//协议
@objc protocol QRCodeRecognizerDelegate:NSObjectProtocol {
    //识别出结果
    func recognizerResult(_ result:String);
    //识别失败
    func failRecognizer(_ ret:Int,msg:String);
    //需要打开闪光灯
    @objc optional func needOpenTorchLight(_ need:Bool);
}



///二维码扫描核心类
class QRCodeRecognizer:UIView,AVCaptureMetadataOutputObjectsDelegate,
                        AVCaptureVideoDataOutputSampleBufferDelegate,SHPhoneAssetsToolDelegate{
    //Variable
    public weak var delegate:QRCodeRecognizerDelegate?
    public private(set) var animateLayer = ScanAnimateLayer()   //动画的图层
    public private(set) var resultSet = Set<String>()           //结果集合-可清空，防误拦截
    //Private
    private var session:AVCaptureSession!
    private var videoDataOutput:AVCaptureVideoDataOutput!       //光线强弱感知
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer!   //视图预览
    private var tool = SHPhoneAssetsTool()                      //相册工具
    private var lightOpen:Bool = false                          //闪光灯是否需要打开
    
    
    ///-Interface
    //初始化扫描
    public func initCapture(_ delegate:QRCodeRecognizerDelegate?){
        
        self.delegate = delegate;
        //获取摄像设备
        let device = AVCaptureDevice.default(for: .video);
        do {
            //创建摄像设备输入流
            let deviceInput = try AVCaptureDeviceInput.init(device: device!);
            //创建元数据输出流
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main);
            //设置扫描范围，每一个取值是0-1，如果不需要设置就不设置
//            metadataOutput.rectOfInterest = CGRect(x: 0.05, y: 0.2, width: 0.7, height: 0.6)
            //创建会话对象
            session = AVCaptureSession()
            //设置会话采集率
            session.sessionPreset = .hd1920x1080;
            //添加元数据输出流到会话对象
            session.addOutput(metadataOutput);
            //创建摄像数据输出流并将其添加到会话对象上-用于识别光线强弱
            videoDataOutput = AVCaptureVideoDataOutput();
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main);
            session.addOutput(videoDataOutput);
            //添加摄像设备输入流到会话对象
            session.addInput(deviceInput);
            //设置数据输出类型(条形码，二维码兼容),不要全写
            metadataOutput.metadataObjectTypes = [.qr,.ean13,.ean8,.code128];
            //实例化预览图层，用于显示会话对象
            videoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: session);
            //保持纵横比
            videoPreviewLayer.videoGravity = .resizeAspectFill;
            videoPreviewLayer.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
            self.layer.insertSublayer(videoPreviewLayer, at: 0);
            //动画图层
            animateLayer.backgroundColor = .clear;
            self.addSubview(animateLayer);
            animateLayer.mas_makeConstraints { (make) in
                make?.left.right()?.top()?.bottom()?.mas_equalTo()(self);
            }
            //启动会话
            session.startRunning();
        } catch _ {
            delegate?.failRecognizer(-1, msg: "启动扫描失败");
        }
    }

    
    //停止扫描
    public func stopCapture(){
        session.stopRunning();
        resultSet.removeAll();
    }

    
    //本地相册选择识别
    public func localImageRecognize(){
        tool.delegate = self;
        tool.holdVC = UIViewController.getCurrentVC();
        tool.useSystemCamera(type: .ChoosePhoto);
    }
    
    
    
    ///Delegate
    //识别的结果
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            let obj:AVMetadataMachineReadableCodeObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject;
            let str = obj.stringValue ?? "";
            //防止重复
            if resultSet.contains(str) == false {
                resultSet.insert(str);
                delegate?.recognizerResult(str);
            }
        }else{
            //暂未识别出
            delegate?.failRecognizer(0,msg: "没有识别出来")
        }
    }
    
    
    //光线强弱
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metaDataDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate) else { return };
        let metaData = NSMutableDictionary.init(dictionary: metaDataDict);
        let exifData:NSDictionary = metaData.object(forKey: kCGImagePropertyExifDictionary) as! NSDictionary;
        let brightness:NSNumber = exifData.object(forKey: kCGImagePropertyExifBrightnessValue) as! NSNumber;
        //光线值是否需要开灯
        var need = false;
        if brightness.floatValue < -1 {
            need = true;
        }
        //是否需要更改
        if need != lightOpen {
            delegate?.needOpenTorchLight?(need);
            lightOpen = need;
        }
    }
    
    
    //识别照片
    func pickerImage(_ image: UIImage) {
        //声明一格CIDetector,并设定识别类型CIDetectorTypeQRCode
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh]);
        
        let cgimage = image.cgImage;
        if cgimage != nil {
            let ciimage:CIImage? = CIImage(cgImage: cgimage!);
            if ciimage != nil {
                let fecture = detector?.features(in: ciimage!);
                if fecture?.count ?? 0 > 0 {
                    for i in 0...fecture!.count-1{
                        let fea:CIQRCodeFeature = fecture![i] as! CIQRCodeFeature;
                        delegate?.recognizerResult(fea.messageString ?? "");
                    }
                }
            }
        }else{
            delegate?.failRecognizer(0,msg: "没有识别出来")
        }
    }
    
    
    func permissionDenyed(_ msg: String) {
        delegate?.failRecognizer(1, msg: "没有相册权限");
    }
    
    
    deinit {
        stopCapture();
    }

    
}






