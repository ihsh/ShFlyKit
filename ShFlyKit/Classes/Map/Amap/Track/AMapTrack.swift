//
//  AMapTrack.swift
//  SHKit
//
//  Created by hsh on 2019/1/15.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class AMapTrackPoint: NSObject {
    public var coordinate:CLLocationCoordinate2D!
    public var locateTime:TimeInterval!
    public var speed:Double!    //速度 km/h
    public var height:Double!
    public var accuracy:Double! //定位精确度
    public var createTime:TimeInterval!  //上传时间，金聪服务端检索返回时有效
    
}


class AMapTrackObject: NSObject {
    public var trackID:String!
    public var distance:UInt!
    public var duration:TimeInterval!
    public var points:[AMapTrackPoint]!
}



class AMapTrack: NSObject {
    public var distanceFilter:CLLocationDistance!
    public var desiredAccurary:CLLocationAccuracy!
    
    public var gatherInterval:TimeInterval!     //定位信息的采集周期，单位秒，有效值范围[1, 60]
    public var pacKInterval:TimeInterval!       //定位信息的上传周期，单位秒
    
    
}
