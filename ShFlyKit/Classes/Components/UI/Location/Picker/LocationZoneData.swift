//
//  LocationZoneData.swift
//  SHKit
//
//  Created by hsh on 2019/9/20.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


//地址类型
enum AddressType{
    case Send,Receive                       //寄件，收件
}


//查询的地址结果
class AddressResult: NSObject {
    public var province:String!             //省名称
    public var provinceCode:Int = 0         //省编码
    public var city:String!                 //城市
    public var cityCode:Int = 0             //城市编码
    public var coutry:String?               //区/县/市/街道等
    public var coutryCode:Int = 0           //第三级编码
    public var town:String?                 //乡镇
    public var townCode:Int = 0             //乡镇编码
    public var fullZone:String!             //查询的完整地址
    public var isMatch:Bool = false         //是否匹配
}



//数据保存
class LocDataSource: NSObject {
    //variable
    static let shared = LocDataSource.init()               //单例保存数据
    public var sendAddress:AddressModel!                   //寄件地址
    public var receiveAddress:AddressModel!                //收件地址

    //外界查询使用
    public func queryAddress(city:String,district:String?,type:AddressType)->AddressResult{
           let result = AddressResult()
           let address = (type == AddressType.Send ? LocDataSource.shared.sendAddress : LocDataSource.shared.receiveAddress);
           if address != nil {
               for province in address!.provinces {
                   for ci in province.citys{
                       var match = false;
                       if (ci.cityName == city){
                           match = true;
                       }else if (city.contains("市")==false && (ci.cityName.contains(city))){
                           match = true;
                       }
                       //找到了这个城市
                       if (match == true){
                           result.province = province.provinceName;
                           result.provinceCode = province.provinceCode;
                           result.city = ci.cityName;
                           result.cityCode = ci.cityCode;
                           let tmpStr = NSMutableString()
                           tmpStr.append(province.provinceName);
                           tmpStr.append(ci.cityName);
                           //找到区
                           if (district != nil && district!.count > 0){
                               for coutry in ci.coutrys{
                                   if coutry.coutryName == district{
                                       result.coutry = coutry.coutryName;
                                       result.coutryCode = coutry.coutryCode;
                                       tmpStr.append(coutry.coutryName);
                                       break;
                                   }
                               }
                           }
                           //判断是否匹配
                           if (district != nil && district!.count > 0){
                               if (ci.coutrys.count == 0 || result.coutryCode == 0){//传入有第三级，本地找不到第三级
                                   result.isMatch = false;
                               }else{
                                   result.isMatch = true;
                               }
                           }else{
                               if (ci.coutrys.count == 0){
                                   result.isMatch = true;
                               }else{
                                   result.isMatch = false;
                               }
                           }
                           result.fullZone = tmpStr as String;
                       }
                   }
               }
           }
           return result;
       }
    
}



//地理位置模型
class AddressModel: NSObject {
    //Variable
    public var provinces:[ProvinceModel] = []
    
    
    //初始化数据
    class func initWithDict(_ dict:NSDictionary)->AddressModel{
        let address = AddressModel()
        //全部省份
        let province:NSArray? = dict.value(forKey: "provinces") as? NSArray;
        //省是数组，第二级和之后是字典
        if province != nil {
            for i in 0...province!.count-1 {
                let obj:NSDictionary? = province![i] as? NSDictionary;
                if obj != nil{
                    let name:NSString = obj?.value(forKey: "name") as? NSString ?? "";
                    let code:NSNumber = obj?.value(forKey: "code") as! NSNumber ;
                    let model = ProvinceModel()
                    model.provinceName = name as String;
                    model.provinceCode = code.intValue;
                    address.provinces.append(model);
                }
            }
        }
        //城市
        let citys:NSDictionary? = dict.value(forKey: "cities") as? NSDictionary;
        if citys != nil {
            //一个key对应一个省份
            for ci in citys!.allKeys{
                let key:NSString = ci as! NSString;
                for model in address.provinces{
                    if model.provinceCode == key.integerValue {
                        let array:NSArray? = citys?.value(forKey: key as String) as? NSArray;
                        if array != nil {
                            for index in 0...array!.count - 1 {
                                let obj:NSDictionary = array![index] as! NSDictionary;
                                let name:NSString = obj.value(forKey: "name") as? NSString ?? "";
                                let code:NSNumber = obj.value(forKey: "code") as! NSNumber ;
                                let cityModel = CityModel()
                                cityModel.parentID = model.provinceCode;
                                cityModel.cityName = name as String;
                                cityModel.cityCode = code.intValue;
                                model.citys.append(cityModel);
                            }
                        }
                        break;
                    }
                }
            }
        }
        //第三级
        let areas:NSDictionary? = dict.value(forKey: "areas") as? NSDictionary;
        if areas != nil {
            for tmp in areas!.allKeys{
                let key:NSString = tmp as! NSString;
                for province in address.provinces {
                    for city in province.citys {
                        if city.cityCode == key.integerValue {
                            let array:NSArray? = areas?.value(forKey: key as String) as? NSArray;
                            if array != nil {
                                for index in 0...array!.count - 1 {
                                    let obj:NSDictionary = array![index] as! NSDictionary;
                                    let name:NSString = obj.value(forKey: "name") as? NSString ?? "";
                                    let code:NSNumber = obj.value(forKey: "code") as! NSNumber ;
                                    let coutryItem = CoutryModel()
                                    coutryItem.coutryCode = code.intValue;
                                    coutryItem.coutryName = name as String;
                                    city.coutrys.append(coutryItem);
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        //第四级
        let towns:NSDictionary? = dict.value(forKey: "towns") as? NSDictionary;
        if towns != nil {
            for tmp in towns!.allKeys{
                let key:NSString = tmp as! NSString;
                for province in address.provinces {
                    for city in province.citys {
                        for coutry in city.coutrys {
                            if coutry.coutryCode == key.integerValue {
                                let array:NSArray? = towns?.value(forKey: key as String) as? NSArray;
                                if array != nil {
                                    for index in 0...array!.count - 1 {
                                        let obj:NSDictionary = array![index] as! NSDictionary;
                                        let name:NSString = obj.value(forKey: "name") as? NSString ?? "";
                                        let code:NSNumber = obj.value(forKey: "code") as! NSNumber ;
                                        let town = TownModel()
                                        town.townCode = code.intValue;
                                        town.townName = name as String;
                                        coutry.towns.append(town);
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
        return address;
    }
    
}



//省
class ProvinceModel: NSObject {
    public var provinceName:String!
    public var provinceCode:Int = 0
    public var citys:[CityModel] = []
}


//市
class CityModel: NSObject {
    public var cityName:String!
    public var cityCode:Int = 0
    public var parentID:Int = 0
    public var coutrys:[CoutryModel] = []
}


//区/县
class CoutryModel: NSObject {
    public var coutryName:String!
    public var coutryCode:Int = 0
    public var towns:[TownModel] = []
}


//乡镇
class TownModel:NSObject{
    public var townName:String!
    public var townCode:Int = 0
}


//定位信息
class LocationAddress:NSObject{
    public var city:String!         //定位的城市名-可能没有-市
    public var coutry:String?       //区/县名称-可能是-县级市-例茂名市-化州市
}


//用于匹配数据
class LocMatchComponents:NSObject{
    public var current:Int = 0                 //当前选择的级别
    public var provinceIndex:Int = 0           //省选择的下标
    public var cityIndex:Int = 0               //城市选择的下标
    public var coutryIndex:Int = 0             //区/县选择的下标
    public var townIndex:Int = 0               //乡镇选择的下标
}
