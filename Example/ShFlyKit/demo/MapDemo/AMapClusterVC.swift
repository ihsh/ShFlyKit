//
//  AMapClusterVC.swift
//  SHKit
//
//  Created by hsh on 2019/1/16.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapSearchKit
import Masonry

class AMapClusterVC: UIViewController,AMapSearchDelegate{
    //mark
    private var clusterManager:AMapClusterService!      //点聚合管理
    private var search = AMapSearchAPI()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //点聚合控制器
        clusterManager = AMapClusterService()
        self.view.addSubview(clusterManager);
        clusterManager.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        //设置地图样式
        AMapUIServise.showUserLocation(show: true);
        AMapUIServise.setCustomMapStyle(pathStr: "style.data", styleID: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = "餐饮";
        request.city = "深圳";
        search?.aMapPOIKeywordsSearch(request);
        search?.delegate = self;
    }
    

    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count == 0 {
            return;
        }
        //转换成需要的模型
        let array:[AMapClusterModel] = AMapClusterModel.convertAMapPoi(toCustomModel: response.pois) as! [AMapClusterModel];
        //设置数据
        clusterManager.buildClusterTree(array);
    }


}
