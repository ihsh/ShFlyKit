//
//  BMKTrackPlayVC.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

//class BMKTrackPlayVC: UIViewController {
//
//    public var trackView:BMKTrackPlayView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.view.backgroundColor = UIColor.white;
//        trackView = BMKTrackPlayView()
//        self.view.addSubview(trackView);
//        trackView.mas_makeConstraints { (maker) in
//            maker?.top.mas_equalTo()(self.view)?.offset()(100);
//            maker?.bottom.mas_equalTo()(self.view)?.offset()(-100);
//            maker?.left.mas_equalTo()(self.view)?.offset()(30);
//            maker?.right.mas_equalTo()(self.view)?.offset()(-30);
//        }
//    }
//    
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated);
//        let tmpArray = NSMutableArray()
//        //运动数据
//        let jsonPath = Bundle.main.path(forResource: "running_record", ofType: "json");
//        if let jsonData:NSData = NSData.init(contentsOfFile: jsonPath ?? ""){
//            let json = try? JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments);
//            let dataArray:NSArray = json as! NSArray;
//            for (_,value) in dataArray.enumerated(){
//                let dict:NSDictionary = value as! NSDictionary;
//                let latitude:NSString = dict.value(forKey: "latitude") as! NSString;
//                let logitude:NSString = dict.value(forKey: "longtitude") as! NSString;
//                let speed:NSString = dict.value(forKey: "speed") as! NSString;
//                let common = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: logitude.doubleValue);
//                let model = BMKTrackModel()
//                model.coodinate = BMKCoordTrans(common, BMK_COORD_TYPE.COORDTYPE_COMMON, BMK_COORD_TYPE.COORDTYPE_BD09LL);
//                model.speed = speed.doubleValue;
//                tmpArray.add(model)
//            }
//        }
//        
//        //显示
//        trackView.showData(data: tmpArray as! [BMKTrackModel]);
//    }
//
//    
//
//    
//
//}