//
//  MapTrackPlayVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/27.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


class AMapTrackPlayVC: UIViewController,MAMapViewDelegate,AMapPathTrackViewDelegate,HeatBeatTimerDelegate {
    // MARK: - Variable
    var mapView:MAMapView!
    var trackView:AMapPathTrackView!                    //显示轨迹的地图
    private var coordinates:[CLLocationCoordinate2D]!   //所有的坐标点
    private var passedTraceCoordIndex:NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = AMapUIServise.getInitialMap();
        self.view.addSubview(mapView);
        mapView.delegate = self;
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        
        //地图轨迹类
        trackView = AMapPathTrackView()
        trackView.delegate = self;
        trackView.initOrExchangeMap(map: mapView);
       
        //给起止点和当前点
        let startPoint = CLLocationCoordinate2D(latitude: 22.571133, longitude: 114.060750)
        let endPoint = CLLocationCoordinate2D(latitude: 22.581524, longitude: 113.953821)
        trackView.startWithPoint(start: startPoint, end: endPoint, cur: startPoint)
    }
    
    deinit {
        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "location");
    }
    
    
    //选择某个点
    private func selectPoint()->Void{
       self.passedTraceCoordIndex += 3
        if passedTraceCoordIndex >= coordinates.count - 1 {
            passedTraceCoordIndex = coordinates.count - 1;
        }
        let location = coordinates[passedTraceCoordIndex];
        trackView.updateCurLocation(location,maxTime: 3);
    }
    
    
    
    //地图路径规划成功传数据
    func calculRouteSuccess(coordinates: [CLLocationCoordinate2D]) {
        self.coordinates = coordinates;
        HeatBeatTimer.shared.addTimerTask(identifier: "location", span: 3, repeatCount: 0, delegate: self);
   
    }
    
    
    public func timeTaskCalled(identifier: String) {
        self.selectPoint();
    }
   
    

    
}
