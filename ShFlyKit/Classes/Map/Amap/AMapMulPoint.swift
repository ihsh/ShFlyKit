//
//  AMapMulPoint.swift
//  SHKit
//
//  Created by hsh on 2019/1/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import MAMapKit

///海量点图层控制类


class AMapMulPoint: NSObject {
    //MARK
    private var mapView:MAMapView!
    private var coordinates:[CLLocationCoordinate2D] = []       //保存所有的点
    private var lastOverlay:MAMultiPointOverlay!                //海量点图层
    
    
    public func setAdapeMap(_ map:MAMapView)->Void{
        self.mapView = map;
    }
    
    
    //添加点
    public func addCoodinates(_ coordinates:[CLLocationCoordinate2D])->Void{
        //所有点集合
        var points:[CLLocationCoordinate2D] = [];
        //之前的所有点
        points.append(contentsOf: self.coordinates);
        //添加的所有点
        points.append(contentsOf: coordinates);
        //保存到所有点数组
        self.coordinates.append(contentsOf: coordinates);
        
        //创建MAMultiPointItem集合
        var items:[MAMultiPointItem] = [];
        for coor in points {
            let item = MAMultiPointItem()
            item.coordinate = coor;
            items.append(item);
        }
        //创建海量点overlay
        let overlay = MAMultiPointOverlay(multiPointItems: items);
        if lastOverlay != nil {
            self.mapView.remove(self.lastOverlay)
        }
        self.mapView.add(overlay);
        self.lastOverlay = overlay;
    }
    
}
