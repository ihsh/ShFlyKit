//
//  GifFrameVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/19.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class GifFrameVC: UIViewController {

    private var imageV:UIImageView!
    private var index:Int = 0
    private var gifV:CADisplayGifImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        imageV = UIImageView()
        self.view.addSubview(imageV);
        imageV.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.view);
            maker?.centerY.mas_equalTo()(self.view)?.offset()(30);
        }
        gifV = CADisplayGifImageView.animateGifFullName("loading3.gif")
        self.view.addSubview(gifV);
        gifV.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(imageV.mas_top)?.offset()(-30);
            maker?.centerX.mas_equalTo()(imageV);
            maker?.width.height().mas_equalTo()(imageV);
        }
        
        let side = UISlider()
        side.maximumValue = Float(gifV.animatedImage.getFrameCount());
        self.view.addSubview(side);
        side.addTarget(self, action: #selector(sideValue(side:)), for: .valueChanged)
        side.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(imageV.mas_bottom)?.offset()(50);
            maker?.centerX.width().mas_equalTo()(imageV);
            maker?.height.mas_equalTo()(30);
        }
        
    }
    
    
    
    @objc private func sideValue(side:UISlider){
        let value = side.value;
        imageV.image = gifV.animatedImage.getFrameWith(UInt(value));
    }
    

    

   

}
