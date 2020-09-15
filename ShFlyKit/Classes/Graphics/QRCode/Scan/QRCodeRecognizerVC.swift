//
//  QRCodeRecognizerVC.swift
//  SHKit
//
//  Created by hsh on 2019/12/31.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///二维码识别控制器
class QRCodeRecognizerVC: UIViewController ,QRCodeRecognizerDelegate{
    //Variable
    public var recognizer:QRCodeRecognizer!         //扫描视图
    public var navHide:Bool = true                  //导航栏是否隐藏
    
    
    ///Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景色
        self.view.backgroundColor = UIColor.black;
        //导航栏隐藏
        if navHide {
            self.makeNavTranslucent();
        }
        //初始化扫描视图
        recognizer = QRCodeRecognizer()
        self.view.addSubview(recognizer);
        recognizer.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        //初始化扫描
        recognizer.initCapture(self);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        //启动扫描动画
        recognizer.animateLayer.startAnimate();
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        //恢复导航栏隐藏
        if navHide {
            self.restoreNavTranslucent();
        }
    }
    
    
    
    ///继承重写这些方法
    func recognizerResult(_ result: String) {
        print(result);
        recognizer.stopCapture();
        self.navigationController?.popViewController(animated: true);
    }
    
    
    func needOpenTorchLight(_ need: Bool) {
        if need {
             recognizer.animateLayer.stopAnimate();
        }else{
             recognizer.animateLayer.startAnimate();
        }
    }
    
    
    func failRecognizer(_ ret: Int, msg: String) {
        print(msg);
    }
    
    
}
