//
//  CustomTextField.swift
//  SHKit
//
//  Created by hsh on 2019/11/28.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


public protocol CustomTextFieldDelegate:NSObject {
    //点击了删除按钮
    func textFieldBackPressed(_ textField:UITextField,clear:Bool);
    //新增文本
    func textFieldDidChange(_ textField:UITextField,text:String?);
}


///自定义的输入视图
public class CustomTextField: UITextField {
    //Variable
    public weak var textDelegate:CustomTextFieldDelegate?
        
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //文本发生更改
    @objc func textDidChange(){
        textDelegate?.textFieldDidChange(self, text: self.text);
    }
    
    
    //点击了删除键
    public override func deleteBackward() {
        let text = self.text;
        super.deleteBackward()
        textDelegate?.textFieldBackPressed(self,clear: text?.count ?? 0 > 0);
    }
    
    
}
