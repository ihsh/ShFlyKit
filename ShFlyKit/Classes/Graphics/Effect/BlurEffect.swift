//
//  BlurEffectView.swift
//  SHKit
//
//  Created by hsh on 2018/11/21.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit

//创建一个高斯模糊的视图

class BlurEffect: UIView {

    
    //添加高斯模糊效果
    class public func blurEffect(effect:UIBlurEffectStyle,view:UIView)->UIVisualEffectView{
        let blurEffect = UIBlurEffect.init(style: effect);
        let blueEffectView = UIVisualEffectView.init(effect: blurEffect);
        blueEffectView.frame = view.bounds;
        view.addSubview(blueEffectView);
        return blueEffectView;
    }

}
