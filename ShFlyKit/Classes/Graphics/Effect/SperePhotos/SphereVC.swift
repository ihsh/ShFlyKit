//
//  SphereVC.swift
//  SHKit
//
//  Created by hsh on 2020/1/3.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import Masonry

///立体相册控制器
class SphereVC: UIViewController {
    //variable
    private var sphereV:SphereView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sphereV = SphereView()
        sphereV.backgroundColor = .white;
        self.view.addSubview(sphereV);
        self.view.backgroundColor = .white;
        sphereV.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self.view);
            make?.width.height()?.mas_equalTo()(340);
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        var array:[UIView] = []
        for _ in 0...52 {
            let btn = UIImageView()
            let image:UIImage = UIImage.name("piggy.JPG");
            btn.image = image;
            btn.frame = CGRect(x: 0, y: 0, width: 60, height: 60);
            array.append(btn);
            sphereV.addSubview(btn);
        }
        sphereV.setViews(array: array);
    }

}
