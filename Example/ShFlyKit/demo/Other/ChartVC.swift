//
//  ChartVC.swift
//  SHKit
//
//  Created by hsh on 2019/10/8.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class ChartVC: UITableViewController {
    let actionArr:NSArray = ["pieChart","雷达图","折线图","饼图"]
    
    
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
            let pie = PieChartTwo()
            var components:[PieComponent] = [];
            for index in 0...8 {
                let pie = PieComponent.initValue(CGFloat(2+index), color: UIColor.randomColor(), content: "一二三四", textColor: UIColor.randomColor());
                components.append(pie);
            }
            pie.showChart(components);
            pie.frame = CGRect(x: 10, y: 00, width: 350, height: 350);
            
            let vc = TransVC();
            vc.showView = pie;
            vc.showRect = CGRect(x: 0, y: 100, width: 350, height: 350);
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
        }else if str == "折线图"{
            let view = LineChartScrollV()
            view.backgroundColor = UIColor.white;
            let vc = TransVC();
            vc.backColor = UIColor.white
            vc.showView = view;
            self.navigationController?.pushViewController(vc, animated: true);
            let data:LineChartData = LineChartData();
            data.minXspan = 20;
            data.xAxisValueHorizon = false;
            data.addOriginData([(30,"一月"),(20,"二月"),(50,"三月"),(45,"四月"),(70,"五月"),(60,"六月"),
                                (90,"七月"),(95,"八月"),(100,"十月"),(130,"十一月"),(120,"十二月"),(100,"十三"),(30,"十四"),(80,"十五"),(70,"十六"),(100,"十月"),(130,"十一月"),(120,"十二月"),(100,"十三"),(30,"十四"),(80,"十五"),(70,"十六"),(100,"十月"),(130,"十一月"),(120,"十二月"),(100,"十三"),(30,"十四"),(80,"十五"),(70,"十六"),(100,"十月"),(130,"十一月"),(120,"十二月"),(100,"十三"),(30,"十四"),(80,"十五"),(70,"十六")])
            let color = data.lineColor;
            data.shadowColor = [color.withAlphaComponent(0.9).cgColor,color.withAlphaComponent(0.7).cgColor,
                                color.withAlphaComponent(0.5).cgColor,UIColor.randomColor().withAlphaComponent(0.3).cgColor,
                                UIColor.randomColor().withAlphaComponent(0.3).cgColor,
                                color.withAlphaComponent(0.02).cgColor]
            view.showData(data);
        }else if str == "饼图"{
            let view = PieChartView()
            view.backgroundColor = UIColor.white;
            let vc = TransVC();
            vc.backColor = UIColor.white
            vc.showView = view;
            self.navigationController?.pushViewController(vc, animated: true);
            
            let data = PieData();
            data.sliceEnable = false;
            let entry1 = PieData.Entry.inits(value: 100,desc: "语文");
            let entry2 = PieData.Entry.inits(value: 30,desc: "体育");
            let entry3 = PieData.Entry.inits(value: 130,desc: "数学");
            let entry4 = PieData.Entry.inits(value: 40,desc: "美术");
            let entry5 = PieData.Entry.inits(value: 50,desc: "其他");
            data.dataSet.append(contentsOf: [entry1,entry2,entry3,entry4,entry5]);
            view .showPie(data);
        }
        
    }

    
}
