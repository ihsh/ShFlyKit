//
//  BMKTrackPlayView.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///轨迹信息类
class BMKTrackModel: NSObject {
    public var coodinate:CLLocationCoordinate2D!
    public var speed:Double = 0
    public var timestamp:TimeInterval = 0
}


///显示地图轨迹视图类
class BMKTrackPlayView: UIView ,BMKMapViewDelegate{
    /// MARK: - Variable
    public var lineWidth:CGFloat = 2
    
    //Data
    private var mapView:BMKMapView!
    private var polyLine:BMKPolyline!                                   //轨迹
    private var speedColors:NSMutableArray!                             //运动轨迹颜色
    private var count:Int = 0
    private var runRecords:UnsafeMutablePointer<BMKMapPoint>!           //运动点
    private var maxSpeed:Double = 0;
    private var minSpeed:Double = 0;
    
    
    // MARK: - LOAD
    override init(frame: CGRect) {
        super.init(frame: frame);
        mapView = BMKMapUIService.getInitialMap()
        self.addSubview(mapView);
        mapView.delegate = self;
        mapView.mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.top()?.mas_equalTo()(self);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Interface
    public func showData(data:[BMKTrackModel])->Void{
        //遇到坐标不准，请进行坐标准换，高德等使用的是GCJ-02,百度是另一套
        //BMKCoordTrans(common, BMK_COORD_TYPE.COORDTYPE_COMMON, BMK_COORD_TYPE.COORDTYPE_BD09LL)
        speedColors = NSMutableArray()
        let indexs = NSMutableArray()
        //初始化数据
        count = data.count;
        runRecords = UnsafeMutablePointer.allocate(capacity: count);
        for (index,track) in data.enumerated(){
            runRecords[index] = BMKMapPointForCoordinate(track.coodinate);
            speedColors.add(self.getColorForSpeed(speed: track.speed));
            indexs.add(NSNumber.init(value: index));
        }
        print("\(minSpeed)------\(maxSpeed)")
        //初始化轨迹
        polyLine = BMKPolyline.init(points: runRecords, count: UInt(count), textureIndex: indexs as? [NSNumber]);
        //显示轨迹
        self.mapView.add(polyLine);
        let inset:UIEdgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20);
        self.mapView.setVisibleMapRect(polyLine.boundingMapRect, edgePadding: inset, animated: true);
    }
    
    
    //设置要显示的地图
    public func replaceMapView(mapView:BMKMapView)->Void{
        self.mapView = mapView;
        self.mapView.delegate = self;
    }
    
    
    
    /// MARK: - Delegate
    //显示轨迹
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if (overlay.isKind(of: BMKPolyline.self)) {
            let render = BMKPolylineView.init(polyline:polyLine);
            render?.lineWidth = lineWidth;
            render?.colors = speedColors as? [UIColor];
            return render;
        }
        return nil;
    }
    
    
    
    /// MARK: - Private
    //根据速度返回颜色
    private func getColorForSpeed(speed:Double)->UIColor{
        maxSpeed = max(maxSpeed,speed)
        minSpeed = min(minSpeed,speed)
        
        let warmHue:CGFloat = 0.02;
        let coldHue:CGFloat = 0.35;
        
        let hue:CGFloat = coldHue - CGFloat(speed - minSpeed)*CGFloat(coldHue - warmHue)/CGFloat(maxSpeed - minSpeed);
        return UIColor.init(hue: hue, saturation: 1, brightness: 1, alpha: 1);
    }

    
}
