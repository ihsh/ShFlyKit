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
