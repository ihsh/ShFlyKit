//
//  OtherVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/7.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit

class OtherVC: UIViewController,AttributeLabelDelegate,MulTipsViewDelegate {
    
    var count:CGFloat = 0.1;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        //属性字符串创建
        attributeLabelInit();
    }
    
    
    
    func attributeLabelInit() -> Void {
        //中间文字匹配的字符串
        let lable = AttributeLabel()
        self.view.addSubview(lable);
        
        lable.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self.view)?.offset()(180);
            maker?.right.mas_equalTo()(self.view)?.offset()(-16);
            maker?.top.mas_equalTo()(self.view)?.offset()(120);
        }
        let ele = AttributeElements();
        ele.normalFont = kFont(14);
        ele.normalColor = UIColor.colorRGB(red: 54, green: 54, blue: 54);
        ele.hightColor = UIColor.colorRGB(red: 85, green: 134, blue: 247);
        let config = AttributeConfig()
        config.elements = ele;
        
        lable.setContent("请在使用前查看并同意完整的隐私权政策及服务条款", compares: ["隐私权政策","服务条款"], config: config);
        lable.delegate = self;
        
        //区间匹配的方式
        let label2 = AttributeLabel()
        self.view.addSubview(label2);
        label2.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(lable.mas_bottom)?.offset()(16);
            maker?.right.mas_equalTo()(self.view)?.offset()(-16);
            maker?.left.mas_equalTo()(self.view)?.offset()(16);
        }
        let config2 = AttributeConfig()
        config2.startStr = "<tel>";
        config2.endStr = "</tel>";
        config2.replaceStart = "(";
        config2.replaceEnd = ")";
        config2.containsRange = false;
        config2.elements.normalColor = UIColor.colorRGB(red: 52, green: 52, blue: 54);
        config2.elements.hightColor = UIColor.colorHexValue("0xf16622");
        config2.elements.normalFont = kFont(14);
        config2.elements.hightFont = kFont(18);
        let str = "配送员开始配送，请你准备收货，配送员，段应成，手机号，<tel>13692249395</tel>或<tel>0755-25832332</tel>";
        label2.setContent(str, config: config2);
        label2.delegate = self;
        
    
        //添加标签视图
        let tipView = MulTipsView()
        tipView.numberOfLines = 3;
        tipView.cornerRadius = 5;
        self.view.addSubview(tipView);
        tipView.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self.view)?.offset()(16);
            maker?.top.mas_equalTo()(label2.mas_bottom)?.offset()(16);
            maker?.right.mas_equalTo()(self.view)?.offset()(-16);
            maker?.height.mas_equalTo()(80);
        }
        let arr = ["4号线/龙华线","44路","5号线/环中线","139路","60路","1号线/罗宝线","2号线/蛇口线","11号线/机场快线",
                   "4号线/龙华线","44路","5号线/环中线","139路","60路","1号线/罗宝线","2号线/蛇口线","11号线/机场快线"];
        let tmpArray = NSMutableArray()
        var index = 0;
        for str in arr {
            let model = TipsModel()
            model.text = str;
            model.touchEnable = index % 2 == 0;
            model.backColor = UIColor.randomColor();
            tmpArray.add(model);
            index += 1;
        }
        tipView.setTips(array: tmpArray as! [TipsModel],viewWidth: ScreenSize().width-32,delegate: self,sortByLength: true);
       
    
        
        let viewScroll = AutoScrollView.initView(width: ScreenSize().width, height: 150);
        self.view.addSubview(viewScroll);
        viewScroll.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(tipView.mas_bottom)?.offset()(16);
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(viewScroll.scrollHeight);
        }
        var views:[UIView] = [];
        var reviews:[UIView] = [];
        var previews:[UIView] = [];
        for _ in 0...3 {
            let view = UIView()
            let color =  UIColor.randomColor()
            view.backgroundColor = color;
            views.append(view);
            let view2 = UIView()
            view2.backgroundColor = color;
            reviews.append(view2);
            let view3 = UIView()
            view3.backgroundColor = color;
            previews.append(view3);
        }
        viewScroll.pageEnable = true;
        viewScroll.customView(direction: ScrollDirection.Horizontal,previews: previews, views: views, reviews: reviews, margin:265, span: 20)
        
        
        
    }
    
    
    
    func click(forText text: String) {
        print(text);
    }

    
    func tipsClickIn(index: NSInteger, text: String) {
        print("\(index)------\(text)");
    }
   
}
