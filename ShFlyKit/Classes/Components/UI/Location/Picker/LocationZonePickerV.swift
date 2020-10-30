//
//  LocationZonePickerV.swift
//  SHKit
//
//  Created by hsh on 2019/8/19.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


//协议
public protocol LocationZonePickerDelegate:NSObjectProtocol {
    //完成选择地址
    func chooseAddress(result:AddressResult,type:AddressType)
    //没有数据重新请求
    func reCallDataSource(type:AddressType)
}


///选择地理区域的控件---PickerView样式
public class LocationZonePickerV: UIView , UIPickerViewDelegate , UIPickerViewDataSource{
    //Variable
    public weak var delegate:LocationZonePickerDelegate?
    //配置项
    public var onlyCity:Bool = false                                     //是否只展示省市
    public var pickerHeight:CGFloat = 220                                //总高度 + 44
    public var cancelColor = UIColor.colorHexValue("000000", alpha: 0.87)//取消的文字颜色
    public var compleColor = UIColor.colorHexValue("F16622", alpha: 1)   //完成的文字颜色
    public var barColor = UIColor.colorHexValue("F3F4F5")                //顶部栏的背景颜色
    public var pickBackColor = UIColor.white                             //选择视图的背景颜色
    //私有变量
    private var contentV:UIView!                                         //容器视图
    private var pickerView:UIPickerView!                                 //选择器
    private var pickerDataSource:AddressModel!                           //选择器数据源
    private var addressInfo:LocationAddress?                             //地理位置信息
    private var contactType:AddressType!                                 //地址类型
    private var components = LocMatchComponents()                        //选择的下标
    
    
    
    ///Interface
    //更新当前地址，直接展示当前地址
    public func updateAddress(_ address:LocationAddress){
        addressInfo = address;
    }
    
    
    //展示视图
    public func animateIn(view:UIView,type:AddressType){
        //已经加载
        if self.superview != nil {
            return;
        }
        contactType = type;
        pickerDataSource = (type == AddressType.Send ? LocDataSource.shared.sendAddress : LocDataSource.shared.receiveAddress);
        //没有数据，重新请求
        if pickerDataSource == nil || pickerDataSource.provinces.count == 0{
            delegate?.reCallDataSource(type: type);
            return;
        }
        //加载数据
        self.loadData();
        //坐标
        self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        self.contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: pickerHeight + 44);
        view.addSubview(self);
        UIView.animate(withDuration: 0.3) {
            self.contentV.frame = CGRect(x: 0, y: ScreenSize().height-self.pickerHeight-44-ScreenBottomInset(), width: ScreenSize().width, height: self.pickerHeight + 44);
        }
    }
    
    
    //移除视图
    @objc public func dismissFromSuper(){
        UIView.animate(withDuration: 0.3, animations: {
            self.contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: self.pickerHeight+44);
        }) { (finish) in
            self.removeFromSuperview();
        }
    }
    
    
    //加载数据
    private func loadData(){
        //找出对应索引
        if (addressInfo != nil && addressInfo!.city != nil){
            for index in 0...pickerDataSource.provinces.count - 1 {
                let province = pickerDataSource.provinces[index];
                //城市
                for cityIndex in 0...province.citys.count - 1 {
                    let city = province.citys[cityIndex];
                    if city.cityName.contains(addressInfo!.city){
                        components.provinceIndex = index;
                        components.cityIndex = cityIndex;
                        if (addressInfo!.coutry != nil){
                            for coutryIndex in 0...city.coutrys.count - 1{
                                let coutry = city.coutrys[coutryIndex];
                                if (coutry.coutryName.contains(addressInfo!.coutry!)){
                                    components.coutryIndex = coutryIndex;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        self.performSelector(onMainThread: #selector(updateUIOnMainThread), with: nil, waitUntilDone: false);
    }
    
    
    
    //更新下标显示
    @objc private func updateUIOnMainThread(){
        self.pickerView.reloadAllComponents();
        if (self.pickerDataSource.provinces.count != 0){
            self.pickerView.selectRow(components.provinceIndex, inComponent: 0, animated: true);
            self.pickerView.selectRow(components.cityIndex, inComponent: 1, animated: true);
            if onlyCity == false{
                self.pickerView.selectRow(components.coutryIndex, inComponent: 2, animated: true);
            }
        }
    }
    
    
    
    ///Delegate
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerDataSource.provinces.count > 0 {
            return onlyCity ? 2 : 3;
        }
        return 0
    }
    
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerDataSource.provinces.count;
        }else if component == 1{
            if components.provinceIndex < pickerDataSource.provinces.count {
                let province = pickerDataSource.provinces[components.provinceIndex];
                return province.citys.count;
            }
        }else if component == 2{
            if components.provinceIndex < pickerDataSource.provinces.count {
                let province = pickerDataSource.provinces[components.provinceIndex];
                if components.cityIndex < province.citys.count {
                    let city = province.citys[components.cityIndex];
                    return city.coutrys.count;
                }
            }
        }
        return 0
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickV:PickerV? = view as? LocationZonePickerV.PickerV;
        if pickV == nil {
            pickV = PickerV()
        }
        if component == 0 {
            if row < pickerDataSource.provinces.count{
                let province = pickerDataSource.provinces[row];
                pickV!.label.text = province.provinceName;
            }
        }else if component == 1{
            if components.provinceIndex < pickerDataSource.provinces.count {
                let province = pickerDataSource.provinces[components.provinceIndex];
                if row < province.citys.count {
                    let city = province.citys[row];
                    pickV!.label.text = city.cityName;
                }
            }
        }else if component == 2{
            if components.provinceIndex < pickerDataSource.provinces.count {
                let province = pickerDataSource.provinces[components.provinceIndex];
                if components.cityIndex < province.citys.count {
                    let city = province.citys[components.cityIndex];
                    if row < city.coutrys.count {
                        let coutry = city.coutrys[row];
                        pickV!.label.text = coutry.coutryName;
                    }
                }
            }
        }
        return pickV!;
    }

    
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            components.provinceIndex = row;
            components.cityIndex = 0;
            components.coutryIndex = 0;
        }else if component == 1 {
            components.cityIndex = row;
            components.coutryIndex = 0;
        }else if component == 2 {
            components.coutryIndex = row;
        }
        self.pickerView.reloadAllComponents()
    }
    

    //选择提交
    @objc private func commit(){
        //更新重新选择的结果
        if pickerDataSource.provinces.count == 0 {
            self.dismissFromSuper();
            return;
        }
        //结果
        let result = AddressResult()
        
        let province = pickerDataSource.provinces[components.provinceIndex];
        result.province = province.provinceName;
        result.provinceCode = province.provinceCode;
        
        let city = province.citys[components.cityIndex];
        result.city = city.cityName;
        result.cityCode = city.cityCode;
        
        if city.coutrys.count > 0 {
            let coutry = city.coutrys[components.coutryIndex];
            result.coutry = coutry.coutryName;
            result.coutryCode = coutry.coutryCode;
        }
        result.fullZone = String(format: "%@%@%@", result.province,result.city,result.coutry ?? "")
        result.isMatch = true;
        //传值退出
        delegate?.chooseAddress(result: result, type: contactType);
        self.dismissFromSuper()
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.clear;
        contentV = UIView()
        contentV.backgroundColor = UIColor.white;
        self.addSubview(contentV);
        //顶部条
        let grayV = UIView()
        grayV.backgroundColor = barColor;
        grayV.layer.shadowColor = UIColor.colorHexValue("000000", alpha: 0.1).cgColor;
        grayV.layer.shadowOffset = CGSize(width: 0, height: -1);
        grayV.layer.shadowOpacity = 0.5;
        grayV.layer.shadowRadius = 1;
        contentV.addSubview(grayV);
        let canBtn = UIButton.initTitle("取消", textColor: cancelColor, back: UIColor.clear, font: kFont(14), super: grayV);
        canBtn.addTarget(self, action: #selector(dismissFromSuper), for: .touchUpInside);
        canBtn.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(grayV)?.offset()(16);
            maker?.centerY.mas_equalTo()(grayV);
            maker?.top.bottom()?.mas_equalTo()(grayV);
        }
        let commitBtn = UIButton.initTitle("完成", textColor: compleColor, back: UIColor.clear, font: kFont(14), super: grayV);
        commitBtn.addTarget(self, action: #selector(commit), for: .touchUpInside);
        commitBtn.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(grayV)?.offset()(-16);
            maker?.centerY.mas_equalTo()(grayV);
            maker?.top.bottom()?.mas_equalTo()(grayV);
        }
        grayV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(contentV);
            maker?.height.mas_equalTo()(44);
        }
        //选择视图
        pickerView = UIPickerView()
        pickerView.backgroundColor = pickBackColor;
        pickerView.showsSelectionIndicator = true;
        contentV.addSubview(pickerView);
        pickerView.mas_makeConstraints { (maker) in
            maker?.left.bottom()?.right()?.mas_equalTo()(contentV);
            maker?.top.mas_equalTo()(grayV.mas_bottom);
        }
        pickerView.delegate = self;
        pickerView.dataSource = self;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //自定义的Picker-View
    public class PickerV: UIView {
        public static var font:UIFont = kFont(16)
        public var label:UILabel!
        
        override init(frame: CGRect) {
            super.init(frame: frame);
            self.backgroundColor = UIColor.white;
            label = UILabel.initText(nil, font: LocationZonePickerV.PickerV.font, textColor: UIColor.black, alignment: .center, super: self);
            label.adjustsFontSizeToFitWidth = true;
            label.mas_makeConstraints { (maker) in
                maker?.top.right()?.bottom()?.left()?.mas_equalTo()(self);
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
}



