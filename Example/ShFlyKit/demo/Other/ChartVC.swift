//
//  ChartVC.swift
//  SHKit
//
//  Created by hsh on 2019/10/8.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class ChartVC: UITableViewController {
    let actionArr:NSArray = ["pieChart","雷达图"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
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
        if str == "pieChart" {
            let pie = PieChartShowView()
            var components:[PieComponent] = [];
            for index in 0...8 {
                let pie = PieComponent.initValue(CGFloat(2+index), color: UIColor.randomColor(), content: "一二三四", textColor: UIColor.randomColor());
                components.append(pie);
            }
            pie.showChart(components);
            pie.frame = CGRect(x: 00, y: 00, width: 400, height: 400);
            
            let zoomV = ChartZoomView();
            zoomV.setZoomView(pie);
            
            let vc = TransVC();
            vc.showView = zoomV;
            vc.showRect = CGRect(x: 0, y: 100, width: 400, height: 400);
            self.navigationController?.pushViewController(vc, animated: true);
        }else if str == "雷达图"{
            let view = RadarChartView()
            view.showSize = CGSize(width: 300, height: 300);
            
            let vc = TransVC();
            vc.showView = view;
            vc.showRect = CGRect(x: 30, y: 100, width: 300, height: 300);
            self.navigationController?.pushViewController(vc, animated: true);
            
            
            let data = RadarShowData();
            data.valueDivider = 40;
            let item1 = RadarShowData.RadarDataItem.initItem(127, desc: "语文");
            let item2 = RadarShowData.RadarDataItem.initItem(147, desc: "数学");
            let item3 = RadarShowData.RadarDataItem.initItem(143, desc: "英语");
            let item4 = RadarShowData.RadarDataItem.initItem(98, desc: "历史");
            let item5 = RadarShowData.RadarDataItem.initItem(90, desc: "政治");
            let item6 = RadarShowData.RadarDataItem.initItem(92, desc: "地理");
            let item7 = RadarShowData.RadarDataItem.initItem(88, desc: "生物");
            let item8 = RadarShowData.RadarDataItem.initItem(80, desc: "化学");
            let item9 = RadarShowData.RadarDataItem.initItem(85, desc: "物理");
            data.appendArray([item1,item2,item3,item4,item5,item6,item7,item8,item9]);
            view.drawData(data);
        }
        
    }

    
}
