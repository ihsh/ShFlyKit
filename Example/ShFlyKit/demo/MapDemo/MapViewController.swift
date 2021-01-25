//
//  MapViewController.swift
//  SHKit
//
//  Created by hsh on 2019/1/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class MapViewController: UITableViewController {
    
//     let actionArr:NSArray = ["百度点聚合","百度调用客户端","百度路线规划","百度地图轨迹",
//                              "高德位置选点","高德路线规划","高德地图轨迹","高德小车动画","高德点聚合"]
    let actionArr:NSArray = ["高德位置选点","高德路线规划","高德地图轨迹","高德小车动画","高德点聚合"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "地图";
        self.tableView.reloadData();
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let str = actionArr[indexPath.row];
        cell.textLabel?.text = str as? String;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str:String = actionArr[indexPath.row] as! String;
        if str == "高德位置选点" {
            let trackVC = AmapPoiSelectVC()
            trackVC.tableHeight = ScreenSize().height/5*2
            self.navigationController?.pushViewController(trackVC, animated: true);
        }else if str == "高德路线规划" {
            let baseVC = MultiRoutePlanVC()
            self.navigationController?.pushViewController(baseVC, animated: true);
        }else if str == "高德小车动画" {
            let playVC = AMapTrackPlayVC()
            self.navigationController?.pushViewController(playVC, animated: true);
        }else if str == "高德点聚合" {
            let vc = AMapClusterVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if str == "高德地图轨迹" {
            let vc = AMapTrackVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if str == "百度路线规划" {
//            let vc = BaiduMaoVC()
//            self.navigationController?.pushViewController(vc, animated: true);
        }else if str == "百度调用客户端" {
            let startPoint = CLLocationCoordinate2D(latitude: 22.572025, longitude: 114.116530)
            let endPoint = CLLocationCoordinate2D(latitude: 22.550398, longitude: 113.932844)
//            BaiduService .routePlan(start: startPoint, end: endPoint, appscheme: "SHKit", type: RouteType.Walk);
//            BMKService.routePlan(start: startPoint, end: endPoint, appscheme: "SHKit", type: RouteType.Drive)
        }else if str == "百度点聚合" {
//            let vc = BMKClusterVC()
//            self.navigationController?.pushViewController(vc, animated: true);
        }else if str == "百度地图轨迹" {
//            let vc = BMKTrackPlayVC()
//            self.navigationController?.pushViewController(vc, animated: true);
        }
        
    }

}
