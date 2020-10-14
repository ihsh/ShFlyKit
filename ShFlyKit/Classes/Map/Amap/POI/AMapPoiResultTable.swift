//
//  AMapPoiResultTable.swift
//  SHKit
//
//  Created by hsh on 2018/12/12.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapSearchKit

//位置选点中表格视图控件

protocol AMapPoiResultTableDelegate {
    //选择某个POI
    func didTableSelectedChanged(selectedPoi:AMapPOI)
    //点击加载更多
    func didLoadMoreBtnClick()
    //点击定位
    func didPositionUserLocation()
}


class AMapPoiResultTable: UIView,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate {
    //MARK
    public var delegate:AMapPoiResultTableDelegate!                 //搜索类的代理

    private var tableView:UITableView!
    private var moreBtn:UIButton!                                   //更多按钮
    
    private var currentAdress:String!                               //当前位置
    private var isFromMoreBtn:Bool = false                          //更多按钮的点击记录
    private var searchPoiArray = NSMutableArray()                   //搜索结果的视图
    private var selectedIndexPath:NSIndexPath!                      //选中的行
    
    
    // MARK: - Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.white;
        tableView = UITableView.initWith(UITableViewStyle.plain, dataSource: self, delegate: self, rowHeight: 50, separate: UITableViewCellSeparatorStyle.singleLine, superView: self);
        tableView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        //初始化footer
        self.initFooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Delegate
    //搜索的结果返回
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if self.isFromMoreBtn == true {
            self.isFromMoreBtn = false
        }else{
            self.searchPoiArray.removeAllObjects();
            self.moreBtn .setTitle("更多...", for: UIControlState.normal);
            self.moreBtn.isEnabled = true;
        }
        //不可点击
        if response.pois.count == 0 {
            self.moreBtn .setTitle("没有数据了...", for: UIControlState.normal);
            self.moreBtn.isEnabled = true;
        }
        searchPoiArray.addObjects(from:response.pois);
        self.tableView.reloadData()
    }
    
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if response.regeocode != nil {
            self.currentAdress = response.regeocode.formattedAddress;//反编译的结果
            
            let indexPath = NSIndexPath.init(row: 0, section: 0);
            self.tableView.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic);
        }
    }
    
    
    
    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath);
        cell?.accessoryType = .checkmark;
        self.selectedIndexPath = indexPath as NSIndexPath;
        //选中当前位置
        if (indexPath.section == 0) {
            self.delegate.didPositionUserLocation()
            return;
        }
        //选中其他结果
        let selectedPoi = self.searchPoiArray[indexPath.row] as? AMapPOI;
        if (self.delegate != nil&&selectedPoi != nil){
            delegate.didTableSelectedChanged(selectedPoi: selectedPoi!);
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath);
        cell?.accessoryType = .none;
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIndentifier = "reuseIndentifier";
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: reuseIndentifier);
        if  cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: reuseIndentifier)
        }
        if (indexPath.section == 0) {
            cell!.textLabel?.text = "[位置]";
            cell!.detailTextLabel?.text = self.currentAdress;
        }else{
            let poi:AMapPOI = self.searchPoiArray[indexPath.row] as! AMapPOI;
            cell!.textLabel?.text = poi.name;
            cell!.detailTextLabel?.text = poi.address;
        }
        if (self.selectedIndexPath != nil &&
            self.selectedIndexPath.section == indexPath.section &&
            self.selectedIndexPath.row == indexPath.row) {
            cell!.accessoryType = .checkmark;
        }else{
            cell!.accessoryType = .none;
        }
        return cell!;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
        }else{
            return self.searchPoiArray.count;
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    
    
    // MARK: - Private
    private func initFooter()->Void{
        let footer = SHBorderView.init(frame: CGRect(x: 0, y: 0, width: ScreenSize().width, height: 60));
        footer.borderStyle = 9;
        
        let btn = UIButton.initTitle("更多...", textColor: UIColor.black, back: UIColor.white, font: kFont(14), super: footer);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center;
        btn.addTarget(self, action: #selector(moreBtnClick), for: UIControlEvents.touchUpInside);
        moreBtn = btn;
        btn.mas_makeConstraints { (maker) in
            maker?.left.top()?.mas_equalTo()(footer)?.offset()(10);
            maker?.bottom.right()?.mas_equalTo()(footer)?.offset()(-10);
        }
        self.tableView.tableFooterView = footer;
    }
    
    
    
    @objc func moreBtnClick()->Void{
        if self.isFromMoreBtn {
            return;
        }
        if delegate != nil {
            delegate.didLoadMoreBtnClick()
        }
        self.isFromMoreBtn = true;
    }
    
}
