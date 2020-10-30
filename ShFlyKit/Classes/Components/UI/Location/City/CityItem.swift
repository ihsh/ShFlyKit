//
//  CityItem.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import YYModel


//城市数据-swif写法
@objc public class CityItem:NSObject , NSCoding , YYModel{
    @objc public var city_id:String!          //城市ID
    @objc public var name:String!             //城市名
    @objc public var name_en:String?          //城市拼音
    @objc public var lat_lon:LatLon?          //经纬度
    @objc public var business:AnyObject?      //业务配置信息
    
    @objc public class LatLon: NSObject {
        @objc public var lat:String!
        @objc public var lon:String!
    }
    
    override init() {
        super.init();
    }
    
    public func encode(with coder: NSCoder) {
        self.yy_modelEncode(with: coder);
    }
    
    required public init?(coder: NSCoder) {
        super.init()
        self.yy_modelInit(with: coder);
    }
        
}
