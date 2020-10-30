//
//  BaiduMaoVC.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

//
//class BaiduMaoVC: UIViewController,BMKCarAnimateDelegate,HeatBeatTimerDelegate {
//    ///MARK
//    public var locationManager:BMKLocationService!
//
//    public var mapView:BMKMulRouteView!         //多路线地图
//    public var routePlan:BMKRoutePlan!          //路线规划
//    public var carAnimate:BMKCarAnimate?        //小车动画类
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //多路径地图
//        mapView = BMKMulRouteView()
//        BMKMapUIService.enableCustomMap(true);
//        self.view.addSubview(mapView);
//        mapView .mas_makeConstraints { (maker) in
//            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
//        }
//        //小车动画
//        carAnimate = BMKCarAnimate()
//        mapView.carAnimate = carAnimate;//设置小车对象
//        carAnimate?.delegate = self;
//
//        //定位管理
//        locationManager = BMKLocationService()
//        locationManager.setAdaptMap(mapView.mapView);
//        locationManager.startLocation()
//        locationManager.startUpdatingLocation(true);
//    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated);
//        //路线规划
//        routePlan = BMKRoutePlan()
//        routePlan.setAdaptMap(self.mapView.mapView);
//        //设置路线规划的代理
//        routePlan.delegate = self.mapView;
//
//
//        //开始路线规划
//        let startPoint = CLLocationCoordinate2D(latitude: 22.572025, longitude: 114.116530)
//        let endPoint = CLLocationCoordinate2D(latitude: 22.550398, longitude: 113.932844)
//        routePlan.driveRoutePlan(start: startPoint, end: endPoint, ways: nil, policy: BMK_DRIVING_TIME_FIRST)
//    }
//
//
//    deinit {
//        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "cara");
//    }
//
//
//    //MARK
//    func carAnnoViewHasSet() {
//        if mapView.routes.count > 0 {
//            carAnimate?.setAnimateForLine(mapView.routes.first!);
//            HeatBeatTimer.shared.addTimerTask(identifier: "cara", span: 3, repeatCount: 0, delegate: self);
//        }
//    }
//
//
//    func timeTaskCalled(identifier: String) {
//         self.carAnimate?.changeTraceIndex()
//    }
//}
