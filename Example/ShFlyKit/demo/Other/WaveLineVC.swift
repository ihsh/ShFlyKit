//
//  WaveLineVC.swift
//  SHKit
//
//  Created by hsh on 2019/5/31.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class WaveLineVC: UIViewController {
    //Variable
    public var waver:AvRecordWave!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        waver = AvRecordWave()
        waver.frame = CGRect(x: 0, y: self.view.height/2 - 50, width: self.view.width, height: 100);
        self.view.addSubview(waver);
        waver.startMonitor();
    }

   

}
