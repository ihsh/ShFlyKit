//
//  ImageColorFetch.swift
//  SHKit
//
//  Created by hsh on 2019/5/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry

public typealias ImageColorCallBack = ((_ color:UIColor)->Void)
//图片颜色取色器
public class ImageColorFetch: UIView {
    //Variable
    public var imageView:UIImageView!
    public var indicateView:UIView?
    private var callBack:ImageColorCallBack?     //颜色回调
    
    //设置图片
    public func setImage(_ image:UIImage){
        if (imageView == nil){
            imageView = UIImageView()
            self.addSubview(imageView);
            imageView.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
            }
            imageView.isUserInteractionEnabled = true;
        }
        imageView.image = image;
    }
    
    
    public func setCallBack(_ callBack:@escaping ImageColorCallBack)->Void{
        self.callBack = callBack;
    }
    
    
    //Touch事件
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        onTouchEvent(point);
    }
    
    
    private func onTouchEvent(_ point:CGPoint){
        let pos = convert(point, to: self);
        let color = imageView.image?.color(atPixel: pos, rect: self.frame);
        indicateView?.backgroundColor = color;
        callBack?(color ?? UIColor.white);
    }
    
    
}
