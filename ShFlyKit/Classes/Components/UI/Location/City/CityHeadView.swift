//
//  CityHeadView.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit



protocol CityHeadViewDelegate :NSObjectProtocol {
    //选择城市
    func selectCity(_ city:CityItem)
    //调用定位
    func callUserLocation()
    //禁止滑动
    func tableViewScrollEnable(_ enable:Bool)
}


///城市列表头部的热门和搜索
class CityHeadView: UIView , ItemsViewDelegate , DelayTextFieldDelegate{
    //Variable
    public weak var delegate:CityHeadViewDelegate?
    public var allHeight:CGFloat = 0                 //整个视图的高度
    public var backColor:UIColor = .white            //面板背景颜色
    public var titleColor:UIColor = UIColor.colorHexValue("4A4A4A")     //标题颜色
    public var textColor:UIColor = UIColor.colorHexValue("4A4A4A")      //文字颜色
    public var allCitys:[CityItem] = []              //所有城市
    public var curItem:ItemsView!                    //当前的定位城市
    private var core = SearchCore()                  //搜索
    private var maskV:UIView!                        //黑色遮罩
    private var resultView:UIView!                   //选择的界面
    
    //设置数据-更新UI
    public func setCitys(cur:CityItem?,recents:[CityItem],favorites:[CityItem]){
        let tmp:[CityItem] = recents.suffix(3);
        self.allHeight = 0;
        self.backgroundColor = backColor;
        //热门
        let item3 = ItemsView()
        item3.rightEdge = 30;
        item3.cornerRadius = 2;
        item3.titleColor = textColor;
        item3.delegate = self;
        let height3 = item3.initBtns(col: 3, items: collectionTitles(favorites));
        self.addSubview(item3);
        item3.mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(height3);
        }
        let title3 = UILabel.initText("热门城市", font: kFont(16), textColor: titleColor, alignment: .left, super: self);
        title3.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(16);
            maker?.bottom.mas_equalTo()(item3.mas_top);
        }
        self.allHeight += (height3 + 25)
        //历史
        var lastView = title3;
        if recents.count > 0 {
            let item2 = ItemsView()
            item2.rightEdge = 30;
            item2.cornerRadius = 2;
            item2.titleColor = textColor;
            item2.delegate = self;
            let height2 = item2.initBtns(col: 3, items: collectionTitles(tmp));
            self.addSubview(item2);
            item2.mas_makeConstraints { (maker) in
                maker?.left.right()?.mas_equalTo()(self);
                maker?.height.mas_equalTo()(height2);
                maker?.bottom.mas_equalTo()(lastView.mas_top);
            }
            let title2 = UILabel.initText("历史城市", font: kFont(16), textColor: titleColor, alignment: .left, super: self);
            title2.mas_makeConstraints { (maker) in
                maker?.left.mas_equalTo()(self)?.offset()(16);
                maker?.bottom.mas_equalTo()(item2.mas_top);
            }
            lastView = title2;
            self.allHeight += (height2 + 25)
        }
        //当前定位
        let item1 = ItemsView()
        curItem = item1;
        item1.rightEdge = 30;
        item1.titleColor = textColor;
        item1.cornerRadius = 2;
        item1.delegate = self;
        self.addSubview(item1);
        let height1 = item1.initBtns(col: 3, items: [cur?.name ?? "定位"]);
        item1.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self);
            maker?.bottom.mas_equalTo()(lastView.mas_top);
            maker?.height.mas_equalTo()(height1);
        }
        let title1 = UILabel.initText("当前定位", font: kFont(16), textColor: titleColor, alignment: .left, super: self);
        title1.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(16);
            maker?.bottom.mas_equalTo()(item1.mas_top);
        }
        //搜索框
        let search = SearchTextFieldV()
        search.initPlaceHolder(nil, attribute: NSString.attribute("请输入城市名或拼音", font: kFont(14), color: UIColor.colorHexValue("9E9E9E")));
        search.textFiled.delayDelegete = self;
        self.addSubview(search);
        search.mas_makeConstraints { (maker) in
            maker?.left.right()?.top()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(55);
        }
        //遮罩
        maskV = UIView()
        maskV.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.3);
        self.addSubview(maskV);
        maskV.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self);
            maker?.top.mas_equalTo()(search.mas_bottom);
            maker?.height.mas_equalTo()(ScreenSize().height);
        }
        maskV.isHidden = true;
        //搜索结果
        resultView = UIView()
        resultView.backgroundColor = .white;
        maskV.addSubview(resultView);
        resultView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(maskV);
            maker?.height.mas_equalTo()(50);
        }
        
        self.allHeight += 55;
        self.allHeight += (height1 + 25)
        //设置搜索的数据
        core.setSource(allCitys);
        for (i,item) in allCitys.enumerated() {
            core.addMatch(String(format: "%@%@%@", item.name,item.name_en ?? "",item.city_id), index: i);
        }
    }
    
    
    //获取标题文字
    private func collectionTitles(_ items:[CityItem])->[String]{
        var titles:[String] = [];
        for item in items{
            titles.append(item.name);
        }
        return titles;
    }
    
    
    //更新当前位置
    public func updateCurrent(_ current:String){
       _ = curItem.initBtns(col: 3, items: [current]);
    }
    
    
    //点击其中的项目
    func objClickTitle(_ title: String) {
        if title == "定位" {
            delegate?.callUserLocation();
        }else{
            for it in allCitys {
                if it.name == title{
                    delegate?.selectCity(it);
                    break;
                }
            }
        }
    }
    
    
    //文字更改停下来调用
    func textFieldDelayDidChange(_ text: String) {
        if text.count == 0 {
            resultView.isHidden = true;
        }else{
            //去除之间的空格
            let final:String = text.trimWhiteSpace();
            //搜索结果
            let result:[CityItem] = core.searchFor(final) as! [CityItem];
            maskV.isHidden = false;
            resultView.isHidden = false;
            resultView.clearSubviews();
            let only = result.first;
            //展示列表
            let str = result.count == 1 ? only?.name ?? "抱歉，未找到相关城市，请尝试修改" : "抱歉，未找到相关城市，请尝试修改";
            let label = UILabel.initText(str, font: kFont(16), textColor: UIColor.colorHexValue("4A4A4A"), alignment: .left, super: resultView);
            label.mas_makeConstraints { (maker) in
                maker?.left.mas_equalTo()(resultView)?.offset()(16);
                maker?.centerY.mas_equalTo()(resultView);
            }
            let btn = UIButton()
            btn.titleLabel?.text = str;
            resultView.addSubview(btn);
            btn.mas_makeConstraints { (maker) in
                maker?.left.right().mas_equalTo()(resultView)?.offset()(16);
                maker?.top.bottom()?.mas_equalTo()(resultView);
            }
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside);
        }
    }
    
    
    @objc private func btnClick(_ sender:UIButton){
        let title = sender.titleLabel?.text ?? "";
        objClickTitle(title);
    }
    
    
    func textBeiginEdit() {
        maskV.isHidden = false;
        resultView.isHidden = true;
        delegate?.tableViewScrollEnable(false);
    }
    
    
    func textDidEndEdit() {
        maskV.isHidden = true;
        delegate?.tableViewScrollEnable(true);
    }
    
    
}







