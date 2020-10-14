//
//  AmapPoiSelectVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/12.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapSearchKit
import AMapNaviKit

///位置选点类

protocol AmapPoiSelectDelegate {
    //选中的poi的地理位置
    func selectPoiResultForLocation(_ location:CLLocationCoordinate2D)
}


class AmapPoiSelectVC: UIViewController,MAMapViewDelegate ,AMapPoiResultTableDelegate{
    //UI定制
    public var zoomLevel:CGFloat = 17                               //放大倍数
    public var tableHeight:CGFloat = ScreenSize().height/2            //表视图高度
    public var searchRadius:NSInteger = 800                         //搜索半径
    //["住宅","学校","楼宇","地铁","公交","医院","宾馆","风景","小区","政府","公司","餐饮","汽车","生活","交通","金融","停车场","购物","体育","道路"]
    public var searchTypes:NSArray = ["楼宇","住宅","公交","餐饮"]      //类型
    public var centerImage:UIImage? = UIImage.name("wateRedBlank")   //中心点图片名字
    public var gpsNormalImageName:String = "gpsnormal"
    public var gpsHighLightImageName:String = "gpssearchbutton"
    
    public var delegate:AmapPoiSelectDelegate?
    public var maMapView:MAMapView!                                  //高德地图
    
    // MARK: - Variable
    private var search:AMapService!                                //地图搜索类
    private var tableView:AMapPoiResultTable!                        //显示的表视图
    private var searchTypeSegment:UISegmentedControl!                //分段选择器
    private var locationBtn:UIButton!                                //定位按钮
    private var centerAnnotationView:UIImageView!                    //中心的图标
    
    //data
    private var isMapViewRegionChangedFromTableView:Bool = false    //区域改变是否来自于表视图选中
    private var isLocated:Bool = false                              //是否已定位
    private var searchPage:NSInteger = 0                            //搜索页码
    private var currentType:String = "全部"                          //当前搜索类型
   
    
    
    // MARK: - Load
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化表视图
        self.initTableView()
        //初始化地图
        self.initMapView()
        //初始化搜索
        self.initSearch()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        //初始化中心点
        self.initCenterView()
        //初始化定位按钮
        self.initLocationBtn()
        //初始化类型选择
        self.initSearchTypeView()
        //地图放大尺寸
        self.maMapView.zoomLevel = zoomLevel;
        //显示用户位置
        self.maMapView.showsUserLocation = true;
    }
    
    
    //初始化地图
    private func initMapView()->Void{
        self.maMapView = AMapUIServise.getInitialMap()
        //设置地图代理
        self.maMapView.delegate = self;
        self.view.addSubview(maMapView);
        maMapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(self.view);
            maker?.bottom.mas_equalTo()(tableView.mas_top);
        }
    }
    
    
    //初始化表视图
    private func initTableView()->Void{
        self.tableView = AMapPoiResultTable()
        self.view.addSubview(tableView);
        //表视图点击的回调的代理
        self.tableView.delegate = self;
        tableView.mas_makeConstraints { (maker) in
            maker?.height.mas_equalTo()(tableHeight);
            maker?.left.bottom()?.right()?.mas_equalTo()(self.view);
        }
    }
    
    
    //初始化搜索
    private func initSearch()->Void{
        self.search = AMapService()
        self.searchPage = 1;
        self.search.searchAPI?.delegate = self.tableView;//放搜索的结果直接返回在表视图
    }
    
    
    //初始化中心点
    private func initCenterView()->Void{
        self.centerAnnotationView = UIImageView.init(image: centerImage);
        self.centerAnnotationView.center = CGPoint(x: self.maMapView.center.x, y: self.maMapView.center.y - self.centerAnnotationView.bounds.height/2);
        self.view.addSubview(self.centerAnnotationView);
    }
    
    
    //初始化定位按钮
    private func initLocationBtn()->Void{
        self.locationBtn = UIButton.initImage(UIImage.name(gpsNormalImageName));
        self.locationBtn.autoresizingMask = .flexibleTopMargin;
        self.locationBtn.backgroundColor = UIColor.white;
        self.locationBtn.layer.cornerRadius = 3;
        self.locationBtn.addTarget(self, action: #selector(actionLocation), for: UIControlEvents.touchUpInside);
        self.view.addSubview(self.locationBtn);
        locationBtn.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(maMapView.mas_bottom)?.offset()(-50);
            maker?.right.mas_equalTo()(maMapView.mas_right)?.offset()(-10);
            maker?.width.height()?.mas_equalTo()(32);
        }
    }
    
    
    //初始化类型切换
    private func initSearchTypeView()->Void{
        self.currentType = (searchTypes.firstObject as? String)!;
        
        self.searchTypeSegment = UISegmentedControl.init(items: searchTypes as? [Any])
        self.searchTypeSegment.layer.cornerRadius = 3;
        self.searchTypeSegment.backgroundColor = UIColor.white;
        self.searchTypeSegment.autoresizingMask = .flexibleTopMargin;
        self.searchTypeSegment.selectedSegmentIndex = 0;
        self.searchTypeSegment.addTarget(self, action: #selector(actionTypeChanged(sender:)), for: UIControlEvents.valueChanged);
        self.view.addSubview(self.searchTypeSegment);
        searchTypeSegment.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(maMapView)?.offset()(10);
            maker?.top.mas_equalTo()(maMapView.mas_bottom)?.offset()(-50);
            maker?.right.mas_equalTo()(maMapView)?.offset()(-50);
            maker?.height.mas_equalTo()(32);
        }
    }
    
    
    //中心点变化动画
    private func centerAnnotationAnimate()->Void{
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            var center = self.centerAnnotationView.center;
            center.y -= 20;
            self.centerAnnotationView.center = center;
        }, completion: nil)
        UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            var center = self.centerAnnotationView.center;
            center.y += 20;
            self.centerAnnotationView.center = center;
        }, completion: nil)
    }
    
    
    
    // MARK: - Delegate
    func didTableSelectedChanged(selectedPoi: AMapPOI) {
        //防止两次点击
        if (self.isMapViewRegionChangedFromTableView == true) {
            return;
        }
        self.isMapViewRegionChangedFromTableView = true;
        let location = CLLocationCoordinate2D(latitude: Double(selectedPoi.location?.latitude ?? 0), longitude: Double(selectedPoi.location?.longitude ?? 0))
        //设置选择的地点作为中心点
        self.maMapView.setCenter(location, animated: true);
        
        if delegate != nil {
            delegate?.selectPoiResultForLocation(location);
        }
    }
    
    
    //点击位置选项
    func didPositionUserLocation() {
        if (self.isMapViewRegionChangedFromTableView == true) {
            return;
        }
        self.isMapViewRegionChangedFromTableView = true;
        self.maMapView.setCenter(self.maMapView.userLocation.coordinate, animated: true);
    }
    
    
    //加载更多
    func didLoadMoreBtnClick() {
        self.searchPage += 1;
        self.search.searchPoiWithCenterCoordinate(coord: self.maMapView.centerCoordinate, type: self.currentType, page: self.searchPage)
    }
    
    
    // MARK: - MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        //来自地图本身的区域变化
        if (self.isMapViewRegionChangedFromTableView == false && self.maMapView.userTrackingMode == .none) {
            self.actionSearchAroundAt(coordinate: self.maMapView.centerCoordinate);
        }
        self.isMapViewRegionChangedFromTableView = false;
    }
    
    
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if (updatingLocation == false || userLocation.location.horizontalAccuracy < 0) {
            return;
        }
        //第一次定位
        if (self.isLocated == false) {
            self.isLocated = true;
            self.maMapView.userTrackingMode = .follow;
            self.maMapView.setCenter(CLLocationCoordinate2D(latitude: userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude), animated: true);
            self.actionSearchAroundAt(coordinate: userLocation.location.coordinate);
        }
    }
    
    
    func mapView(_ mapView: MAMapView!, didChange mode: MAUserTrackingMode, animated: Bool) {
        if (mode == .none) {
            self.locationBtn.setImage(UIImage.name(gpsNormalImageName), for: .normal)
        }else{
            self.locationBtn.setImage(UIImage.name(gpsHighLightImageName), for: .normal);
        }
    }
    
    
    func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
        
    }
   

    
    // MARK: - Private
    private func actionSearchAroundAt(coordinate:CLLocationCoordinate2D)->Void{
        self.search.searchReGeoCodeWithCoordinate(coordinate: coordinate);
        self.search.searchPoiWithCenterCoordinate(coord: coordinate, type: self.currentType, page: self.searchPage);
        self.searchPage = 1;
        self.centerAnnotationAnimate()
    }
    
    
    
    //定位操作
    @objc private func actionLocation()->Void{
        if (self.maMapView.userTrackingMode == .follow) {
            self.maMapView.setUserTrackingMode(.none, animated: true);
        }else{
            self.searchPage = 1;
            self.maMapView.setCenter(self.maMapView.userLocation.coordinate, animated: true);
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.maMapView.setUserTrackingMode(.follow, animated: true)
            }
        }
    }
    
    
    
    //类型切换
    @objc private func actionTypeChanged(sender:UISegmentedControl)->Void{
        self.currentType = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        self.actionSearchAroundAt(coordinate: self.maMapView.centerCoordinate);
    }
    
    
}
