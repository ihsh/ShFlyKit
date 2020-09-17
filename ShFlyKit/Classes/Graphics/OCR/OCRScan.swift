//
//  OcrScanVC.swift
//  SHKit
//
//  Created by hsh on 2019/2/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AipOcrSdk

//成功回调
typealias Successblock = ((_ image:UIImage?,_ result:NSDictionary)->Void)
//失败回调
typealias FailureBlock = ((_ error: Error?)->Void)


///OCR扫描证件类
class OCRScan: NSObject {
    
    
    ///MARK-Interface
    //使用AK/SK认证
    public func authWithAK(_ AK:String,SK:String)->Void{
        AipOcrService.shard()?.auth(withAK: AK, andSK: SK);
    }
    
    
    //使用license文件认证
    public func authLicense(_ name:String)->Void{
        let path:String = Bundle.main.path(forResource: name, ofType: "license") ?? "";
        do{
            let data:Data = try NSData.init(contentsOfFile: path) as Data
            AipOcrService.shard()?.auth(withLicenseFileData: data)
        }catch{}
    }
    
    
    //识别文字-每日免费5000次
    public func baseTextScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let options = ["language_type":"CHN_ENG","detect_direction":"true"];
        let vc = AipGeneralVC.viewController { (image) in
            AipOcrService.shard()?.detectTextBasic(from: image, withOptions: options, successHandler: {[unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    
    
    //精确识别文字-每日免费500次
    public func accuracyTextScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let options = ["language_type":"CHN_ENG","detect_direction":"true"];
        let vc = AipGeneralVC.viewController { (image) in
            AipOcrService.shard()?.detectTextAccurate(from: image, withOptions: options, successHandler: {[unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
                }, failHandler: { (error) in
                    self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    
    
    //身份证正面扫描-每次免费500次
    public func IDCardFrontScan(_ suc: @escaping Successblock,fail: @escaping FailureBlock)->Void{
        let vc = AipCaptureCardVC.viewController(with: .idCardFont) { (image) in
            AipOcrService.shard()?.detectIdCardFront(from: image, withOptions: nil, successHandler: {[unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    
    
    //身份证反面扫描-每次免费500次
    public func IDCardBackScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let vc = AipCaptureCardVC.viewController(with: .idCardBack) { (image) in
            AipOcrService.shard()?.detectIdCardBack(from: image, withOptions: nil, successHandler: { [unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    

    //银行卡正面扫描
    public func bankCardScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let vc = AipCaptureCardVC.viewController(with: .bankCard) { (image) in
            AipOcrService.shard()?.detectBankCard(from: image, successHandler: { [unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    
    
    //驾驶证扫描
    public func drivinglicenseScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let vc = AipGeneralVC.viewController { (image) in
            AipOcrService.shard()?.detectDrivingLicense(from: image, withOptions: nil, successHandler: { [unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }
    
    
    //行驶证扫描
    public func vehicleLicenseScan(_ suc:@escaping Successblock,fail:@escaping FailureBlock)->Void{
        let vc = AipGeneralVC.viewController { (image) in
            AipOcrService.shard()?.detectVehicleLicense(from: image, withOptions: nil, successHandler: { [unowned self] (result) in
                self.handleSuccess(suc, image: image, result: result);
            }, failHandler: { (error) in
                self.handleFail(fail, error: error);
            })
        }
        if vc != nil {
            UIViewController.top().present(vc!, animated: true, completion: nil);
        }
    }

    
    //成功回调
    private func handleSuccess(_ suc:Successblock,image:UIImage?,result:Any?)->Void{
        DispatchQueue.main.sync {
            UIViewController.top().dismiss(animated: true, completion: nil);
            let dict:NSDictionary = result as? NSDictionary ?? NSDictionary()
            suc(image,dict);
        }
    }
    
    
    //失败回调
    private func handleFail(_ fail:FailureBlock,error:Error?)->Void{
        DispatchQueue.main.sync {
            UIViewController.top().dismiss(animated: true, completion: nil);
            fail(error);
        }
    }
    
    
    
    
}
