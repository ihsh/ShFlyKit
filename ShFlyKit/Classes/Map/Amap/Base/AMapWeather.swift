//
//  AMapWeather.swift
//  SHKit
//
//  Created by hsh on 2019/1/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapSearchKit


///搜索天气代理
@objc public protocol AMapWeatherDelegate : NSObjectProtocol {
    //返回实时天气数组
    func weatherSearchDone(_ llives:[AMapLocalWeatherLive])
    //搜索失败
    @objc optional func weatherSearchFailed()
}


///搜索天气类
public class AMapWeather: NSObject,AMapSearchDelegate {
    ///MARK
    private var searchApi = AMapSearchAPI()
    public weak var delegate:AMapWeatherDelegate?
    
    
    ///Load
    override init() {
        super.init();
        searchApi?.delegate = self;
    }
    
    
    ///MARK-Interface
    //搜索对应城市的天气状况
    public func searchWeatherForCity(_ name:String)->Void{
        let request = AMapWeatherSearchRequest()
        request.city = name;   //名称
        //实时的天气
        request.type = AMapWeatherType.live;
        self.searchApi?.aMapWeatherSearch(request);
    }
    
    
    //天气结果回调成功
    func onWeatherSearchDone(_ request: AMapWeatherSearchRequest!, response: AMapWeatherSearchResponse!) {
        let array = response.lives;
        var result:[AMapLocalWeatherLive] = [];
        if array != nil {
            if (array?.count)! > 0 {
                for live in array!{
                    result.append(live);
                }
            }
        }
        delegate?.weatherSearchDone(result);
    }
    
    
    //天气搜索失败
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        delegate?.weatherSearchFailed!();
        print("天气搜索失败");
    }
    
    
}
