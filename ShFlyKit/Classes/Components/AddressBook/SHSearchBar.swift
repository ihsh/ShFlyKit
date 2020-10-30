//
//  SHSearchBar.swift
//  SHKit
//
//  Created by hsh on 2019/5/24.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//搜索的代理协议
@objc public protocol SHSearchBarDelegate:NSObjectProtocol {
    //输入的文字发生改变
    func textDidChange(_ text:String)
    //开始编辑
    @objc optional func textBeginEdit()
    //退出了编辑
    @objc optional func textDidEndEdit()
    //改变高度
    @objc optional func keyboardChangeFrame(_ height:CGFloat)
}


//搜索栏
public class SHSearchBar: UIView{
    //输入框
    public weak var delegate:SHSearchBarDelegate?           //代理
    public var searchTextField:UISpanTextField!             //输入的文本输入框--有内边距
    public var cancelBtn:UIButton!                          //取消的按钮

    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //取消按钮
        cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: UIControlState.normal);
        cancelBtn.setTitleColor(UIColor.colorHexValue("212121"), for: .normal);
        cancelBtn.titleLabel?.font = kFont(14);
        self.addSubview(cancelBtn);
        cancelBtn.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-8);
            maker?.centerY.mas_equalTo()(self);
            maker?.top.bottom()?.mas_equalTo()(self);
            maker?.width.mas_equalTo()(0);
        }
        cancelBtn.addTarget(self, action: #selector(textEndEditing), for: UIControlEvents.touchUpInside);
        //输入框
        searchTextField = UISpanTextField.init(dx: 8, dy: 0, frame: CGRect(x: 16, y: 8, width: ScreenSize().width-32, height: 34));
        self.addSubview(searchTextField);
        searchTextField.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(16);
            maker?.right.mas_equalTo()(cancelBtn.mas_left)?.offset()(-8);
            maker?.top.mas_equalTo()(self)?.offset()(8);
            maker?.bottom.mas_equalTo()(self)?.offset()(-8);
        }
        searchTextField.placeholder = "搜索";
        searchTextField.backgroundColor = UIColor.colorRGB(red: 231, green: 231, blue: 231);
        searchTextField.layer.cornerRadius = 6;
        searchTextField.layer.masksToBounds = true;
        //添加事件监听
        searchTextField.addTarget(self, action: #selector(textDidChanged), for: UIControlEvents.editingChanged);
        searchTextField.addTarget(self, action: #selector(textEndEditing), for: UIControlEvents.editingDidEnd);
        searchTextField.addTarget(self, action: #selector(textBeiginEditing), for: UIControlEvents.editingDidBegin);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(noti:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil);
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc public func textDidChanged() {
        delegate?.textDidChange(searchTextField.text ?? "");
    }
    
    @objc public func textEndEditing(){
        cancelBtn.mas_remakeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-8);
            maker?.centerY.mas_equalTo()(self);
            maker?.top.bottom()?.mas_equalTo()(self);
            maker?.width.mas_equalTo()(0);
        }
        self.endEditing(true);
        searchTextField.text = nil;
        delegate?.textDidEndEdit?();
    }
    
    @objc public func textBeiginEditing(){
        cancelBtn.mas_remakeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-8);
            maker?.centerY.mas_equalTo()(self);
            maker?.top.bottom()?.mas_equalTo()(self);
            maker?.width.mas_equalTo()(60);
        }
        delegate?.textBeginEdit?();
    }
    
    
    @objc public func keyboardWillChangeFrame(noti:NSNotification){
        let info:NSDictionary = noti.userInfo! as NSDictionary;
        let beginRect:CGRect = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! CGRect
        let endRect:CGRect = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
        let yOffset = fabs(endRect.origin.y - beginRect.origin.y);
        delegate?.keyboardChangeFrame?(yOffset);
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
}
