//
//  SearchBar.swift
//  SHKit
//
//  Created by hsh on 2018/10/30.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


//用于一般性的在导航栏位置的搜索条带按键的布局和事件控件

//布局类型
public enum LayoutType{
    case Inner,Outer
}


public class SearchBar: UIView {
    // MARK: - 按钮存储
    private let _leftOutBtns = NSMutableArray()
    private let _leftInnerBtns = NSMutableArray()
    private let _rightInnerBtns = NSMutableArray()
    private let _rightOutBtns = NSMutableArray()
    // MARK: - UI
    public  var _containView:UIView!                //内容视图
    private var _textField:UITextField!             //输入框
    // MARK: - Default
    private var _layOutType = LayoutType.Inner;     //Inner输入栏内有按钮，Out无
    private var _radius:CGFloat = 5;                //搜索栏的圆角
    private var _barHeight:CGFloat = 50;            //搜索视图的高度
    
    
    //初始化
    class public func initSearchBar(placeHolder:String,type:LayoutType,radius:CGFloat = 5,barHeight:CGFloat = 50)->SearchBar{
        let searchBar = SearchBar();
        searchBar._layOutType = type;
        searchBar._textField = UITextField.initPlaceHolder(placeHolder, super: searchBar);
        let attribute = [NSAttributedStringKey.foregroundColor:UIColor.colorHexValue("9E9E9E"),
                         NSAttributedStringKey.font:kFont(14)];
        let attriStr = NSAttributedString(string: placeHolder, attributes: attribute);
        searchBar._textField.attributedPlaceholder = attriStr;
        searchBar._radius = radius;
        searchBar._barHeight = barHeight;
        return searchBar;
    }
    
    
    //添加内容
    public func addSearchItem(items:[UIButtonLayout],inner:Bool = true,left:Bool = false)->Void{
        if (_layOutType == LayoutType.Inner){
            if inner == true{
                if left == true{
                    _leftInnerBtns.addObjects(from: items);
                }else{
                    _rightInnerBtns.addObjects(from: items);
                }
            }else{
                if left == true{
                    _leftOutBtns.addObjects(from: items);
                }else{
                    _rightOutBtns.addObjects(from: items);
                }
            }
        }else{
            if left == true{
                _leftOutBtns.addObjects(from: items);
            }else{
                _rightOutBtns.addObjects(from: items);
            }
        }
        self.setNeedsLayout();
    }
    
    
    
    //布局
    public override func layoutSubviews() {
        //移除所有，重新布局
        for view in self.subviews{
            view.removeFromSuperview();
        }
        //左依据视图
        var leftBase:UIView = self;
        var rightBase:UIView = self;
        
        var lastLeftLayout:UIButtonLayout?
        var lastRightLayout:UIButtonLayout?
        //外层左侧按钮遍历
        for value in _leftOutBtns{
            let layout = value as! UIButtonLayout;
            self.addSubview(layout.btn);
            layout.btn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(self);
                if leftBase == self{
                    maker?.left.mas_equalTo()(leftBase.mas_left)?.offset()(layout.leftMargin);
                }else{
                    maker?.left.mas_equalTo()(leftBase.mas_right)?.offset()(layout.leftMargin);
                }
                maker?.width.mas_equalTo()(layout.width);
                maker?.height.mas_equalTo()(layout.height);
            }
            leftBase = layout.btn;
            lastLeftLayout = layout;
        }
        //外层右侧按钮遍历
        for value in _rightOutBtns{
            let layout = value as! UIButtonLayout;
            self.addSubview(layout.btn);
            layout.btn.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(self);
                if rightBase == self{
                     maker?.right.mas_equalTo()(rightBase.mas_right)?.offset()(-layout.rightMargin);
                }else{
                     maker?.right.mas_equalTo()(rightBase.mas_left)?.offset()(-layout.rightMargin);
                }
                maker?.width.mas_equalTo()(layout.width);
                maker?.height.mas_equalTo()(layout.height);
            }
            rightBase = layout.btn;
            lastRightLayout = layout;
        }
        //添加搜索框容器视图
        _containView = UIView();
        self.addSubview(_containView);
        _containView.backgroundColor = UIColor.white;
        _containView.setRadius(_barHeight/2.0);
        _containView.mas_makeConstraints { (maker) in
            if lastLeftLayout == nil{
                maker?.left.mas_equalTo()(leftBase.mas_left)?.offset()(16);
            }else{
                maker?.left.mas_equalTo()(leftBase.mas_right)?.offset()((lastLeftLayout?.rightMargin)!);
            }
            if lastRightLayout == nil{
                maker?.right.mas_equalTo()(rightBase.mas_right)?.offset()(-16);
            }else{
                maker?.right.mas_equalTo()(rightBase.mas_left)?.offset()(-(lastRightLayout?.leftMargin)!);
            }
            maker?.height.mas_equalTo()(_barHeight);
            maker?.centerY.mas_equalTo()(self);
        }
        leftBase = _containView;
        rightBase = _containView;
        //如果里面还有则显示里面的
        if _layOutType == LayoutType.Inner {
            _containView.setRadius(_radius);
            //内部左侧
            for value in _leftInnerBtns{
                let layout = value as! UIButtonLayout;
                self.addSubview(layout.btn);
                layout.btn.mas_makeConstraints { (maker) in
                    maker?.centerY.mas_equalTo()(self);
                    if leftBase == _containView{
                        maker?.left.mas_equalTo()(leftBase.mas_left)?.offset()(layout.leftMargin);
                    }else{
                        maker?.left.mas_equalTo()(leftBase.mas_right)?.offset()(layout.leftMargin);
                    }
                    maker?.width.mas_equalTo()(layout.width);
                    maker?.height.mas_equalTo()(layout.height);
                }
                leftBase = layout.btn;
                lastLeftLayout = layout;
            }
            //内部右侧
            for value in _rightInnerBtns{
                let layout = value as! UIButtonLayout;
                self.addSubview(layout.btn);
                layout.btn.mas_makeConstraints { (maker) in
                    maker?.centerY.mas_equalTo()(self);
                    if rightBase == _containView{
                        maker?.right.mas_equalTo()(rightBase.mas_right)?.offset()(-layout.rightMargin);
                    }else{
                        maker?.right.mas_equalTo()(rightBase.mas_left)?.offset()(-layout.rightMargin);
                    }
                    maker?.width.mas_equalTo()(layout.width);
                    maker?.height.mas_equalTo()(layout.height);
                }
                rightBase = layout.btn;
                lastRightLayout = layout;
            }
        }
        //最后添加输入框
        _containView.addSubview(_textField);
        _textField.mas_makeConstraints { (maker) in
            if leftBase == rightBase{
                maker?.left.mas_equalTo()(leftBase.mas_left)?.offset()((lastLeftLayout?.rightMargin)!);
                maker?.right.mas_equalTo()(rightBase.mas_right)?.offset()(-(lastRightLayout?.leftMargin)!);
            }else{
                maker?.left.mas_equalTo()(leftBase.mas_right)?.offset()((lastLeftLayout?.rightMargin)!);
                maker?.right.mas_equalTo()(rightBase.mas_left)?.offset()(-(lastRightLayout?.leftMargin)!);
            }
            maker?.top.bottom()?.mas_equalTo()(_containView);
        }
        
        
    }
}
