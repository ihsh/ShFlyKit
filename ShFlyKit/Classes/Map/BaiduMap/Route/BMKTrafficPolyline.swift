//
//  BMKTrafficPolyline.swift
//  SHKit
//
//  Created by hsh on 2019/1/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///自定义带交通状况的polyline，用于传数据
class BMKTrafficPolyline: BMKPolyline {
    ///MARK
    public var routeID:Int!                         //对应的RouteID
    public var polyline:BMKPolyline!                //多彩线

    public var pointNum:UInt = 0;                   //路线的点数
    public var route:BMKDrivingRouteLine!           //百度的路线结果
    public var savePoint:UnsafeMutablePointer<BMKMapPoint>!//路线创建的BMKMapPoint数组
    
    public var polylineStrokeColors:[UIColor]!      //颜色数组
    public var polylineTextureImages:[UIImage]!     //纹理数组
}
