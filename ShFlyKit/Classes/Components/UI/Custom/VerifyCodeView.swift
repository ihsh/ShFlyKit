//
//  VerifyCodeView.swift
//  SHKit
//
//  Created by hsh on 2019/11/28.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


protocol VerifyCodeViewDelegate:NSObjectProtocol {
    //结束输入
    func endInputVerifyCode(_ code:String);
}

///样式
enum CodeStyle {
    case Line,Square
}


//验证码输入视图
class VerifyCodeView: UIView,CustomTextFieldDelegate,UITextFieldDelegate {
    //Variable
    public weak var delegate:VerifyCodeViewDelegate?
    public var style:CodeStyle = .Square                                //默认样式
    public var codeLength:Int = 4                                       //默认输入位数
    public var lineWidth:CGFloat = 1                                    //边框线宽度
    public var cornerRadius:CGFloat = 2                                 //圆角
    public var margin:CGFloat = 8                                       //输入位之间的间距
    public var widHeight:CGFloat = 45                                   //输入位的宽高
    public var norColor:UIColor = UIColor.colorHexValue("9E9E9E")       //正常状态下的边框颜色
    public var selectColor:UIColor = UIColor.colorHexValue("F16622")    //当前选中的边框颜色
    public var textColor:UIColor = .black                               //中间文本颜色
    public var cursorColor:UIColor?                                     //光标颜色
    public var font:UIFont = kFont(22)                                  //中间文本字号
    public var endInput:Bool = true                                     //结束编辑后不允许重新开始输入
    //私有变量
    private var itemViews:[CodeItemV] = []                              //所有的视图
    private var curIndex:Int = 0                                        //当前的选中下标
    public private(set) var textField:CustomTextField!                  //输入视图
    
    
    
    //初始化-调用之前修改好配置
    public func initSubViews(_ width:CGFloat){
        //限制最大值,最小值
        codeLength = min(8, codeLength);
        codeLength = max(4, codeLength);
        //计算初始的X
        let double:Bool = codeLength%2 == 0;                     //是否是偶数
        let half:CGFloat = width/2.0;                            //正中的位置
        let halfCount = CGFloat(floor(Double(codeLength)/2.0));  //一半的下取整
        var x:CGFloat = 0;
        if double == true{
            x = half - margin/2.0 - halfCount * widHeight - (halfCount - 1) * margin;
        }else{
            x = half - widHeight/2.0 - halfCount * (widHeight + margin);
        }
        //移除原有视图
        self.clearSubviews();
        itemViews.removeAll();
        //添加视图
        for index in 0...codeLength-1 {
            let item = CodeItemV()
            if style == .Square {
                item.initBoarder(cornerRadius, norColor: norColor, hightColor: selectColor,
                                 lineWidth: lineWidth,index: index);
            }else{
                item.initLine(cornerRadius,norColor: norColor, hightColor: selectColor,
                              lineWidth: lineWidth, index: index);
            }
            //中间显示文字的字号，颜色
            item.showLabel.font = font;
            item.showLabel.textColor = textColor;
            item.frame = CGRect(x: x + (widHeight + margin) * CGFloat(index), y: 2, width: widHeight, height: widHeight)
            self.addSubview(item);
            itemViews.append(item);
        }
        //输入框
        textField = CustomTextField()
        let leftView = UIView(for: .clear);
        leftView.frame = CGRect(x: 0, y: 0, width: widHeight/2.0-lineWidth, height: 0)
        textField.leftView = leftView;
        textField.leftViewMode = .always;
        textField.contentVerticalAlignment = .center;
        textField.contentHorizontalAlignment = .center;
        textField.keyboardType = .numberPad;
        textField.textDelegate = self;
        textField.delegate = self;
        self.addSubview(textField);
        //设置光标颜色
        if cursorColor != nil {
            textField.tintColor = cursorColor;
        }
        //点亮第一个
        changeHightLight(0);
    }
    
    
    ///CustomTextFieldDelegate
    func textFieldBackPressed(_ textField: UITextField, clear: Bool) {
        //当前是已经清空的回退，往前一格退
        if clear == false {
            moveToLast();
        }
    }
    
    
    func textFieldDidChange(_ textField: UITextField, text: String?) {
        //文字发生变更，如果当前已经有文字了，就往前移动
        if textField.text?.count ?? 0 >= 1 {
            moveToNext(text);
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //限制输入的字符仅为数字
        let str = string.trimmingCharacters(in: NSCharacterSet.decimalDigits);
        if string.count > 0 && str.count > 0 {
            return false;
        }
        return true;
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for item in itemViews {
            //清空已有输入
            item.showLabel.text = nil;
        }
    }
    
    
    //往后移动
    func moveToNext(_ text:String?) {
        //保存值
        for (i,item) in itemViews.enumerated() {
            if i == curIndex {
                item.showLabel.text = text;
            }
        }
        //输入框值清除
        textField.text = nil;
        //下一步
        changeHightLight(curIndex + 1);
    }
      
    
    //往前移动
    func moveToLast() {
        //清空当前及之前的输入
        for (i,item) in itemViews.enumerated() {
            if i == curIndex - 1 {
                item.showLabel.text = nil;
            }else if i == curIndex{
                item.showLabel.text = nil;
            }
        }
        //当前是0就不会动了
        changeHightLight(curIndex - 1);
    }
    
    
    //勾选某个高亮
    private func changeHightLight(_ index:Int){
        //回归所有状态为非选中
        func updateBoarderNormal(){
            for (_,item) in itemViews.enumerated() {
                item.updateBoarder(false);
            }
        }
        //更改输入框的位置
        func changeInputIndex(_ index:Int){
            if index >= 0 && index < itemViews.count {
                let item = itemViews[index];
                //当前下标
                curIndex = index;
                textField.mas_remakeConstraints { (maker) in
                    maker?.width.height().mas_equalTo()(widHeight);
                    maker?.center.mas_equalTo()(item);
                }
            }
        }
        //当最后一个输完了，则输入结束
        if index >= itemViews.count {
            //所有边框色恢复
            updateBoarderNormal();
            //键盘收起
            textField.resignFirstResponder();
            //将输入视图放回第一个
            changeInputIndex(0);
            //输入完成后不允许再点击
            if endInput == true {
                textField.isEnabled = false;
            }
            //获取整串文字
            var tmp:String = String()
            for item in itemViews {
                let text = item.showLabel.text ?? "";
                tmp.append(text);
            }
            delegate?.endInputVerifyCode(tmp);
        }else{
            //输入过程中
            for (i,item) in itemViews.enumerated() {
                if i == index {
                    item.updateBoarder(true);
                    changeInputIndex(index);
                    textField.becomeFirstResponder();
                }else{
                    item.updateBoarder(false);
                }
            }
        }
    }
    
    
}




//验证码单视图
class CodeItemV: UIView {
    //Variable
    public var showLabel:UILabel!           //显示的文本
    //私有变量
    private var norColor:UIColor!           //正常状态的颜色
    private var hightColor:UIColor!         //选中状态的颜色
    private var line:UIView!                //仅底部线的时候
    
    
    //初始边框
    public func initBoarder(_ cornerRadius:CGFloat,norColor:UIColor,hightColor:UIColor,lineWidth:CGFloat,index:Int){
        self.norColor = norColor;
        self.hightColor = hightColor;
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderColor = norColor.cgColor;
        self.layer.borderWidth = lineWidth;
        initLabel();
    }
    
    
    public func initLine(_ cornerRadius:CGFloat,norColor:UIColor,hightColor:UIColor,lineWidth:CGFloat,index:Int){
        self.norColor = norColor;
        self.hightColor = hightColor;
        self.line = UIView(for: norColor);
        self.line.layer.cornerRadius = cornerRadius;
        self.line.layer.masksToBounds = true;
        self.addSubview(line);
        line.mas_makeConstraints { (make) in
            make?.left.bottom().right()?.mas_equalTo()(self);
            make?.height.mas_equalTo()(lineWidth);
        }
        initLabel();
    }
    
    
    //更新颜色
    public func updateBoarder(_ hight:Bool){
        if self.line != nil {
            if hight == true{
                self.line.backgroundColor = hightColor;
            }else{
                self.line.backgroundColor = norColor;
            }
        }else{
            if hight == true{
                self.layer.borderColor = hightColor.cgColor;
            }else{
                self.layer.borderColor = norColor.cgColor;
            }
        }
    }
    
    
    //初始化显示的Label
    private func initLabel(){
        self.showLabel = UILabel()
        self.addSubview(showLabel);
        showLabel.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self);
        }
    }
    

}
