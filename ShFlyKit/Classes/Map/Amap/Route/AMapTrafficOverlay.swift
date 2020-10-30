//
//  SelectableTrafficOverlay.swift
//  SHKit
//
//  Created by hsh on 2018/12/17.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///带交通状况的overlay图层类
public class AMapTrafficOverlay: MAMultiPolyline {

    public var routeID:NSInteger!                   //对应的RouteID
    public var selected:Bool = false                //是否选中
    public var polylineWidth:CGFloat!               //路径宽度
     
    public var polylineStrokeColors:[UIColor]!      //颜色数组
    public var polylineTextureImages:[UIImage]!     //纹理数组
    
}
