//
//  HandBoardVC.swift
//  SHKit
//
//  Created by hsh on 2020/1/9.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit

class HandBoardVC: UIViewController {
    public var boardV:HandBoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        //视图
        boardV = HandBoardView()
        self.view.addSubview(boardV);
        boardV.mas_makeConstraints { (make) in
            make?.left.right()?.top()?.mas_equalTo()(self.view);
            make?.bottom.mas_equalTo()(self.view)?.offset()(-50);
        }
        
        let btn = UIButton.initTitle("撤销", textColor: .black, back: .randomColor(), font: kLightFont(14), super: self.view);
        let btn2 = UIButton.initTitle("橡皮檫", textColor: .black, back: .randomColor(), font: kLightFont(14), super: self.view);
        let btn3 = UIButton.initTitle("画笔", textColor: .black, back: .randomColor(), font: kLightFont(14), super: self.view);
        let btn4 = UIButton.initTitle("取色", textColor: .black, back: .randomColor(), font: kLightFont(14), super: self.view);
        btn.mas_makeConstraints { (make) in
            make?.left.bottom()?.mas_equalTo()(self.view);
            make?.top.mas_equalTo()(boardV.mas_bottom);
            make?.width.mas_equalTo()(ScreenSize().width/4.0);
        }
        btn2.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(btn.mas_right);
            make?.height.mas_equalTo()(btn);
            make?.top.mas_equalTo()(boardV.mas_bottom);
            make?.width.mas_equalTo()(ScreenSize().width/4.0);
        }
        btn3.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(btn2.mas_right);
            make?.height.mas_equalTo()(btn);
            make?.top.mas_equalTo()(boardV.mas_bottom);
            make?.width.mas_equalTo()(ScreenSize().width/4.0);
        }
        btn4.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(btn3.mas_right);
            make?.height.mas_equalTo()(btn);
            make?.top.mas_equalTo()(boardV.mas_bottom);
            make?.width.mas_equalTo()(ScreenSize().width/4.0);
        }
        btn.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
        btn2.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
        btn3.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
        btn4.addTarget(self, action: #selector(btnClick(sender:)), for: .touchUpInside);
    }
    
    
    @objc private func btnClick(sender:UIButton){
        let text = sender.titleLabel?.text;
        if text == "撤销"{
            boardV.undoPain();
        }else if text == "橡皮檫"{
            boardV.erasePain();
        }else if text == "画笔"{
            boardV.restorePainColor();
        }else if text == "取色"{
             //取色uj环
            let wheel = ColorWheel()
            wheel.frame = CGRect(x: 20, y: 20, width: ScreenSize().width-40, height: ScreenSize().width-40);
            wheel.initColorLayer();
            let window:UIWindow = (UIApplication.shared.delegate?.window!!)!;
            window.addSubview(wheel);
            wheel.mas_makeConstraints { (make) in
                make?.center.mas_equalTo()(window);
                make?.width.height()?.mas_equalTo()(200);
            }
            wheel.setCallBack { (color) in
                self.boardV.painColor = color;
            }
        }
    }



}
