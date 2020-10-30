//
//  AMapBaseView.swift
//  SHKit
//
//  Created by hsh on 2019/1/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit

public class AMapBaseView: UIView,MAMapViewDelegate,MAMultiPointOverlayRendererDelegate{
    //mark
    public var mapView:MAMapView!
    
    
    //MARK
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.mapView = MAMapView()
        self.addSubview(self.mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    ///显示用户位置
    public func showUserLocation(_ show:Bool = true)->Void{
        self.mapView.showsUserLocation = show;
        self.mapView.userTrackingMode = .followWithHeading;
    }
    
    
    ///显示室内地图
    public func enableIndoorMap(_ enable:Bool)->Void{
        self.mapView.isShowsIndoorMap = enable;
    }
    
    
    ///改变地图图层
    public func changeMapType(type:MAMapType)->Void{
        self.mapView.mapType = type;
    }
    
    
    ///开关交通状况
    public func enableTraffic(_ enable:Bool)->Void{
        self.mapView.isShowTraffic = enable;
    }
    
    
    ///显示英文地图
    public func showMapForEnglish(show:Bool)->Void{
        self.mapView .perform(NSSelectorFromString("setMapLanguage:"), with: NSNumber.init(value: show ? 1 : 0))
    }
    
    
    ///设置自定义地图样式
    public func setCustomMapStyle(pathStr:String,styleID:String?)->Void{
        let options:MAMapCustomStyleOptions = MAMapCustomStyleOptions()
        if styleID != nil{
            options.styleId = styleID;
            self.mapView.setCustomMapStyleOptions(options);
        }else{
            var path =  Bundle.main.bundlePath;
            path.append(pathStr);
            let jsonData = NSData.init(contentsOfFile: path)
            if jsonData != nil{
                options.styleData = jsonData! as Data;
                self.mapView.setCustomMapStyleOptions(options);
            }
        }
    }
    
    
    
    public func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKind(of: MAUserLocation.self) {
            return nil;
        }
        return nil;
    }

    
//    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
//        let customUser = MAUserLocationRepresentation()
//        customUser.showsAccuracyRing = true   //显示精度圈
//        customUser.showsHeadingIndicator = true //是否开启方向指示器
//        customUser.fillColor = UIColor.green;
//        customUser.strokeColor = UIColor.blue;
//        customUser.lineWidth = 2;
//        customUser.enablePulseAnnimation = true;    //律动效果
////        customUser.locationDotBgColor =
////        customUser.image =
//
//    }
    
    
    
    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        //海量点图层
        if (overlay.isKind(of: MAMultiPointOverlay.self)){
            let renderer = MAMultiPointOverlayRenderer(multiPointOverlay: overlay as? MAMultiPointOverlay)
            renderer!.delegate = self
            ///设置图片
            renderer!.icon = UIImage(named: "marker_blue")
            ///设置锚点
            renderer!.anchor = CGPoint(x: 0.5, y: 1.0)
            return renderer;
        }
        return nil;
    }
    
    
    public func multiPointOverlayRenderer(_ renderer: MAMultiPointOverlayRenderer!, didItemTapped item: MAMultiPointItem!) {
        
    }
}
