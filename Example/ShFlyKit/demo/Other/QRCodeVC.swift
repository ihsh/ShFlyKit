//
//  QRCodeVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/9.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class QRCodeVC: UIViewController {

    private var imageV:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;

        imageV = UIImageView()
        self.view.addSubview(imageV);
        imageV.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(self.view);
            maker?.width.height()?.mas_equalTo()(240);
        }
        
        
        let imageV2 = UIImageView()
        self.view.addSubview(imageV2);
        imageV2.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(imageV.mas_bottom)?.offset()(50);
            maker?.left.mas_equalTo()(self.view)?.offset()(16);
            maker?.right.mas_equalTo()(self.view)?.offset()(-16);
            maker?.height.mas_equalTo()(50);
        }
        QRCodeGenerator.generateBarCode(content: "order19310168531107?$%#@$#!sdf__", imageV: imageV2, size: CGSize(width: ScreenSize().width-32, height: 50));
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        QRCodeGenerator.generateColorQRCode(content: "order19310168531107", imageV: imageV, width: 240, color: UIColor.randomColor());
    }

    
}
