//
//  ColorWheels.swift
//  SHKit
//
//  Created by hsh on 2019/5/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import CoreImage


typealias ColorCallBack = ((_ color:UIColor)->Void)


//色环
class ColorWheel: UIView {
    //Variable
    public var choosedHide:Bool = true      //选择后隐藏
    private var hue:CGFloat = 0             //色相
    private var saturation:CGFloat = 0      //饱和度
    private var brightness:CGFloat = 1      //亮度
    private var callBack:ColorCallBack?     //颜色回调

    
    ///Interface
    //绘制色环
    public func initColorLayer(_ brightness:CGFloat = 1){
        self.brightness = brightness;
        let dimension = min(frame.width, frame.height);
        let param = ["inputColorSpace":CGColorSpaceCreateDeviceRGB(),
                     "inputDither":0,
                     "inputRadius":dimension,
                     "inputSoftness":0,
                     "inputValue":brightness] as [String : Any]
        let filter:CIFilter = CIFilter.init(name: "CIHueSaturationValueGradient", withInputParameters: param)!;
        let outputImage = filter.outputImage;
        let context:CIContext = CIContext.init(options: nil);
        let cgImg = context.createCGImage(outputImage!, from: outputImage?.extent ?? CGRect.zero);
        self.layer.contents = cgImg;
    }
    
    
    public func setCallBack(_ callBack:@escaping ColorCallBack)->Void{
        self.callBack = callBack;
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
        if choosedHide {
            self.removeFromSuperview();
        }
    }
    
    
    private func onTouchEvent(_ point:CGPoint){
        let radius:CGFloat = self.bounds.width / 2.0;
        let dist = sqrt((radius - point.x) * (radius - point.x) + (radius - point.y) * (radius - point.y));
        if (dist <= radius){
            let c:CGFloat = CGFloat(NSInteger(self.bounds.width/2.0));
            let dx = (point.x - c) / c;
            let dy = (c - point.y) / c;
            let d:CGFloat = sqrt((dx * dx + dy * dy));
            saturation = d;
            if (d == 0){
                hue = 0;
            }else{
                hue = CGFloat(acosf(Float(dx / d))) / CGFloat(Double.pi) / 2.0;
                if (dy < 0 ){
                    hue = 1.0 - hue;
                }
            }
            callBack?(UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1));
        }
    }
    
    
}
