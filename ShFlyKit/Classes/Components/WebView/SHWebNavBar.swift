//
//  SHWebNavBar.swift
//  SHKit
//
//  Created by hsh on 2019/6/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//右侧更多按钮样式
public enum RightBarItemStyle{
    case Icon,Word          //图标样式,文字样式
}


//自定义的Web导航栏
public class SHWebNavBar: UIView {
    //Variable
    public var backItem:UIButton!                   //返回按钮
    public var closeItem:UIButton!                  //关闭按钮
    public var titleL:UILabel!                      //标题
    public var moreItem:UIButton!                   //更多按钮
    public var progressView:UIProgressView!                                                         //进度视图
    
    public var progressBarHeight:CGFloat = 2                                                        //进度条的颜色
    public var progressColor:UIColor = UIColor.colorRGB(red: 152, green: 215, blue: 93)             //进度条的颜色
    
    
    //配置
    public func configRightBarItem(_ style:RightBarItemStyle,title:String?,url:String?){
        switch style {
        case .Word:
            moreItem.setTitle(title ?? "更多", for: .normal);
            moreItem.setImage(nil, for: .normal);
        case .Icon:
            moreItem.setTitle(nil, for: .normal);
            //下载icon
            moreItem.setImage(UIImage.name("ic_navbar_more"), for: .normal);
        }
    }
    
    
    
    //初始化约束
    private func initConstraint(){
        progressView.mas_makeConstraints { (maker) in
            maker?.left.bottom().right()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(progressBarHeight);
        }
        backItem.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(12);
            maker?.width.height()?.mas_equalTo()(32);
            maker?.centerY.mas_equalTo()(self);
        }
        closeItem.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(backItem.mas_right)
            maker?.width.height()?.mas_equalTo()(32);
            maker?.centerY.mas_equalTo()(self);
        }
        moreItem.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(self)?.offset()(-12);
            maker?.width.height()?.mas_equalTo()(32);
            maker?.centerY.mas_equalTo()(self);
        }
        titleL.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(self);
        }
    }
    
    
    
    private func initUI(){
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.clear;
        progressView.progressTintColor = progressColor;
        self.addSubview(progressView);
        progressView.isHidden = true;
        //返回按钮
        backItem = UIButton()
        backItem.setImage(UIImage.name("ic_navbar_back"), for: .normal);
        self.addSubview(backItem);
        backItem.isHidden = false;
        //关闭按钮
        closeItem = UIButton()
        closeItem.setImage(UIImage.name("ic_navbar_close"), for: .normal);
        self.addSubview(closeItem);
        closeItem.isHidden = true;
        //更多按钮
        moreItem = UIButton()
        self.addSubview(moreItem);
        moreItem.isHidden = true;
        //标题
        titleL = UILabel()
        titleL.font = kFont(16);
        titleL.textColor = UIColor.black;
        titleL.lineBreakMode = .byTruncatingTail;
        titleL.textAlignment = .center;
        self.addSubview(titleL);
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.white;
        self.initUI();
        self.initConstraint();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
