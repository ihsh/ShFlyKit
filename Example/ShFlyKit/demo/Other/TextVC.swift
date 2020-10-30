//
//  TextVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/22.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class TextVC: UIViewController,DisplayDelegate {
    
    private var prossL:ProgressLabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
//        let gradien = UILabel.initText("请向左滑动解锁", font: kFont(20), textColor: UIColor.black, alignment: .center, super: self.view);
//        gradien.mas_makeConstraints { (maker) in
//            maker?.top.mas_equalTo()(self.view)?.offset()(200);
//            maker?.left.right()?.mas_equalTo()(self.view);
//            maker?.height.mas_equalTo()(80);
//        }
        
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.bounds = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 60);
//        gradientLayer.position = CGPoint(x: 0, y: 100);
//
//        //决定动画方向，默认是(0.5,0),(0.5,1)
//        gradientLayer.startPoint = CGPoint(x: 0, y: 1);
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0);
//        //动画效果的颜色
//        gradientLayer.colors = [UIColor.black.cgColor,UIColor.white.cgColor,UIColor.black.cgColor];
//
//
//        let locationAnimation = CABasicAnimation(keyPath: "locations");
//        locationAnimation.fromValue = [0,0,0.25];
//        locationAnimation.toValue = [0.75,1,1];
//        locationAnimation.duration = 3;
//        locationAnimation.repeatCount = MAXFLOAT;
//
//        gradien.layer .addSublayer(gradientLayer);
//        gradientLayer.mask = gradien.layer;
//        gradientLayer.add(locationAnimation, forKey: "locations");
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        //文字路径绘制
        let str:NSString = "文字路径绘制，从左往右";
        str.animate(on: self.view, lineWidth: 0.5, rect: CGRect(x: 30, y: 100, width: 300, height: 60), font: kFont(30), color: UIColor.randomColor(), duration: 8);
        
        let label = UILabel.initText("这是一段测试文本，用来测试高亮效果，全文搜索点亮", font: kFont(14), textColor: UIColor.randomColor(), alignment: .center, super: self.view);
        label.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self.view)?.offset()(16);
            make?.right.mas_equalTo()(self.view)?.offset()(-16);
            make?.centerY.mas_equalTo()(self.view);
        }
        
        label.hightMatch("测试", color: UIColor.randomColor());
        
        
        self.prossL = ProgressLabel();
        self.prossL .setText(text: "如果多年以后，忘不掉你的笑容,我想我会奋不顾身牵起你的手\n如果多年以后厌倦了分分合合\n是否还来得及,告诉你\n是最懂我的那一个", color: UIColor.randomColor(), font: kFont(16), hightColor: UIColor.randomColor());
        self.prossL.setDuration(sec: 10);
        self.view.addSubview(self.prossL);
        self.prossL.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(label);
            make?.top.mas_equalTo()(label.mas_bottom)?.offset()(16);
        }
        HeatBeatTimer.shared.addDisplayTask(self);
    }
    

    func displayCalled() {
        if self.prossL.allProgress >= 1 {
            HeatBeatTimer.shared.cancelDisplayTask(self);
        }
        self.prossL.goForward();
    }

}
