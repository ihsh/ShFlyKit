//
//  AMapVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/29.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


class AMapVC: UIViewController {

    private var mapView:MAMapView!
    private var controlView:MapControlView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = AMapUIServise.getInitialMap();
        self.view.addSubview(mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        controlView = MapControlView()
        controlView.initDefaultControl(topHeight: 100, bottomHeight: 100, rightWidth: 50);
        self.view.addSubview(controlView);
        controlView.mas_makeConstraints { (maker) in
            maker?.left.bottom()?.right()?.top()?.mas_equalTo()(self.view);
        }
        //添加按钮
        addBtns()
    }
    
    
    
    
    private func addBtns()->Void{
        //底部按钮
        let lineBtn = UIButton.initTitle("路线", textColor: UIColor.white, back: UIColor.colorRGB(red: 85, green: 134, blue: 246), font: kFont(14),super: controlView.bottomBar);
        lineBtn.tag = 100;
        lineBtn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        lineBtn.setRadius(20);
        lineBtn.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(controlView.bottomBar);
            maker?.bottom.mas_equalTo()(controlView.bottomBar)?.offset()(-60);
            maker?.width.mas_equalTo()(100);
            maker?.height.mas_equalTo()(40);
        }
        let locateBtn = UIButton.initImage(UIImage.name("locate_btn"), back: false, super: controlView.bottomBar);
        locateBtn.setRadius(15);
        locateBtn.tag = 101;
        locateBtn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        locateBtn.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(controlView.bottomBar)?.offset()(16);
            maker?.centerY.mas_equalTo()(lineBtn);
            maker?.width.height()?.mas_equalTo()(30);
        }
        
        //顶部按钮
        let searchBar = SearchBar.initSearchBar(placeHolder: "查找地点、公交、地铁", type: LayoutType.Inner, radius: 5, barHeight: 45);
        controlView.topBar.addSubview(searchBar);
        searchBar.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(controlView.topBar);
            maker?.height.mas_equalTo()(60);
            maker?.top.mas_equalTo()(controlView.topBar)?.offset()(50);
        }
        
        let width:CGFloat = 30;
        let setting = UIButtonLayout.init(UIButton.initImage(UIImage.name("person_headp")), left: 6, right: 2, width: width, height: width);
        setting.btn.tag = 102;
        setting.btn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        let voice = UIButtonLayout.init(UIButton.initImage(UIImage.name("camera")), left: 2, right: 6, width: width, height: width);
        voice.btn.tag = 103;
        voice.btn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        
        searchBar.addSearchItem(items: [setting], inner: true, left: true);
        searchBar.addSearchItem(items: [voice], inner: true, left: false);
        
        
        //右侧按钮
        let switchBtn = UIButton.initImage(UIImage.name("camera"));
        switchBtn.backgroundColor = UIColor.white;
        switchBtn.tag = 104;
        switchBtn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        switchBtn.setRadius(3);
        let tracffic = UIButton.initImage(UIImage.name("camera"));
        tracffic.tag = 105;
        tracffic.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        
        let moreBtn = UIButton.initImage(UIImage.name("camera"));
        moreBtn.tag = 106;
        moreBtn.addTarget(self, action: #selector(btnsClick(sender:)), for: UIControlEvents.touchUpInside);
        
        let linearBtns = LinearBtns.initWithDirection(direction: LinearDirection.Vertical, btns: [switchBtn,tracffic,moreBtn], spans: [5], btnSize: CGSize(width: width, height: width),lineColor: UIColor.colorRGB(red: 237, green: 237, blue: 237),dashline: true);
        linearBtns.0.setCorners(radius: 3, color: UIColor.white, width: 0);
        controlView.rightBar.addSubview(linearBtns.0);
        
        linearBtns.0.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(controlView.rightBar.mas_right)?.offset()(-16);
            maker?.top.mas_equalTo()(controlView.rightBar)?.offset()(20);
            maker?.width.mas_equalTo()(linearBtns.1.width);
            maker?.height.mas_equalTo()(linearBtns.1.height);
        }
    }
    
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    
    
    
    //点击按钮的事件
    @objc private func btnsClick(sender:UIButton)->Void{
        let tag:NSInteger = sender.tag;
        var remark = "";
        
        switch tag {
        case 100:
            self.navigationController?.popViewController(animated: true);
            remark = "路线";
        case 101:
            remark = "定位";
        case 102:
            remark = "个人中心";
        case 103:
            remark = "语音按钮";
        case 104:
            remark = "地图类型切换";
        case 105:
            remark = "交通状况开关";
        case 106:
            remark = "更多设置";
        default:
            remark = "未定义";
        }
    }

}
