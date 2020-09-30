//
//  AMapTrackingVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/14.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit
import Masonry

class AMapTrackingVC: UIViewController,MAMapViewDelegate{
    // MARK: - Variable
    public var mapView:MAMapView!
    public var traceManager:MATraceManager!
    
    public var isRecording:Bool = false;
    public var isSaving:Bool = false;
    
    public var currentRecord:AMapRouteRecord!
    public var polyLine:MAPolyline!
    
    private var tracedPolyLines = [MAPolyline]()
    private var tempTraceLocations = [CLLocation]()
    private var totalTraceLength:Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "轨迹"
        self.view.backgroundColor = UIColor.white
        //初始化地图
        initMapView()
        //初始化轨迹追踪
        traceManager = MATraceManager()
        let startBtn = UIButton.initTitle("开始", textColor: UIColor.black, back: UIColor.orange, font: kFont(14), super: nil);
        startBtn.addTarget(self, action: #selector(actionRecordOrStop), for: UIControlEvents.touchUpInside);
        let playBtn = UIButton.initTitle("回放", textColor: UIColor.black, back: UIColor.orange, font: kFont(14), super: nil);
        let lineBtns = LinearBtns.initWithDirection(direction: .Horizontal, btns: [startBtn,playBtn], spans: [0], btnSize: CGSize(width: 100, height: 80))
        self.view.addSubview(lineBtns.0)
        lineBtns.0.mas_makeConstraints { (maker) in
            maker?.left.bottom().right()?.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(mapView.mas_bottom);
        }
    }
    
    
    //定位
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        mapView.showsUserLocation = true;
        mapView.userTrackingMode = .follow;
    }
    
    
    //初始化地图
    private func initMapView()->Void{
        mapView = AMapUIServise.getInitialMap();
        mapView.pausesLocationUpdatesAutomatically = false;
        mapView.allowsBackgroundLocationUpdates = true;
        mapView.distanceFilter = 10.0;
        mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        mapView.delegate = self;
        self.view.addSubview(mapView);
        self.view.sendSubview(toBack: mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(self.view);
            maker?.bottom.mas_equalTo()(self.view)?.offset()(-100);
        }
    }
    
    
    
    //停止定位
    public func stopLocation()->Void{
        mapView.setUserTrackingMode(.none, animated: false);
        mapView.showsUserLocation = false;
    }

  
    //历史记录
    public func historyShow()->Void{
        
    }
    
    
    
    @objc public func actionRecordOrStop()->Void{
        isRecording = !isRecording;
        if isRecording == true {
            if currentRecord == nil{
                currentRecord = AMapRouteRecord()
            }
            addLocation(location: mapView.userLocation.location);
        }else{
            addLocation(location: mapView.userLocation.location);
            actionSave()
        }
    }
    
    
    
    //定位按钮点击
    public func locationBtnClick(sender:UIButton)->Void{
        if mapView.userTrackingMode == .follow {
            mapView.setUserTrackingMode(.none, animated: false);
            mapView.showsUserLocation = false;
        }else{
            mapView.setUserTrackingMode(.follow, animated: true);
        }
    }
    
    
    
    //添加一个地理位置
    public func addLocation(location:CLLocation?)->Void{
        if location != nil {
            currentRecord.addLocation(location: location!);
        }
    }
    
    
    public func actionSave()->Void{
        self.isRecording = false;
        self.isSaving = true;
        
        self.mapView.remove(self.polyLine);
        self.polyLine = nil;
        
        self.mapView.removeOverlays(tracedPolyLines);
        self.queryTrace(locations: self.currentRecord.locations, saving: true)
    }
    
    
    
    //查询轨迹
    public func queryTrace(locations:[CLLocation],saving:Bool)->Void{
        var tmpArr = [MATraceLocation]()
        for loc:CLLocation in locations {
            let trackLoc = MATraceLocation()
            trackLoc.loc = loc.coordinate;
            trackLoc.speed = loc.speed * 3.6        // m/s->km/h
            trackLoc.time = loc.timestamp.timeIntervalSince1970 * 1000;
            trackLoc.angle = loc.course;
            tmpArr.append(trackLoc);
        }
        
        weak var weakSelf = self;
        traceManager.queryProcessedTrace(with: tmpArr, type: .aMap, processingCallback: { (index:Int32, arr:[MATracePoint]?) in
            
        }, finishCallback: { (arr:[MATracePoint]?, distance:Double) in
            if self.isSaving == true{
                weakSelf?.totalTraceLength = 0.0;
                weakSelf?.currentRecord.updateTracedLocations(traces: arr!);
                
                weakSelf?.isSaving = false;
            }
            weakSelf?.addFullTrace(arr);
            self.totalTraceLength += distance;
        }) { (errCode:Int32, errDesc:String?) in
            print(errDesc);
            weakSelf?.isSaving = false;
        }
    }
    
    
    

    func addFullTrace(_ tracePoints: [MATracePoint]?) {
        let polyline: MAPolyline? = self.makePolyline(with: tracePoints)
        if polyline == nil {
            return
        }
        self.tracedPolyLines.append(polyline!)
        self.mapView.add(polyline!)
    }
    
    func makePolyline(with tracePoints: [MATracePoint]?) -> MAPolyline? {
        if tracePoints == nil || tracePoints!.count < 2 {
            return nil
        }
        var pCoords = [CLLocationCoordinate2D]()
        for i in 0..<tracePoints!.count {
            pCoords.append(CLLocationCoordinate2D(latitude: tracePoints![i].latitude, longitude: tracePoints![i].longitude))
        }
        let polyline = MAPolyline(coordinates: &pCoords, count: UInt(pCoords.count))
        return polyline
    }
    
    
    func coordinatesFromLocationArray(locations: [CLLocation]?) -> [CLLocationCoordinate2D]? {
        if locations == nil || locations!.count == 0 {
            return nil
        }
        
        var coordinates = [CLLocationCoordinate2D]()
        for location in locations! {
            coordinates.append(location.coordinate)
        }
        
        return coordinates
    }
    
    
    
    //MARK:- MAMapViewDelegate
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if updatingLocation == false {
            return
        }
        let location: CLLocation? = userLocation.location
        if location == nil || !isRecording {
            return
        }
        //过滤结果
        if userLocation.location.horizontalAccuracy < 100.0 {
            
            let lastDis = userLocation.location.distance(from: self.currentRecord!.endLocation()!)
    
            if lastDis < 0.0 || lastDis > 10 {
                addLocation(location: userLocation.location)
                if self.polyLine == nil {
                    self.polyLine = MAPolyline.init(coordinates: nil, count: 0)
                    self.mapView.add(self.polyLine!)
                }
                var coordinates = coordinatesFromLocationArray(locations: self.currentRecord!.locations)
                if coordinates != nil {
                    self.polyLine!.setPolylineWithCoordinates(&coordinates!, count: coordinates!.count)
                }
            
                self.mapView.setCenter(userLocation.location.coordinate, animated: true)
                // trace
                self.tempTraceLocations.append(userLocation.location)
                if self.tempTraceLocations.count >= 10 {
                    self.queryTrace(locations: self.tempTraceLocations, saving: false)
                    self.tempTraceLocations.removeAll()
                    // 把最后一个再add一遍，否则会有缝隙
                    self.tempTraceLocations.append(userLocation.location)
                }
            }
        }
        
        var speed = location!.speed
        if speed < 0.0 {
            speed = 0.0
        }
    }
    
    
    
    func mapView(_ mapView: MAMapView, didChange mode: MAUserTrackingMode, animated: Bool) {
        if mode == MAUserTrackingMode.none {
//            locationButton?.setImage(imageNotLocate, for: UIControlState.normal)
        }else {
//            locationButton?.setImage(imageLocated, for: UIControlState.normal)
        }
    }
    
    
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if self.polyLine != nil && overlay.isEqual(self.polyLine!) {
            let view = MAPolylineRenderer(polyline: overlay as? MAPolyline)
            view?.lineWidth = 5.0
            view?.strokeColor = UIColor.red
            return view
        }
        if (overlay is MAPolyline) {
            let view = MAPolylineRenderer(polyline: overlay as? MAPolyline)
            view?.lineWidth = 10.0
            view?.strokeColor = UIColor.darkGray.withAlphaComponent(0.8)
            return view
        }
        return nil
    }
    
}
