//
//  GradientLayerVC.swift
//  SHKit
//
//  Created by hsh on 2018/11/12.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit

class GradientLayerVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        let imageV = UIImageView();
        self.view.addSubview(imageV);
        imageV.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(self.view)?.offset()(80);
            maker?.width.height()?.mas_equalTo()(350);
        }
//        QRCodeGenerator.generateLogoQRCode(content: "sn193932y3723917", imageV: imageV, width: 350, logo: UIImage.name("hezhao"), logoSize: CGSize(width: 50, height: 50), color: UIColor.colorHexValue(hexStr: "283927"), radius: 5);
//

//        let generator = EFQRCodeGenerator(content: "nihaosn1802830283$", size: EFIntSize(width: 350, height: 350));
//        generator.setInputCorrectionLevel(inputCorrectionLevel: EFInputCorrectionLevel.h)
//        generator.setMode(mode: .none)
//        generator.setMagnification(magnification: EFIntSize(width: 9, height: 9))
//        generator.setColors(backgroundColor: CIColor(color: UIColor.white), foregroundColor: CIColor(color: UIColor.black))
//        generator.setForegroundPointOffset(foregroundPointOffset: 0)
//        generator.setAllowTransparent(allowTransparent: true)
//        generator.setBinarizationThreshold(binarizationThreshold: 0.5)
//        generator.setPointShape(pointShape: .square)
        
        
        
//        let cgimage = generator.generate();
//        let image = UIImage(cgImage: cgimage!);
//        imageV.image = image;
        
//        let imageBar = UIImageView()
//        self.view.addSubview(imageBar);
//        imageBar.mas_makeConstraints { (maker) in
//            maker?.centerX.mas_equalTo()(self.view);
//            maker?.width.mas_equalTo()(300);
//            maker?.height.mas_equalTo()(90);
//            maker?.top.mas_equalTo()(imageV.mas_bottom)?.offset()(20);
//        }
//        QRCodeGenerator.generateBarCode(content: "19027393629363282", imageV: imageBar, size: CGSize(width: 300, height: 90));
//
//        BlurEffect.blurEffect(effect: UIBlurEffectStyle.light, view: imageV)
        
        let emiterCell:CAEmitterCell = CAEmitterCell()
        //展示的图片
        emiterCell.contents = UIImage.name("xin2", cls: GradientLayerVC.self, bundleName: "Components").cgImage;
        //每秒粒子产生个数的乘数因子，会与layer的birthRate相乘，然后确定每秒产生的粒子个数
        emiterCell.birthRate = 20;
        //每个粒子存活时长
        emiterCell.lifetime = 10.0
        //粒子生命周期范围
        emiterCell.lifetimeRange = 1;
        //粒子透明度变化，设置为-0.4，则每过一秒透明度减0.4,这样就有消失效果
        emiterCell.alphaSpeed = -0.1;
        emiterCell.alphaRange = 0.5;
        //粒子的速度
        emiterCell.velocity = 100;
        //粒子的速度范围
        emiterCell.velocityRange = 20;
        //周围发射的角度，如果为M_PI*2,就可以从360度任意位置发射
//        emiterCell.emissionRange = M_PI*2;
        //粒子的内容颜色
        emiterCell.color = UIColor.randomColor().cgColor;
        //设置颜色变化·范围后每次产生的粒子的颜色都是随机的
        emiterCell.redRange = 0.5;
        emiterCell.greenRange = 0.5;
        emiterCell.blueRange = 0.5;
        emiterCell.redSpeed = 0.5;
        emiterCell.greenSpeed = 0.5;
        emiterCell.blueSpeed = 0.5;
        //缩放比例
        emiterCell.scale = 0.15;
        //缩放比例范围
        emiterCell.scaleRange = 0.02;
        //粒子初始发射方向
        emiterCell.emissionLongitude = CGFloat(Double.pi);
        //X方向加速度
//        emiterCell.xAcceleration = 20;

        let emitLayer = CAEmitterLayer()
        //发射位置
        emitLayer.emitterPosition = CGPoint(x: ScreenSize().width/2.0, y: 0);
        //粒子产生系数，默认1
        emitLayer.birthRate = 1;
        //发射器c尺寸
        emitLayer.emitterSize = CGSize(width: ScreenSize().width, height: 0);
        //发射形状
        emitLayer.emitterShape = kCAEmitterLayerLine
        //发射的模式
        emitLayer.emitterMode = kCAEmitterLayerLine;
        //渲染模式
        emitLayer.renderMode = kCAEmitterLayerOldestFirst;
        emitLayer.masksToBounds = false;
        emitLayer.emitterCells = [emiterCell];
        self.view.layer.addSublayer(emitLayer);
        
        
        
    }
    

    

}
