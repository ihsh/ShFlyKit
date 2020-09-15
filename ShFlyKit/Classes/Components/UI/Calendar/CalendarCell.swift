//
//  CalendarCell.swift
//  SHKit
//
//  Created by hsh on 2019/9/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//日历显示cell
class CalendarCell: UICollectionViewCell {
    //Variable
    private var backV:UIView!                   //容器视图
    private var dayL:UILabel!                   //日期
    private var contentL:UILabel!               //内容
    private var extText:UILabel!                //休息或加班
    private var layerV:UIView!                  //显示边框的图层
    
    
    //加载数据
    public func loadData(_ data:CalendarData,config:CalendarUIConfig,select:Bool){
        
        if data.isCurrent == false && config.showHeadTail == false {
            dayL.isHidden = true;
            contentL.isHidden = true;
            extText.isHidden = true;
            layerV.backgroundColor = .clear;
        }else{
            //隐藏属性
            dayL.isHidden = false;
            contentL.isHidden = config.showContent == false;
            if config.showContent {
                dayL.mas_updateConstraints { (maker) in
                    maker?.centerY.mas_equalTo()(backV)?.offset()(-8);
                }
            }else{
                dayL.mas_updateConstraints { (maker) in
                    maker?.centerY.mas_equalTo()(backV);
                }
            }
            extText.isHidden = false;
            //透明度
            dayL.alpha = data.isCurrent ? 1 : config.notCurrentAlpha;
            contentL.alpha = data.isCurrent ? 1 : config.notCurrentAlpha;
            extText.alpha = data.isCurrent ? 1 : config.notCurrentAlpha;
            //字体
            dayL.font = config.dayFont;
            contentL.font = config.contentFont;
            extText.font = config.restOverFont;
            //数据
            dayL.text = String(format: "%ld", data.day);
            contentL.text = data.content;
            if data.isRest {
                extText.backgroundColor = config.restBackColor;
                extText.text = "休";
                extText.isHidden = false;
            }else if data.isOverTime {
                extText.text = "班";
                extText.backgroundColor = config.overBackColor;
                extText.isHidden = false;
            }else{
                extText.isHidden = true;
            }
            //字体的颜色
            dayL.textColor = data.isWork ? config.dayWorkColor : config.dayWeekendColor;
            if data.holidayType == 1 {
                contentL.textColor = config.solarsColor;
            }else if data.holidayType == 2 || data.holidayType == 3 {
                contentL.textColor = config.holidayColor;
            }else{
                contentL.textColor = data.isWork ? config.norLunalColor : config.holidayColor;
            }
            
            //背景色
            let mi = min(backV.width, backV.height);
            //选中时
            if select == true{
                if config.selectStyle == .CircleFill {
                    layerV.backgroundColor = config.fillStrokeColor;
                    layerV.layer.cornerRadius = mi/2.0;
                    layerV.layer.masksToBounds = true;
                    layerV.layer.borderWidth = 0;
                    dayL.textColor = config.fillTextColor ?? UIColor.white;
                    contentL.textColor = config.fillTextColor ?? UIColor.white;
                }else if config.selectStyle == .SquareFill {
                    layerV.backgroundColor = config.fillStrokeColor;
                    layerV.layer.cornerRadius = config.strokeCornerRadius;
                    layerV.layer.masksToBounds = true;
                    layerV.layer.borderWidth = 0;
                    dayL.textColor = config.fillTextColor ?? UIColor.white;
                    contentL.textColor = config.fillTextColor ?? UIColor.white;
                }else if config.selectStyle == .SquarePath{
                    layerV.backgroundColor = UIColor.clear;
                    layerV.layer.cornerRadius = config.strokeCornerRadius;
                    layerV.layer.masksToBounds = true;
                    layerV.layer.borderWidth = config.strokeLineWidth;
                    layerV.layer.borderColor = config.fillStrokeColor.cgColor;
                }
            }else{
                if data.isToday {
                    if config.selectStyle == .CircleFill {
                        layerV.backgroundColor = config.todayColor;
                        layerV.layer.cornerRadius = mi/2.0;
                        layerV.layer.masksToBounds = true;
                        layerV.layer.borderWidth = 0;
                        dayL.textColor = config.fillTextColor ?? UIColor.white;
                        contentL.textColor = config.fillTextColor ?? UIColor.white;
                    }else if (config.selectStyle == .SquareFill){
                        layerV.backgroundColor = config.todayColor;
                        layerV.layer.cornerRadius = config.strokeCornerRadius;
                        layerV.layer.masksToBounds = true;
                        layerV.layer.borderWidth = 0;
                        dayL.textColor = config.fillTextColor ?? UIColor.white;
                        contentL.textColor = config.fillTextColor ?? UIColor.white;
                    }else if (config.selectStyle == .SquarePath){
                        layerV.backgroundColor = UIColor.clear;
                        layerV.layer.cornerRadius = config.strokeCornerRadius;
                        layerV.layer.masksToBounds = true;
                        layerV.layer.borderWidth = config.strokeLineWidth;
                        layerV.layer.borderColor = config.todayColor.cgColor;
                    }
                }else{
                    layerV.backgroundColor = UIColor.clear;
                    layerV.layer.cornerRadius = 0;
                    layerV.layer.masksToBounds = false;
                    layerV.layer.borderColor = UIColor.clear.cgColor;
                    layerV.layer.borderWidth = 0;
                }
            }
        }
    }
    
    
    
    ///Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        //容器图层
        backV = UIView()
        backV.backgroundColor = UIColor.clear;
        self.contentView.addSubview(backV);
        backV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.contentView);
        }
        //显示边框图层
        layerV = UIView()
        layerV.backgroundColor = UIColor.clear;
        backV.addSubview(layerV);
        layerV.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(backV);
            make?.width.height()?.mas_equalTo()(ScreenSize().width/7.0);
        }
        //日期文本
        dayL = UILabel.initText(nil, font: kFont(14), textColor: UIColor.black, alignment: .center, super: backV);
        dayL.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(backV);
            maker?.centerY.mas_equalTo()(backV)?.offset()(-8);
        }
        //日期文本
        contentL = UILabel.initText(nil, font: kFont(12), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .center, super: backV);
        contentL.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(backV);
            maker?.top.mas_equalTo()(dayL.mas_bottom);
        }
        //休息日文本
        extText = UILabel.initText(nil, font: kFont(8), textColor: UIColor.white, alignment: .center, super: backV);
        extText.layer.cornerRadius = 6;
        extText.layer.masksToBounds = true;
        extText .mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(dayL.mas_right);
            maker?.centerY.mas_equalTo()(dayL.mas_top);
            maker?.width.height()?.mas_equalTo()(12);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}





