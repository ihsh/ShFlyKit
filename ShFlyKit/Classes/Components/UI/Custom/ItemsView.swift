//
//  ItemsView.swift
//  SHKit
//
//  Created by hsh on 2019/9/18.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//协议
@objc public protocol ItemsViewDelegate:NSObjectProtocol {
    @objc optional func objClick(_ index:Int)
    @objc optional func objClickTitle(_ title:String)
    @objc optional func customViewForIndexPath(row:Int,column:Int)->UIView
}


///自定义的多选项视图
public class ItemsView: UIView {
    ///variable
    public weak var delegate:ItemsViewDelegate?
    public var leftEdge:CGFloat = 16                                    //左边缘距离
    public var rightEdge:CGFloat = 16                                   //右边缘距离
    public var margin:CGFloat = 10                                      //中间的间距
    public var topSpan:CGFloat = 16                                     //上/下边缘距离
    public var rowSpan:CGFloat = 10                                     //上下之间的距离
    public var itemHeight:CGFloat = 30                                  //每项高度
    public var font:UIFont = kFont(14)                                  //字号
    public var titleColor:UIColor = UIColor.colorHexValue("4A4A4A")     //文字颜色
    public var cornerRadius:CGFloat = 15                                //圆角
    public var borderW:CGFloat = 0.5                                    //边框宽度
    public var borderColor:UIColor = UIColor.colorHexValue("9E9E9E")    //边框颜色
    public var backColor:UIColor = UIColor.clear;                       //背景颜色
    
    
    
    //自定义视图，代理返回视图
    public func initCustom(col:Int,count:Int,eventEnable:Bool = true)->Void{
        self.clearSubviews();
        self.backgroundColor = backColor;
        for index in 0...count-1{
            //当前行
            let row = index / col;
            //当前列
            let line = index % col;
            //代理返回视图
            guard let view = delegate?.customViewForIndexPath?(row: row, column: line) else { return };
            if eventEnable == true {
                let btn = UIButton()
                btn.tag = index;
                btn.addTarget(self, action: #selector(customClickIn(_:)), for: .touchUpInside);
                view.addSubview(btn);
                btn.mas_makeConstraints { (maker) in
                    maker?.left.top()?.right()?.bottom()?.mas_equalTo()(view);
                }
            }
            self.addSubview(view);
        }
    }
    
    
    //初始化默认样式的按钮
    public func initBtns(col:Int,items:[String])->CGFloat{
        self.clearSubviews();
        self.backgroundColor = backColor;
        let column:CGFloat = CGFloat(col);
        //每个的宽度
        let width:CGFloat = (ScreenSize().width - leftEdge - rightEdge - (column - 1) * margin) / column;
        //最大的行数
        var maxLine:CGFloat = 0;
        //添加按钮
        for (index,value) in items.enumerated(){
            //当前行
            let row = index / col;
            //当前列
            let line = index % col;
            maxLine = max(maxLine,CGFloat(row + (line == 0 ? 1 : 0)));
            //坐标
            let rect = CGRect(x: leftEdge + (width + margin) * CGFloat(line), y: topSpan + (itemHeight+rowSpan) * CGFloat(row), width: width, height: itemHeight);
            
            let btn = UIButton();
            btn.frame = rect;
            btn.tag = index;
            btn.setTitle(value, for: .normal);
            btn.titleLabel?.font = font;
            btn.setTitleColor(titleColor, for: .normal);
            btn.addTarget(self, action: #selector(btnClickIn(_:)), for: .touchUpInside);
            btn.layer.cornerRadius = cornerRadius;
            btn.layer.borderWidth = borderW;
            btn.layer.borderColor = borderColor.cgColor;
            self.addSubview(btn);
        }
        //返回整个视图应需的高度
        return (maxLine * itemHeight + topSpan * 2 + (maxLine - 1) * rowSpan);
    }
    
    
    
    @objc private func btnClickIn(_ sender:UIButton){
        delegate?.objClick?(sender.tag);
        delegate?.objClickTitle?((sender.titleLabel?.text)!);
    }
    
    
    @objc private func customClickIn(_ sender:UIButton){
        delegate?.objClick?(sender.tag);
    }

    
}
