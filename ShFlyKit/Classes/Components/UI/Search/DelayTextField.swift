//
//  DelayTextField.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///延时调用
public protocol DelayTextFieldDelegate:NSObjectProtocol {
    //延时调用
    func textFieldDelayDidChange(_ text:String)
    //开始编辑
    func textBeiginEdit()
    //结束编辑
    func textDidEndEdit()
}


//延迟调用文字调用的文本输入框
public class DelayTextField:UITextField , HeatBeatTimerDelegate{
    //Variable
    public var delayTime:TimeInterval = 1                //延时判断时间间隔
    public var dx:CGFloat = 16                           //水平方向上的偏移
    public weak var delayDelegete:DelayTextFieldDelegate?//延时代理
    //私有变量
    private var changed:Bool = false                    //是否发生变更
    private var lastChangeTime:TimeInterval = 0         //上次的变更的时刻
        
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //添加文本更改观察者
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(textBeiginEdit), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(textEndEdit), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        //添加检测任务
        HeatBeatTimer.shared.addTimerTask(identifier: "delatInputCheck", span: 1, repeatCount: 0, delegate: self, executeRightNow: false);
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //发生了更改
    @objc private func textDidChange(){
        lastChangeTime = Date().timeIntervalSince1970;
        changed = true;
    }
    
    
    @objc private func textBeiginEdit(){
        delayDelegete?.textBeiginEdit();
    }
    
    
    @objc private func textEndEdit(){
        delayDelegete?.textDidEndEdit();
    }
    
    
    //定时器的调用
    public func timeTaskCalled(identifier: String) {
        //时间间隔
        let current = Date().timeIntervalSince1970;
        let sub = fabs(current - lastChangeTime);
        //发生更改
        if sub > 0.5 && changed == true {
            changed = false;
            let text = self.text ?? "";
            delayDelegete?.textFieldDelayDidChange(text);
        }
    }
    
    
    //修改内边距
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: dx, dy: 0);
    }
    
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: dx, dy: 0);
    }
    
    
}

