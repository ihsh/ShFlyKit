//
//  UITabbarController.swift
//  SHKit
//
//  Created by hsh on 2019/9/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///Tabbar控制器扩展
public extension UITabBarController{
    
    
    //添加子控制器
    func addChildControllers(_ vcs:[UIViewController],titles:[String],nors:[UIImage],hights:[UIImage]){
        for (index,vc) in vcs.enumerated(){
            let title = index < titles.count ? titles[index] : "";
            let nor = index < nors.count ? nors[index] : nil;
            let hight = index < hights.count ? hights[index] : nil;
            vc.tabBarItem.title = title;
            vc.tabBarItem.image = nor;
            vc.tabBarItem.selectedImage = hight;
            self.addChildViewController(vc);
        }
    }
    
    
}
