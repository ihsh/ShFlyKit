//
//  SHShareUI.swift
//  SHKit
//
//  Created by hsh on 2019/4/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry

//UI的代理
@objc public protocol SHShareUIDelegate:NSObjectProtocol {
    //处理点击
    func shareClick(config:ShareConfig)
    //由代理对Cell进行数据填充
    @objc optional func cellForIndexPath(_ cell:UICollectionViewCell,indexPath: IndexPath, config:ShareConfig) -> UICollectionViewCell
}


///分享工具类UI
public class SHShareUI: UIView,UICollectionViewDelegate,UICollectionViewDataSource{
    //Variable
    public weak var delegate:SHShareUIDelegate?             //UI代理
    public var activitys:[ShareConfig] = []                 //第一行分享功能数据
    public var customActions:[ShareConfig] = []             //第二行自定义功能
    
    public var lineHeight:CGFloat = 100                     //一行显示的高度
    public var boardSpan:CGFloat = 0                        //板块距边距离
    public var contentOffset:CGFloat = 10                   //显示的icon和标题在X轴上的偏移
    
    public var containView:UIView!                          //内容视图
    public var showView:UIView!                             //展示collectionView
    public var cancelBtn:UIButton!                          //取消的按钮
    //集合视图
    private var mainCollectionV:UICollectionView!
    private var customCollectionV:UICollectionView!
    private var cellClass:AnyClass!                         //cell的class缓存
    private var showDefault:Bool = false                    //是否展示的是默认UI
    
    
    //Interface(
    public func setLatout(lineSpace:CGFloat,interitemSpace:CGFloat){
        //创建layout
        func creatFlowLayout(lineSpace:CGFloat,interitemSpace:CGFloat)->UICollectionViewFlowLayout{
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = lineSpace;
            layout.minimumInteritemSpacing = interitemSpace;
            layout.scrollDirection = .horizontal;
            layout.itemSize = CGSize(width: ScreenSize().width/5, height: lineHeight);
            return layout;
        }
        mainCollectionV = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: creatFlowLayout(lineSpace: lineSpace, interitemSpace: interitemSpace));
        customCollectionV = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: creatFlowLayout(lineSpace: lineSpace, interitemSpace: interitemSpace));
        //不显示水平滚动条
        mainCollectionV.showsHorizontalScrollIndicator = false;
        customCollectionV.showsHorizontalScrollIndicator = false;
        //设置背景色
        mainCollectionV.backgroundColor = UIColor.clear;
        customCollectionV.backgroundColor = UIColor.clear;
    }
    
    
    //注册cell
    public func register(anyclass:AnyClass){
        if mainCollectionV == nil {
            cellClass = anyclass;
        }else{
            mainCollectionV.register(anyclass, forCellWithReuseIdentifier: "cell");
            customCollectionV.register(anyclass, forCellWithReuseIdentifier: "cell");
        }
    }
    
    
    //配置后开始显示
    public func show(){
        //防止因为设置的不对引起的nil崩溃
        if cellClass != nil{
            self.register(anyclass: cellClass);
        }
        self.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.3);
        self.containView = UIView()
        self.containView.backgroundColor = UIColor.clear;
        self.containView.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        var showHeight:CGFloat = 0;
        //取消视图
        let cancelView = SHBorderView()
        cancelBtn = UIButton()
        cancelBtn.setTitle("取消", for: .normal);
        cancelBtn.setTitleColor(UIColor.colorHexValue("212121"), for: .normal);
        cancelBtn.addTarget(self, action: #selector(cancalCalled), for: .touchUpInside);
        cancelBtn.titleLabel?.font = kFont(14);
        cancelView.addSubview(cancelBtn);
        cancelBtn.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(cancelView);
        }
        cancelView.layer.cornerRadius = boardSpan/2.0;
        cancelView.layer.masksToBounds = true;
        self.containView.addSubview(cancelView);
        cancelView.borderStyle = 1;
        cancelView.backgroundColor = UIColor.white;
        cancelView.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(self.containView)?.offset()(-boardSpan*2);
            maker?.left.mas_equalTo()(self.containView)?.offset()(boardSpan);
            maker?.right.mas_equalTo()(self.containView)?.offset()(-boardSpan);
            maker?.height.mas_equalTo()(55);
        }
        showHeight += 55;
        //展示点击的视图
        self.showView = UIView()
        self.showView.backgroundColor = UIColor.white;
        self.showView.layer.cornerRadius = boardSpan/2.0;
        self.showView.layer.masksToBounds = true;
        self.containView.addSubview(showView);
        //添加第二行的视图
        self.showView.addSubview(customCollectionV);
        let customHeight:CGFloat = ((customActions.count > 0) ? 1 : 0)*lineHeight;
        showHeight += customHeight;
        customCollectionV.mas_makeConstraints { (maker) in
            maker?.left.right().bottom()?.mas_equalTo()(showView);
            maker?.height.mas_equalTo()(customHeight);
        }
        //添加分割线
        if (customActions.count > 0) {
            let line = UIView()
            line.backgroundColor = UIColor.colorHexValue("9E9E9E");
            self.showView.addSubview(line);
            line.mas_makeConstraints { (maker) in
                maker?.left.right().mas_equalTo()(self.showView);
                maker?.bottom.mas_equalTo()(customCollectionV.mas_top)?.offset();
                maker?.height.mas_equalTo()(0.5);
            }
        }
        //添加第一行的视图
        self.showView.addSubview(mainCollectionV);
        mainCollectionV.mas_makeConstraints { (maker) in
            maker?.left.right().mas_equalTo()(self.showView);
            maker?.bottom.mas_equalTo()(customCollectionV.mas_top)?.offset()(-1);
            maker?.height.mas_equalTo()(lineHeight);
        }
        showHeight += lineHeight;
        //更改显示高度
        showView.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(cancelView.mas_top)?.offset()(-boardSpan);
            maker?.left.mas_equalTo()(self.containView)?.offset()(boardSpan);
            maker?.right.mas_equalTo()(self.containView)?.offset()(-boardSpan);
            maker?.height.mas_equalTo()(lineHeight + customHeight + 20);
        }
        self.containView.frame = CGRect(x: 0, y: ScreenSize().height-showHeight, width: ScreenSize().width, height: ScreenSize().height);
        self.addSubview(containView);
        //设置代理
        customCollectionV.delegate = self;
        customCollectionV.dataSource = self;
        mainCollectionV.delegate = self;
        mainCollectionV.dataSource = self;
        UIView.animate(withDuration: 0.3) {
            self.containView.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        }
    }

    
    //默认的配置
    public func defaultShow(){
        showDefault = true;
        self.setLatout(lineSpace: 0, interitemSpace: 0);
        self.register(anyclass: ShareDefaultCell.self);
        //配置数据
        let qq = ShareConfig.initConfig(title: "QQ", image: UIImage.name("share_qq"), type: .QQ);
        let qzone = ShareConfig.initConfig(title: "QQ空间", image: UIImage.name("share_qzone"), type: .QQzone);
        let wechat = ShareConfig.initConfig(title: "微信好友", image: UIImage.name("share_wechat"), type: .WeChat);
        let wechatzone = ShareConfig.initConfig(title: "朋友圈", image: UIImage.name("share_wechat_timeline"), type: .WeChatZone);
        let weibo = ShareConfig.initConfig(title: "微博", image: UIImage.name("share_sina"), type: .Weibo);
        let sms = ShareConfig.initConfig(title: "短信", image: UIImage.name("share_sina"), type: .SMS);
        let system = ShareConfig.initConfig(title: "系统", image: UIImage.name("share_sina"), type: .System);
        self.activitys = [wechat,wechatzone,qq,qzone,weibo,sms,system];
        self.show();
    }
    
    
    //取消的点击
    @objc private func cancalCalled(){
        UIView.animate(withDuration: 0.3, animations: {
            self.containView.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: ScreenSize().height);
        }) { (finished) in
            self.removeFromSuperview();
        }
    }
    
    
    //UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.isEqual(mainCollectionV)) {
            return activitys.count;
        }else{
            return customActions.count;
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let config:ShareConfig!
        if (collectionView.isEqual(mainCollectionV)) {
            config = activitys[indexPath.row];
        }else{
            config = customActions[indexPath.row];
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath);
        if showDefault == false{
            return delegate?.cellForIndexPath?(cell, indexPath: indexPath, config: config) ?? UICollectionViewCell();
        }
        //默认UI的显示
        let defaultCell:ShareDefaultCell = cell as! ShareDefaultCell;
        defaultCell.loadData(config: config);
        defaultCell.setContentOffset(contentOffset);
        return defaultCell;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let config:ShareConfig!
        if (collectionView.isEqual(mainCollectionV)) {
            config = activitys[indexPath.row];
        }else{
            config = customActions[indexPath.row];
        }
        delegate?.shareClick(config: config);
    }
    
}


//分享UI的配置项
public class ShareConfig:NSObject{
    //Variable
    public var title:String!
    public var image:UIImage!
    public var type:ShareType?
    
    class public func initConfig(title:String,image:UIImage,type:ShareType?)->ShareConfig{
        let config = ShareConfig()
        config.title = title;
        config.image = image;
        config.type = type;
        return config;
    }
}


//分享UI的cell
public class ShareDefaultCell: UICollectionViewCell {
    //Variable
    public var imageV:UIImageView!          //图标
    public var titleL:UILabel!              //标题
    //Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        imageV = UIImageView()
        imageV.isUserInteractionEnabled = true;
        self.contentView.addSubview(imageV);
        imageV.mas_makeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(self.contentView)?.offset()(-10);
            maker?.centerX.mas_equalTo()(self.contentView);
            maker?.width.height()?.mas_equalTo()(60);
        }
        titleL = UILabel()
        titleL.font = kFont(14);
        titleL.textColor = UIColor.colorHexValue("212121");
        titleL.textAlignment = .center;
        self.contentView.addSubview(titleL);
        titleL.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.contentView);
            maker?.top.mas_equalTo()(imageV.mas_bottom)?.offset()(1);
        }
    }
    
    
    public func setContentOffset(_ offset:CGFloat){
        imageV.mas_remakeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(self.contentView)?.offset()(-10);
            maker?.centerX.mas_equalTo()(self.contentView)?.offset()(offset);
            maker?.width.height()?.mas_equalTo()(60);
        }
        titleL.mas_remakeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.contentView)?.offset()(offset);
            maker?.top.mas_equalTo()(imageV.mas_bottom)?.offset()(1);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func loadData(config:ShareConfig){
        imageV.image = config.image;
        titleL.text = config.title;
    }
    
}
