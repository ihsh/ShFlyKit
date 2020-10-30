//
//  BMKClusterVC.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapSearchKit

//class BMKClusterVC: UIViewController,AMapSearchDelegate {
//
//    public var clusterManager:BMKClusterService!
//    private var search = AMapSearchAPI()
//    public var locationManager:BMKLocationService!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        clusterManager = BMKClusterService()
//        self.view.addSubview(clusterManager);
//        clusterManager.mas_makeConstraints { (maker) in
//            maker?.left.top()?.bottom()?.right()?.mas_equalTo()(self.view);
//        }
//        //定位管理
//        locationManager = BMKLocationService()
//        locationManager.setAdaptMap(clusterManager.mapView);
//    }
//
//
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated);
//        let request = AMapPOIKeywordsSearchRequest()
//        request.keywords = "餐饮";
//        request.city = "深圳";
//        search?.aMapPOIKeywordsSearch(request);
//        search?.delegate = self;
//        locationManager.startLocation()
//        locationManager.startUpdatingLocation(true);
//    }
//
//
//    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
//        if response.pois.count == 0 {
//            return;
//        }
//        //转换模型
//        var array:[BMKClusterModel] = [];
//        for poi in response.pois {
//            let model = BMKClusterModel()
//            model.uid = poi.uid;
//            model.name = poi.name;
//            model.address = poi.address;
//            model.tel = poi.tel;
//            model.location = CLLocationCoordinate2D(latitude: CLLocationDegrees(poi.location?.latitude ?? 0),
//                                                    longitude: CLLocationDegrees(poi.location?.longitude ?? 0));
//            model.email = poi.email;
//            model.website = poi.website;
//            model.province = poi.province;
//            model.pcode = poi.pcode;
//            model.city = poi.city;
//            model.cityCode = poi.citycode;
//            model.district = poi.district;
//            model.adcode = poi.adcode;
//            array.append(model);
//        }
//        //设置数据
//        clusterManager.buildClusterTree(array);
//    }
//
//}
