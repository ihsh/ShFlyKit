//
//  AMapTrackPlayVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/10.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


//轨迹类
public class TrackModel: NSObject {
    public var coodinate:CLLocationCoordinate2D!
    public var speed:Double = 0
    public var timestamp:TimeInterval = 0
}


///显示地图轨迹视图类
public class AMapTrackPlayView: UIView,MAMapViewDelegate{
    // MARK: - Variable
    public var lineWidth:CGFloat = 6
    
    //data
    private var mapView:MAMapView!
    private var _polyLine:MAMultiPolyline!                               //轨迹
    private var _speedColors:NSMutableArray!                             //运动轨迹颜色
    private var _count:Int = 0
    private var _runRecords:UnsafeMutablePointer<CLLocationCoordinate2D>!//运动点
    private var maxSpeed:Double = 4;
    private var minSpeed:Double = 2;

    
    // MARK: - LOAD
    override init(frame: CGRect) {
        super.init(frame: frame);
        mapView = AMapUIServise.getInitialMap();
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
    public func showData(data:[TrackModel])->Void{
        _speedColors = NSMutableArray()
        let indexs = NSMutableArray()
        //初始化数据
        _count = data.count;
        _runRecords = UnsafeMutablePointer.allocate(capacity: _count);
        for (index,track) in data.enumerated(){
            _runRecords[index].latitude = track.coodinate.latitude;
            _runRecords[index].longitude = track.coodinate.longitude;
            _speedColors.add(self.getColorForSpeed(speed: track.speed));
            indexs.add(NSNumber.init(value: index));
        }
        print("\(minSpeed)------\(maxSpeed)")
        //初始化轨迹
        _polyLine = MAMultiPolyline.init(coordinates: _runRecords, count: UInt(_count), drawStyleIndexes: indexs as? [NSNumber]);
        //显示轨迹
        self.mapView.add(_polyLine);
        let inset:UIEdgeInsets = UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20);
        self.mapView.setVisibleMapRect(_polyLine.boundingMapRect, edgePadding: inset, animated: true);
    }

    
    
    //更换地图
    public func replaceMapView(mapView:MAMapView)->Void{
        self.mapView = mapView;
        self.mapView.delegate = self;
    }
    
    
    // MARK: - Delegate
    //显示轨迹
    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: MAMultiPolyline.self)) {
            let render = MAMultiColoredPolylineRenderer.init(polyline:_polyLine);
            render?.lineWidth = lineWidth;
            render?.strokeColors = _speedColors as? [UIColor];
            render?.lineCapType = kMALineCapRound;
            render?.lineJoinType = kMALineJoinRound;
            render?.isGradient = true;
            return render;
        }
        return nil;
    }
    
    
    
    // MARK: - Private
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
