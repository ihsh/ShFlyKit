//
//  IgnoreTouchView.swift
//  SHKit
//
//  Created by hsh on 2020/1/8.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//忽略所有操作到下层视图
class IgnoreTouchView: UIView {

    
    //想避开自己,触控传递，需要在该视图里面写hitTest方法
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event);
        //如果点击在当前视图，则透过到下层
        if hitView?.isKind(of: type(of: self)) ?? false {
            return nil;
        }
        return hitView;
    }

    
}
