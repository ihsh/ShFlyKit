//
//  SystemInfoVC.swift
//  SHKit
//
//  Created by hsh on 2020/4/7.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit

class SystemInfoVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    
    private var tableV:UITableView!
    private var dataSource:[[String:String]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        let main:UIView = UIScreenFit.createMainView();
        self.view.addSubview(main);
        
        self.tableV = UITableView();
        main.addSubview(self.tableV);
        self.tableV.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(main);
        }
        self.tableV.delegate = self;
        self.tableV.dataSource = self;
        self.tableV.rowHeight = 44;
        self.tableV.register(ListCell.self, forCellReuseIdentifier: "cell");
        self.initDatas();
    }
    
    
    private func initDatas(){
        
        self.dataSource.append(["设备名":SystemInfo.deviceName()]);
        let info:[String:String] = SystemInfo.netDataCounters() as! [String : String];
        for (key,value) in info {
            self.dataSource.append([key:value]);
        }
        self.dataSource.append(["内存使用":String(format: "%.2f", SystemInfo.taskUsedMemory())]);
        self.dataSource.append(["总内存大小":String(format: "%.2f", SystemInfo.totalMemorySize())]);
        self.dataSource.append(["cpu使用率":String(format: "%.2f%%", SystemInfo.cpuUsedPersentage())]);
        self.dataSource.append(["电池电量":String(format: "%.2f%%", SystemInfo.getBatteryQuantity()*100.0)]);
        self.dataSource.append(["低电量模式":SystemInfo.lowPowerModeEnable() ? "打开" : "关闭"]);
        self.dataSource.append(["所在地语言":SystemInfo.localLanguage()]);
        self.dataSource.append(["系统语言":SystemInfo.systemLanguage()]);
        
        let disk:[String:String] = SystemInfo.diskInfo() as! [String : String];
        for (key,value) in disk {
            self.dataSource.append([key:value]);
        }
        let format = DateFormatter();
        format.dateFormat = "yyyy-MM-dd HH:mm:ss";
        self.dataSource.append(["系统启动时间":String(format: "%@", format.string(from: SystemInfo.systemStartTime()))]);
        self.dataSource.append(["运行时间":SystemInfo.runningTime()]);
        self.dataSource.append(["系统版本":SystemInfo.systemVersion()]);
        
        let net:[String:String] = SystemInfo.carrierInfo() as! [String : String];
        for (key,value) in net {
            self.dataSource.append([key:value]);
        }
        self.dataSource.append(["网络IP":SystemInfo.deviceIPAdress()]);
        self.dataSource.append(["移动网络地址":SystemInfo.deviceCellularIP()]);
        self.dataSource.append(["移动网络类型":SystemInfo.getNetType()]);
        self.dataSource.append(["网络延迟":String(format: "%.2fms", SystemInfo.pingSecForRemote())]);
        
//        self.dataSource.append(["电池状态":String(format: "%ld", SystemInfo.stateOfBattery())]);
        
        self.tableV.reloadData();
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = self.dataSource[indexPath.row];
        let cell:ListCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ListCell;
        cell.titleL.text = info.keys.first;
        cell.valueL.text = info.values.first;
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        return cell;
    }
   

}




class ListCell:UITableViewCell{
    public var titleL:UILabel!
    public var valueL:UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.initSubViews();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initSubViews(){
        self.titleL = UILabel.initText(nil, font: kFont(14), textColor: UIColor.colorHexValue("212121"), alignment: .center, super: self.contentView);
        self.titleL.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self.contentView);
            make?.left.mas_equalTo()(self.contentView)?.offset()(16);
        }
        self.valueL = UILabel.initText(nil, font: kFont(14), textColor: UIColor.colorHexValue("212121"), alignment: .right, super: self.contentView);
        self.valueL .mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self.contentView);
            make?.right.mas_equalTo()(self.contentView)?.offset()(-16);
        }
    }
    
    
}
