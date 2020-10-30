//
//  BottomInfoView.swift
//  SHKit
//
//  Created by hsh on 2018/12/17.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


///多路径选择的底部选择栏

//路线选择代理
public protocol BottomInfoViewDelegate {
    //选择路径RouteID的路线
    func bottomInfoViewSelectedRouteWithRouteID(routeID:NSInteger)
    //使用RouteID开始导航
    func bootomInfoViewStartNavWithRouteID(routeID:NSInteger)
}



public class BottomInfoView: UIView ,RouteInfoViewDelegate{
    // MARK: - variable
    public var delegate:BottomInfoViewDelegate!         //底部栏代理，多路径控制器作为代理
    public var allRoute:[RouteInfoModel]!               //所有路线的信息
    
    private var allInfoView = [RouteInfoView]()         //所有路线的视图
    private var startNavBtn:UIButton!                   //开始导航按钮
    private var selectedRouteID:NSInteger!              //当前选择的路线
    private var containView:SHBorderView!
    
    
    // MARK: - Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        //容器视图
        self.containView = SHBorderView()
        containView.borderStyle = 8;
        self.addSubview(containView);
        containView.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(self)?.offset()(-80);
            maker?.top.left()?.right()?.mas_equalTo()(self);
        }
        //按钮的容器视图
        let btnView = UIView()
        btnView.backgroundColor = UIColor.white;
        self.addSubview(btnView);
        btnView .mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.mas_equalTo()(self);
            maker?.top.mas_equalTo()(containView.mas_bottom);
        }
        //开始导航按钮
        self.startNavBtn = UIButton.initTitle("开始导航", textColor: UIColor.white, back: UIColor.colorRGB(red: 61, green: 135, blue: 233), font: kFont(12), super: btnView);
        self.startNavBtn.layer.cornerRadius = 3;
        self.startNavBtn.addTarget(self, action: #selector(startNavButtonAction), for: UIControlEvents.touchUpInside);
        startNavBtn.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(btnView)?.offset()(-30);
            maker?.top.mas_equalTo()(btnView.mas_top)?.offset()(20);
            maker?.width.mas_equalTo()(100)
            maker?.bottom.mas_equalTo()(btnView.mas_bottom)?.offset()(-20);
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    // MARK: - Interface
    public func setAllRouteInfo(allRouteInfo:[RouteInfoModel])->Void{
        self.allRoute = allRouteInfo;
        for (_,view) in allInfoView.enumerated(){
            view.removeFromSuperview()
        }
        self.allInfoView.removeAll();
        let count = allRoute.count;
        let width:CGFloat = ScreenSize().width/CGFloat(count)
        for index in 0...count-1 {
            let infoView:RouteInfoView = RouteInfoView()
            infoView.delegate = self;
             self.addSubview(infoView);
            infoView .mas_makeConstraints { (maker) in
                maker?.left.mas_equalTo()(self)?.offset()(CGFloat(index)*(width+1));
                maker?.top.mas_equalTo()(self);
                maker?.bottom.mas_equalTo()(self)?.offset()(-81);
                maker?.width.mas_equalTo()(width);
            }
            infoView.setRouteInfo(info: allRoute[index]);
            self.allInfoView.append(infoView);
        }
    }
    
    
    
    // MARK: - Private
    ///选中了某条路径，更改其他的颜色
    public func selectNavRouteWithRouteID(routeID:NSInteger)->Void{
        if routeID < 0 {
            return
        }
        for aview:RouteInfoView in self.allInfoView {
            if aview.routeInfo.routeID == routeID{
                aview.setSelect(selected: true)     //设置为选中的颜色
            }else{
                aview.setSelect(selected: false);   //设置为未选中的颜色
            }
        }
        self.selectedRouteID = routeID;//当前选中的ID
    }
    
    
    
    ///开始导航
    @objc func startNavButtonAction()->Void{
        if delegate != nil {
            delegate.bootomInfoViewStartNavWithRouteID(routeID: self.selectedRouteID);
        }
    }
    
    
    ///当前选中了某条路线
    func routeInfoViewClickedWithRouteID(routeID: NSInteger) {
        self.selectNavRouteWithRouteID(routeID: routeID);
        if delegate != nil {
            delegate.bottomInfoViewSelectedRouteWithRouteID(routeID: routeID);
        }
    }
    
    
    
}
