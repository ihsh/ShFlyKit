//
//  WeatherEffect.swift
//  SHKit
//
//  Created by hsh on 2020/1/4.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import Masonry

///天气效果视图
public class WeatherEffect: IgnoreTouchView {
    //Variable
    private var emiterV:IgnoreTouchView!
    
    
    ///Interface
    //清除所有
    public func clearViewsAndLayers(){
        //移除图层
        for layer in self.layer.sublayers ?? [] {
            layer.removeFromSuperlayer();
        }
        for sub in self.subviews {
            sub.removeFromSuperview();
        }
    }
    
    
    //太阳和耀斑
    public func sunShine(config:WeatherConfig.Sun){
        //光斑
        if config.shineImage != nil {
            let shineV = UIImageView.init(image: config.shineImage);
            shineV.frame = CGRect(x: 0, y: 0, width: config.shineWidth, height: config.shineWidth);
            shineV.center = config.center;
            self.addSubview(shineV);
            shineV.layer.add(rotationAnimation(duration: config.rotationDuration), forKey: nil);
        }
        //太阳
        let sunV = UIImageView.init(image: config.sunImage);
        sunV.frame = CGRect(x: 0, y: 0, width: config.sunWidth, height: config.sunWidth);
        sunV.center = config.center;
        self.addSubview(sunV);
        sunV.layer.add(rotationAnimation(duration: config.rotationDuration), forKey: nil);
    }
    
    
    //下雪
    public func snowFlow(config:WeatherConfig.Snow){
        //指定数量
        for i in 0...config.count {
            let snow = UIImageView.init(image:config.image);
            snow.frame = CGRect(x: CGFloat(arc4random() % config.xRange),
                                y: CGFloat(arc4random() % config.yRange),
                                width: CGFloat(arc4random() % config.widthRange + config.baseWidth),
                                height: CGFloat(arc4random() % config.widthRange + config.baseWidth));
            self.addSubview(snow);
            //移动
            snow.layer.add(transAnimation(duration: CGFloat(i%config.rangeDuration+config.baseDuration),
                                          from: config.from,
                                          to: CGPoint(x: CGFloat(arc4random()%UInt32(ScreenSize().width)),
                                                      y: config.toY)), forKey: nil);
            //不透明度
            snow.layer.add(alphaAnimation(duration: CGFloat(i%config.rangeDuration+config.baseDuration)), forKey: nil);
            //旋转
            snow.layer.add(rotationAnimation(duration: CGFloat(config.rotateDuration)), forKey: nil);
        }
    }
    
    
    //闪电视图
    public func thunderFlash(config:WeatherConfig.Thunder){
        let thunderV = WeatherThunder();
        thunderV.config = config;
        self.addSubview(thunderV);
        thunderV.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        thunderV.startAnimation();
    }
    
    
    //下雨
    public func rain(config:WeatherConfig.Rain){
        
        for i in 0...config.count {
            let randomIndex = Int(arc4random()%config.images) + 1;
            let rainLineV = UIImageView.init(image: UIImage.name(String(format: "%@%ld.png",config.imagePrefix, randomIndex), cls: WeatherEffect.self, bundleName: "Graphics"));
            
            if randomIndex == 1{
                rainLineV.frame = CGRect(x: CGFloat(arc4random()%300) * ScreenSize().width / 320.0,
                                         y: CGFloat(arc4random()%400+150), width: 60, height: 218);
            }else if randomIndex == 2 {
                rainLineV.frame = CGRect(x: CGFloat(arc4random()%300) * ScreenSize().width / 320.0,
                                         y: CGFloat(arc4random()%400+150), width: 33, height: 118);
            }else{
                rainLineV.frame = CGRect(x: CGFloat(arc4random()%300) * ScreenSize().width / 320.0,
                                         y: CGFloat(arc4random()%400+150), width: 33, height: 118);
            }
            self.addSubview(rainLineV);
            rainLineV.layer.add(transAnimation(duration: CGFloat(config.timeBase+i%config.timeRange),
                                               from: config.from,
                                               to: config.to), forKey: nil);
            rainLineV.layer.add(alphaAnimation(duration: CGFloat(config.timeBase+i%config.timeRange)), forKey: nil);
        }
    }
    

    //使用粒子方式展示
    public func showEmitter(config:EmitterConfig){
        //图片是否设置了
        if config.content != nil {
            
            let emitter = CAEmitterLayer()
            //发射源的形状-顶部一条线
            emitter.emitterShape = kCAEmitterLayerLine;
            //发射模式
            emitter.emitterMode = kCAEmitterLayerSurface;
            //发射源的size
            emitter.emitterSize = config.size;
            //发射源的位置
            emitter.emitterPosition = config.position;
            //用于限制粒子显示范围
            if emiterV == nil {
                self.emiterV = IgnoreTouchView()
                self.emiterV.backgroundColor = .clear;
                self.addSubview(self.emiterV);
                self.emiterV.clipsToBounds = true;
                self.emiterV.mas_makeConstraints { (make) in
                    make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
                }
            }
            //添加到视图上
            self.emiterV.layer.addSublayer(emitter);
            
            let cell = CAEmitterCell()
            //图片
            cell.contents = config.content.cgImage;
            //粒子每秒产生
            cell.birthRate = config.birthRate;
            //粒子生命周期
            cell.lifetime = config.lifeTime;
            //粒子生命周期范围
            cell.lifetimeRange = 0.8;
            //粒子速度
            cell.velocity = config.velocity;
            //粒子速度范围
            cell.velocityRange = config.velocityRange;
            //Y轴加速度
            cell.yAcceleration = config.yAcceleration;
            //初始方向
            cell.emissionLongitude = config.emissionLongitude;
            //自旋速度
            cell.spin = config.spin;
            //图片缩放
            cell.scale = config.scale;
            cell.scaleRange = config.scaleRange;
            //如果定义多种cell，并且一个cell是另一种cell的emitterCells，则动画会一个接一个
            emitter.emitterCells = [cell];
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    //添加云彩
    public func addCloud(isRain:Bool,count:Int,
                         mixColor:UIColor = UIColor.colorRGB(red: 0, green: 51, blue: 86),y:CGFloat = 50){
        
        var temp:[NSNumber] = [];
        let maxCount:Int = 11;
        //最大数量的云
        if count == maxCount {
            for i in 0...maxCount {
                temp.append(NSNumber.init(value: i));
            }
            temp.sort { (obj1, obj2) -> Bool in
                if (Int(arc4random()) % 2) > 0 {
                    return obj1.intValue > obj2.intValue;
                }else{
                    return obj2.intValue > obj1.intValue;
                }
            }
        }else{
            var rows:[Int] = [];
            for _ in 0...count-1 {
                while 1 > 0 {
                    let indexRow = Int(arc4random()) % maxCount;
                    if rows.contains(indexRow) == false {
                        rows.append(indexRow);
                        temp.append(NSNumber.init(value: indexRow));
                        break;
                    }else{//当传入的数字大于最大值，就肯定会有重复的
                        break;
                    }
                }
            }
        }
        
        for (i,num) in temp.enumerated() {
            var cloudImage:UIImage?
            if isRain {
                cloudImage = mixImage(name: String(format:"ele_white_cloud_%ld.png", num.intValue), color: mixColor);
            }else{
                cloudImage = UIImage.name(String(format:"ele_white_cloud_%ld.png", num.intValue), cls: WeatherEffect.self, bundleName: "Graphics");
            }
            let offsetX:CGFloat = CGFloat(i * 3 / count - 1) * ScreenSize().width;
            if cloudImage != nil {
                let cloundV = UIImageView.init(image: cloudImage);
                cloundV.frame = CGRect(x: 0, y: 0, width: 200.0 * cloudImage!.size.width/cloudImage!.size.height, height: 200);
                cloundV.center = CGPoint(x: offsetX, y: y);
                cloundV.layer.add(cloudAnimation(from: NSNumber.init(value: Float(offsetX)), to: NSNumber.init(value: 3), duration: 100), forKey: nil);
                self.addSubview(cloundV);
            }
        }
    }
    
 
    
    ///云朵移动
    public func cloudAnimation(from:NSNumber,to:NSNumber,duration:CGFloat)->CAAnimationGroup{
        let keyAnim = CAKeyframeAnimation.init(keyPath: "transform.translation.x");
        var temp:[NSNumber] = [];
        let count:CGFloat = 3
        let compare:CGFloat = 2 * ScreenSize().width;
        for i in 0...30 {
            var offset:CGFloat = CGFloat(i)/30.0 * CGFloat(to.floatValue) * ScreenSize().width;
            if (offset + CGFloat(from.floatValue)) < compare {
                temp.append(NSNumber.init(value: Float(offset)));
            }else{
                while (offset + CGFloat(from.floatValue)) > compare {
                    offset = offset - count * ScreenSize().width;
                }
                temp.append(NSNumber.init(value: Float(offset)));
            }
        }
        temp.append(NSNumber.init(value: 0));
        keyAnim.values = (NSArray.init(array: temp) as! [Any]);
        
        let group = CAAnimationGroup();
        group.duration = CFTimeInterval(duration);
        group.animations = [keyAnim];
        group.autoreverses = false;
        group.repeatCount = MAXFLOAT;
        group.isRemovedOnCompletion = false;
        group.fillMode = kCAFillModeForwards;
        return group;
    }
    
    
    //水平移动
    public func flyAnimation(toValue:NSNumber,duration:CGFloat)->CABasicAnimation{
        let base = CABasicAnimation()
        base.keyPath = "transform.translation.x";
        base.toValue = toValue;
        base.duration = CFTimeInterval(duration);
        base.autoreverses = false;
        base.isRemovedOnCompletion = false;
        base.repeatCount = MAXFLOAT;
        base.fillMode = kCAFillModeForwards;
        return base;
    }
    
    
    //位置移动
    public func transAnimation(duration:CGFloat,from:CGPoint,to:CGPoint)->CABasicAnimation{
        let base = CABasicAnimation();
        base.duration = CFTimeInterval(duration);
        base.keyPath = "transform";
        base.repeatCount = MAXFLOAT;
        base.isRemovedOnCompletion = false;
        base.fillMode = kCAFillModeForwards;
        base.fromValue = NSValue.init(caTransform3D: CATransform3DMakeTranslation(from.x, from.y, 0))
        base.toValue = NSValue.init(caTransform3D: CATransform3DMakeTranslation(to.x, to.y, 0))
        return base;
    }
    
    
    //不透明度变化
    public func alphaAnimation(duration:CGFloat)->CABasicAnimation{
        let base = CABasicAnimation()
        base.keyPath = "opacity";
        base.fromValue = NSNumber.init(value: 1.0);
        base.toValue = NSNumber.init(value: 0.1);
        base.duration = CFTimeInterval(duration);
        base.repeatCount = MAXFLOAT;
        base.fillMode = kCAFillModeForwards;
        base.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut);
        base.isRemovedOnCompletion = false;
        return base;
    }
    
    
    //Z轴旋转
    public func rotationAnimation(duration:CGFloat)->CABasicAnimation{
        let base = CABasicAnimation();
        base.keyPath = "transform.rotation.z";
        base.fromValue = NSNumber.init(value: 0);
        base.toValue = NSNumber.init(value: 2.0*Double.pi);
        base.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut);
        base.duration = CFTimeInterval(duration);
        base.repeatCount = MAXFLOAT;
        base.isCumulative = false;
        base.isRemovedOnCompletion = false;
        base.fillMode = kCAFillModeForwards;
        return base;
    }
    
    
    //图片混合颜色
    public func mixImage(name:String,color:UIColor)->UIImage?{
        let image:UIImage? = UIImage.name(name, cls: WeatherEffect.self, bundleName: "Graphics").withRenderingMode(.alwaysTemplate);
        if image != nil {
            UIGraphicsBeginImageContextWithOptions(image!.size, false, image!.scale);
            color.set();
            image!.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height));
            let result = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return result;
        }
        return image;
    }
    

}


