//
//  UIViewExtention.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


extension UIView{
    
    //清除当前子视图
    func clearSubviews(){
        for sub in self.subviews{
            sub.removeFromSuperview();
        }
    }
    
    
}
