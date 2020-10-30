//
//  RouteInfoView.swift
//  SHKit
//
//  Created by hsh on 2018/12/20.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit

///多路径选择界面底部栏中视图类

///路线选择视图代理
protocol RouteInfoViewDelegate {
    //选择了某个路线
    func routeInfoViewClickedWithRouteID(routeID:NSInteger);
}


//路线信息图
class RouteInfoView: UIView{
    // MARK: - Variable
    public var delegate:RouteInfoViewDelegate!          //代理对象
    public var selected:Bool = false;                   //是否选中
    public var routeInfo:RouteInfoModel!                //当前视图所对应的路径信息
    
    public var selectedColor:UIColor = UIColor.colorRGB(red: 26, green: 166, blue: 239) //选中的颜色
    public var deselectedColor:UIColor = UIColor.gray                                   //非选中颜色
    
    
    // MARK: - Private
    private var boardView = SHBorderView()
    private var routeTagL:UILabel!              //路线特征--例如，距离最短
    private var timeL:UILabel!                  //所需时间
    private var lengthL:UILabel!                //距离
    private var coverBtn:UIButton!              //点击按钮
    
    
    
    // MARK: - Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initViews()
    }
    
    
    private func initViews()->Void{
        self.backgroundColor = UIColor.white;
        self.boardView.borderStyle = 12;
        self.addSubview(boardView)
        self.routeTagL = UILabel.initText(nil, font: kFont(12), textColor: deselectedColor, alignment: .center, super: self.boardView);
        self.timeL = UILabel.initText(nil, font: kFont(18), textColor: UIColor.black, alignment: .center, super: self.boardView);
        self.timeL.numberOfLines = 2;
        self.lengthL = UILabel.initText(nil, font: kFont(10), textColor: deselectedColor, alignment: .center, super: self.boardView);
        self.coverBtn = UIButton.init()
        self.coverBtn.addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside);
        self.coverBtn.backgroundColor = UIColor.clear;
        self.boardView.addSubview(self.coverBtn);
        //约束
        boardView.mas_makeConstraints { (maker) in
            maker?.top.left()?.bottom()?.right()?.mas_equalTo()(self);
        }
        routeTagL.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(boardView)?.offset()(24);
            maker?.centerX.mas_equalTo()(boardView);
        }
        timeL.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(boardView)?.offset()(8);
            maker?.right.mas_equalTo()(boardView)?.offset()(-16);
            maker?.top.mas_equalTo()(routeTagL.mas_bottom)?.offset()(10);
        }
        lengthL.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(boardView)?.offset()(8);
            maker?.right.mas_equalTo()(boardView)?.offset()(-16);
            maker?.top.mas_equalTo()(timeL.mas_bottom)?.offset()(10);
        }
        coverBtn.mas_makeConstraints { (maker) in
            maker?.top.left()?.bottom()?.right()?.mas_equalTo()(boardView);
        }
        
    }
    
    
    
    // MARK: - Interface
    //填充数据
    public func setRouteInfo(info:RouteInfoModel)->Void{
        self.routeInfo = info;
        self.routeTagL.text = info.routeTag;
        self.timeL.text = AMapMathService.normalizedRemainTime(time: info.routeTime);
        self.lengthL.text = AMapMathService.normalizedRemainDistance(distance: info.routeLength);
    }
    
    
    
    //设置选中和不选中的颜色
    public func setSelect(selected:Bool)->Void{
        self.selected = selected;
        self.timeL.textColor = selected ? selectedColor : deselectedColor;
        self.routeTagL.textColor = selected ? selectedColor : deselectedColor;
        self.lengthL.textColor = selected ? selectedColor : deselectedColor;
    }
    
    
    
    // MARK: - Private
    @objc private func buttonAction()->Void{
        if  delegate != nil {
            delegate.routeInfoViewClickedWithRouteID(routeID: routeInfo.routeID);
        }
    }
    
}
