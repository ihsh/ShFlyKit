//
//  ColorWheelVC.swift
//  SHKit
//
//  Created by hsh on 2019/5/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class ColorWheelVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        let main:UIView = UIScreenFit.createMainView();
        self.view.addSubview(main);
        
        let wheel = ColorWheel()
        wheel.choosedHide = false;
        wheel.frame = CGRect(x: 20, y: 20, width: ScreenSize().width-40, height: ScreenSize().width-40);
        main.addSubview(wheel);
        wheel.initColorLayer();
        
        
        let view = UIView()
        main.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(main);
            maker?.top.mas_equalTo()(wheel.mas_bottom)?.offset()(150);
            maker?.width.mas_equalTo()(200);
            maker?.height.mas_equalTo()(60);
        }
//        wheel.indicateView = view;
        //设置颜色回调
        wheel.setCallBack { (color) in
            view.backgroundColor = color;
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
    }

}
