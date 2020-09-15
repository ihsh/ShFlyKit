//
//  BMKClusterObject.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

///点聚合annotation类
class BMKClusterAnno: NSObject,BMKAnnotation {
    ///MARK
    @objc public var coordinate = CLLocationCoordinate2D()  //对应坐标点
    @objc public var count:NSInteger = 0                    //对应点数
    @objc public var pois:NSMutableArray!                   //对应位置数组 [BMKClusterModel]
    
    ///MARK-Load
    @objc init(coordinate:CLLocationCoordinate2D,count:NSInteger) {
        super.init();
        self.coordinate = coordinate;
        self.count = count;
        self.pois = NSMutableArray()
    }
    
    //是否相等
    override func isEqual(_ object: Any?) -> Bool {
        if let com:BMKClusterAnno = object as? BMKClusterAnno {
            return hash(anno: self) == hash(anno: com);
        }else{
            return false;
        }
    }
    
    //自定义HASH规则
    @objc public func hash(anno:BMKClusterAnno)->Int{
        let tohash = NSString(format: "%.5f%.5f%ld", anno.coordinate.latitude,anno.coordinate.longitude,anno.count);
        return tohash.hash
    }
}




///点集合数据模型
class BMKClusterModel:NSObject{
    ///MARK
    @objc public var uid:String!      //编号
    @objc public var name:String!     //名称
    @objc public var address:String!  //地址
    @objc public var tel:String!      //电话号码
    @objc public var location = CLLocationCoordinate2D() //地理位置
    @objc public var email:String!    //电子邮件
    @objc public var website:String!  //网站
    @objc public var province:String! //省
    @objc public var pcode:String!    //省code
    @objc public var city:String!     //城市
    @objc public var cityCode:String! //城市编码
    @objc public var district:String! //区域名称
    @objc public var adcode:String!   //区域编码
    @objc public var images:[UIImage]!//图片数组  -->优先
    @objc public var imageUlrs:[String]!//图片地址
    
    
}
