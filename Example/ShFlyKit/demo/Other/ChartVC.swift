//
//  ChartVC.swift
//  SHKit
//
//  Created by hsh on 2019/10/8.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class ChartVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        let pie = PieChartShowView()
        self.view.addSubview(pie);
        pie.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(self.view)?.offset()(100);
            maker?.centerX.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(300);
            maker?.left.right()?.mas_equalTo()(self.view);
        }
        var components:[PieComponent] = [];
        for index in 0...8 {
            let pie = PieComponent.initValue(CGFloat(2+index), color: UIColor.randomColor(), content: "一二三四", textColor: UIColor.randomColor());
            components.append(pie);
        }
        pie.showChart(components);
    }
    
    
}
