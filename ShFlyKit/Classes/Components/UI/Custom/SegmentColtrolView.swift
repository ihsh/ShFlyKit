//
//  SegmentColtrolView.swift
//  SHKit
//
//  Created by hsh on 2019/12/2.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


protocol SegmentColtrolViewDelegate:NSObjectProtocol {
    func segmentDidSelectIndex(_ index:Int,title:String)
}


///滑动的segmengControl
class SegmentColtrolView: UIView {
    //Variable
    public weak var delegate:SegmentColtrolViewDelegate?
    public var indicaterColor = UIColor.colorRGB(red: 58, green: 156, blue: 254)        //指示条颜色
    public var highColor = UIColor.colorHexValue("000000")  //高亮状态的颜色
    public var highFont:UIFont = kBoldFont(14)              //高亮状态的字号
    public var norColor = UIColor.colorHexValue("9E9E9E")   //普通状态的颜色
    public var norFont:UIFont = kFont(14)                   //普通状态的字号
    public var autoWidth:Bool = false                       //是否自动宽度
    public var widthExtra:CGFloat = 0                       //自动宽度时增加的宽度-可增可减
    public var lineWidth:CGFloat = 2                        //线宽
    public var itemWidth:CGFloat = ScreenSize().width/4.0   //单项宽度
    public var segmentHeight:CGFloat = 40                   //高度
    
    public private(set) var indicater:UIView!               //指示视图
    private var scrollV:UIScrollView!                       //滚动视图
    private var indicateWidths:[CGFloat] = []               //指示条根据文字计算出来的宽度数组
    private var btns:[UIButton] = []                        //按钮

    
    
    //load
    public func initSubviews(_ items:[String]){
        //滚动视图
        scrollV = UIScrollView()
        scrollV.showsHorizontalScrollIndicator = false;
        self.addSubview(scrollV);
        scrollV.mas_makeConstraints { (make) in
            make?.left.right()?.top()?.bottom().mas_equalTo()(self);
        }
        //滚动视图
        var allContentWidth:CGFloat = 0;
        for (index,value) in items.enumerated() {
            let btn = UIButton.initTitle(value, textColor: norColor, back: .white, font: norFont, super: scrollV);
            btn.frame = CGRect(x: itemWidth*CGFloat(index), y: 0, width: itemWidth, height: segmentHeight-lineWidth);
            btn.tag = index;
            btn.addTarget(self, action: #selector(btnClicked(_:)), for: .touchUpInside);
            let str:NSString = NSString.init(string: value);
            let width = str.width(with: norFont);
            indicateWidths.append(width + widthExtra);
            btns.append(btn);
            allContentWidth += itemWidth;
        }
        scrollV.contentSize = CGSize(width: allContentWidth, height: 0);
        //指示视图
        indicater = UIView();
        indicater.backgroundColor = indicaterColor;
        indicater.frame = CGRect(x: 0, y: segmentHeight-lineWidth, width: itemWidth, height: lineWidth);
        scrollV.addSubview(indicater);
        //更新到第一个
        updateIndicater(0);
    }
    
    
    //更新指示的位置
    public func updateIndicater(_ index:Int){
        //动态宽度
        var width = itemWidth;
        if autoWidth == true {
            width = indicateWidths[index];
        }
        UIView.animate(withDuration: 0.1) {
            self.indicater.frame = CGRect(x: self.itemWidth*CGFloat(index)+(self.itemWidth-width)/2.0,
                                          y: self.segmentHeight-self.lineWidth,
                                          width: width, height: self.lineWidth);
        }
        //按钮状态重置
        for (i,btn) in btns.enumerated() {
            if i == index {
                btn.titleLabel?.font = highFont;
                btn.setTitleColor(highColor, for: .normal);
            }else{
                btn.titleLabel?.font = norFont;
                btn.setTitleColor(norColor, for: .normal);
            }
        } 
    }
    
    
    //按钮点击
    @objc private func btnClicked(_ sender:UIButton){
        let index = sender.tag;
        updateIndicater(index);
        autoScroll(index);
        delegate?.segmentDidSelectIndex(index, title: btns[index].titleLabel?.text ?? "")
    }
    
    
    //自动滚动
    public func autoScroll(_ index:Int){
        if index > 0 && index < btns.count - 1 {
            //当前滚动的X
            let x = scrollV.contentOffset.x;
            //当前所在的x
            let tmpX = CGFloat(index) * itemWidth;
                //向左滚动
            if tmpX - 5  < x {
                let step = floor((x-itemWidth)/itemWidth);
                scrollV.setContentOffset(CGPoint(x: step*itemWidth, y: 0), animated: true);
            }else if (tmpX + itemWidth + 5) >= x + ScreenSize().width {
                //向右滚动
                let step = floor((x+itemWidth)/itemWidth);
                scrollV.setContentOffset(CGPoint(x: step*itemWidth, y: 0), animated: true);
            }else{
                //回归位置
                let step = floor(x/itemWidth);
                scrollV.setContentOffset(CGPoint(x: step*itemWidth, y: 0), animated: true);
            }
        }
    }

    
}

