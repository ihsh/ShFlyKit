//
//  SearchTextField.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///简单的搜索输入栏
public class SearchTextFieldV: UIView , UITextFieldDelegate{
    //Variable
    public var leftRight:CGFloat = 30                                   //左右边距
    public var topMargin:CGFloat = 12                                   //距顶部距离
    public var backColor:UIColor = .white                               //背景颜色
    public var textFieldBackColor = UIColor.colorHexValue("F3F4F5")     //文本背景颜色
    public var textColor:UIColor = UIColor.colorHexValue("4A4A4A")      //文字颜色
    public var cornerRadius:CGFloat = 20                                //圆角
    public var inputHeight:CGFloat = 40                                 //输入框的高度
    public var cancelColor:UIColor = UIColor.colorHexValue("4A4A4A")    //取消按钮文字颜色
    public var textFont:UIFont = kFont(14)                              //输入框文本字号
    public var textFiled:DelayTextField!                                //延迟确认输入文本框
    private var cancelBtn:UIButton!                                     //取消按钮
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = backColor;
        //延迟确认输入文本框
        textFiled = DelayTextField()
        textFiled.delegate = self;
        textFiled.textColor = textColor;
        textFiled.layer.cornerRadius = cornerRadius;
        textFiled.layer.masksToBounds = true;
        textFiled.backgroundColor = textFieldBackColor;
        textFiled.font = textFont;
        textFiled.frame = CGRect(x: leftRight, y: topMargin, width: ScreenSize().width - leftRight * 2, height: inputHeight);
        self.addSubview(textFiled);
        textFiled.inputAccessoryView = InputAccessaryView()
        //取消按钮
        cancelBtn = UIButton.initTitle("取消", textColor: cancelColor, back: UIColor.clear, font: kFont(14), super: self);
        cancelBtn.isHidden = true;
        cancelBtn.addTarget(self, action: #selector(endEidt), for: .touchUpInside);
        cancelBtn.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-20);
            maker?.centerY.mas_equalTo()(textFiled);
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func initPlaceHolder(_ str:String?,attribute:NSAttributedString?){
        if attribute != nil {
            textFiled.attributedPlaceholder = attribute;
        }else{
            textFiled.placeholder = str;//低系统版本设置了placeholder再设置attributedPlaceholder会出现无效
        }
    }
    
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            textField.frame = CGRect(x: self.leftRight, y: self.topMargin, width: ScreenSize().width - self.leftRight * 2 - 45, height: self.inputHeight);
        }) { (_) in
            self.cancelBtn.isHidden = false;
        }
    }
    
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        cancelBtn.isHidden = true;
        UIView.animate(withDuration: 0.3) {
            self.textFiled.frame = CGRect(x: self.leftRight, y: self.topMargin, width: ScreenSize().width - self.leftRight * 2, height: self.inputHeight);
        }
        textField.text = nil;
    }
    
    
    @objc private func endEidt(){
        self.endEditing(true);
    }
    
    
}


