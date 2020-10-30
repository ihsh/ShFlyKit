//
//  LocationPickerVC.swift
//  SHKit
//
//  Created by hsh on 2019/8/20.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class LocationPickerVC: UIViewController ,LocationZoneTableDelegate , LocationZonePickerDelegate , CityListDelegate{
    //variable
    private var label:UILabel!
    private var locationV:LocationZoneTableV!
    private var pickV:LocationZonePickerV!
    private var  vc = CityListVC()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
//        NetManager.shareInstance.request(BaseRequest.initWithMethod(method: .GET, key: nil, pairClass: nil, url: "http://ltl-stg.huolala.cn/line/recipient?_su=19082010564319720000000741898668&_t=1566269803&area_code=440304&os=ios&revision=6200&token=userf0cc386666ed4d3efb2dd41cc994&user_md5=5f2f7afbe3961eb80161eead296aa7c1&version=6.2.0", block: { (ret, msg, data) in
//            if ret == 0{
//                let address = AddressModel.initWithDict(data);
//                SHPersister.shareInstance.saveData(objs: [data], identifier: "location");
//                LocationZonePickerV.shared.receiveAddress = address;
//            }
//        }))
        
//        NetManager.shareInstance.request(BaseRequest.initWithMethod(method: .GET, match: BaseMatch.inits(keys: ["city_item","hot_city"], pairClasses: [CityItem.self]), url: "https://uapi-stg.huolala.cn/?_m=city_list&_su=19092417444137620000004190600705&_t=1569318281&args=%7B%7D&device_id=3EF7D69F5F6B44A4946403E9025246CA&device_type=iPhone%206&os=ios&revision=6400&version=6.4.0", block: { (ret, msg, data) in
//            if ret == 0 {
//                let citylist:[CityItem] = data.value(forKey: "city_item") as! [CityItem];
//                let hot:[CityItem] = data.value(forKey: "hot_city") as! [CityItem];
//                SHPersister.shareInstance.saveData(objs: citylist, identifier: "city",clear: true);
//                SHPersister.shareInstance.saveData(objs: hot, identifier: "hot",clear: true);
//            }
//
//        }))
        
        let data:[NSDictionary] = SHPersister.shareInstance.queryForClass(NSDictionary.self, clear: false, identifier: "location") as! [NSDictionary];
        let address = AddressModel.initWithDict(data.first ?? NSDictionary());
        locationV = LocationZoneTableV()
        locationV.delegate = self;
        locationV.completeCheck = true;
        LocDataSource.shared.receiveAddress = address;
        
        pickV = LocationZonePickerV()
        pickV.delegate = self;
        
        
        let btn = UIButton.initTitle("picker", textColor: UIColor.colorHexValue("4A4A4A"), back: UIColor.randomColor(), font: kFont(16), super: self.view);
        btn.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(self.view);
            maker?.centerY.mas_equalTo()(self.view)?.offset()(100);
            maker?.width.mas_equalTo()(100);
            maker?.height.mas_equalTo()(80);
        }
        btn.addTarget(self, action: #selector(showView(_:)), for: .touchUpInside);
        
        let btn1 = UIButton.initTitle("列表", textColor: UIColor.colorHexValue("4A4A4A"), back: UIColor.randomColor(), font: kFont(16), super: self.view);
        btn1.tag = 1;
        btn1.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(btn);
            maker?.top.mas_equalTo()(btn.mas_bottom)?.offset()(10);
            maker?.width.height()?.mas_equalTo()(btn);
        }
        btn1.addTarget(self, action: #selector(showView(_:)), for: .touchUpInside);
        
        let btn2 = UIButton.initTitle("城市列表", textColor: UIColor.colorHexValue("4A4A4A"), back: UIColor.randomColor(), font: kFont(16), super: self.view);
        btn2.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(btn);
            maker?.top.mas_equalTo()(btn1.mas_bottom)?.offset()(10);
            maker?.width.height()?.mas_equalTo()(btn);
        }
        btn2.addTarget(self, action: #selector(showCitys), for: .touchUpInside);
        
        
        
        label = UILabel.initText(nil, font: kFont(16), textColor: UIColor.colorHexValue("4A4A4A"), alignment: .center, super: self.view);
        label.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(btn.mas_top)?.offset()(-50);
            maker?.centerX.mas_equalTo()(btn);
        }
        
    }
    
    
    func selectAddress(result: AddressResult, type: AddressType) {
        label.text = result.fullZone;
    }
    
    
    func chooseAddress(result: AddressResult, type: AddressType) {
        label.text = result.fullZone;
    }
    
    
    @objc private func showView(_ sender:UIButton){
        if sender.tag == 1 {
            locationV.animateIn(view: (UIApplication.shared.delegate?.window!)!, type: .Receive);
        }else{
            pickV.animateIn(view: (UIApplication.shared.delegate?.window!)!, type: .Receive);
        }
        
    }
    
    
    @objc private func showCitys(){
        vc = CityListVC()
        vc.delegate = self;
        let citylist:[CityItem] = SHPersister.shareInstance.queryForClass(CityItem.self, clear: false, identifier: "city") as! [CityItem];
        let hot:[CityItem] = SHPersister.shareInstance.queryForClass(CityItem.self, clear: false, identifier: "hot") as! [CityItem];
        vc.allCitys = citylist;
        vc.hotCitys = hot;
        vc.recents = hot;
        self.navigationController?.pushViewController(vc, animated: true);
    }

    
    func reCallDataSource(type: AddressType) {
        
    }
  
    
    func chooseCity(_ city: CityItem) {
        print(city.name);
    }
    
    
    func callUserLocation() {
        vc.headV.updateCurrent("深圳");
    }

    
}
