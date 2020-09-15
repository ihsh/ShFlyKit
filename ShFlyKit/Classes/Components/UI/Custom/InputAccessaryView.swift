//
//  InputAccessaryView.swift
//  SHKit
//
//  Created by hsh on 2019/9/26.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry


///输入视图的键盘accessary
class InputAccessaryView: UIView {
    ///Variable
    public var backColor:UIColor = UIColor.colorHexValue("F3F4F5")
    public var cancelBtn:UIButton!
    public var comfirmBtn:UIButton!

    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = backColor;
        self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 40);
        
        cancelBtn = UIButton.initTitle("取消", textColor: UIColor.colorHexValue("4a4a4a"), back: UIColor.clear, font: kFont(14), super: self);
        cancelBtn.addTarget(self, action: #selector(hideKeyBoard), for: .touchUpInside);
        cancelBtn.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(16);
            maker?.centerY.mas_equalTo()(self);
        }
        
        comfirmBtn = UIButton.initTitle("完成", textColor: UIColor.colorHexValue("f16622"), back: UIColor.clear, font: kFont(14), super: self);
        comfirmBtn.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-16);
            maker?.centerY.mas_equalTo()(cancelBtn);
        }
        comfirmBtn.addTarget(self, action: #selector(hideKeyBoard), for: .touchUpInside);
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //退出键盘
    @objc private func hideKeyBoard(){
        let window = UIApplication.shared.delegate?.window;
        for view in window!!.subviews{
            view.endEditing(true);
        }
    }
    
    
}
