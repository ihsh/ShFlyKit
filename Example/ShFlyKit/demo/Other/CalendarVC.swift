//
//  CalendarVC.swift
//  SHKit
//
//  Created by hsh on 2019/9/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        CalendarDataSource.restDays = ["2020":["10-1":true,"10-2":true,"10-3":true,"10-4":true,"10-5":true,"10-6":true,"10-7":true,"10-8":true]]
        let view = CalenDarV()
        self.view.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(self.view)?.offset()(100);
            maker?.height.mas_equalTo()(400);
        }
        view.calendar.initData(date: Date());
        view.calendar.config.selectStyle = .SquarePath;
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    



}
