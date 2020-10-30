//
//  JiYanVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/15.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//极验测试例子
class JiYanVC: JiYanBaseVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.configInit(api1: "http://www.geetest.com/demo/gt/register-slide", api2: "http://www.geetest.com/demo/gt/validate-slide", timeOut: 5, maskColor: UIColor.colorHexValue("000000", alpha: 0.6));
        
        self.view.addSubview(captchBtn);
        captchBtn.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(self.view);
            maker?.width.mas_equalTo()(260);
            maker?.height.mas_equalTo()(40);
        }
    }
    

}
