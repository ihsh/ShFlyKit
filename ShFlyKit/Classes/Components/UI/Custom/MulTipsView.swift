//
//  MulTipsView.swift
//  SHKit
//
//  Created by hsh on 2018/12/7.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit



public class TipsModel: NSObject {
    public var text:String!                                                 //文本
    public var textColor = UIColor.white                                    //文字颜色
    public var font = kFont(12)                                             //文字大小
    public var backColor = UIColor.colorRGB(red: 92, green: 164, blue: 248);//背景颜色
    public var touchEnable = false                                          //是否处理触摸事件
}



//代理协议
public protocol MulTipsViewDelegate : NSObjectProtocol {
    //点击的下标和对应的文本
    func tipsClickIn(index:NSInteger,text:String)
}


///显示一连串标签的视图
public class MulTipsView: UIView {
    
    private weak var tipDelegate:MulTipsViewDelegate?//代理对象

    public var numberOfLines:Int = 1            //可换行数 0为无限制
    public var cornerRadius:CGFloat = 5         //全局圆角
    public var innerSpan:CGFloat = 3            //内部间距
    
    public var rowHeight:CGFloat = 18           //行高
    public var columnSpan:CGFloat = 5           //水平间距
    public var rowSpan:CGFloat = 5              //垂直方向间距
    
    
    //设置内容
    public func setTips(array:[TipsModel],viewWidth:CGFloat,delegate:MulTipsViewDelegate?,sortByLength:Bool = false)->Void{
        tipDelegate = delegate;
        //排序
        var tips = array;
        if sortByLength == true {
            tips.sort { (model1:TipsModel, model2:TipsModel) -> Bool in
                return model1.text.count <= model2.text.count;
            }
        }
        //移除旧视图
        for sub in self.subviews {
            sub.removeFromSuperview();
        }
        if ((self.layer.sublayers) != nil) {
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
        }
        //加载视图
        var startX = columnSpan;
        var startY = rowSpan;
        var lines = 1;
        let maxWidth = viewWidth;
        
        for (index,model) in tips.enumerated() {
            //坐标计算
            let string:NSString = NSString.init(string: model.text);
            //计算宽度
            var width = string.width(with: model.font);
            width = width + innerSpan * 2;
            if (startX + width > maxWidth){
                lines += 1;
                //超过行数不显示
                if (lines > numberOfLines && numberOfLines != 0){
                    //在最后补 ...
                    let textLayer = CATextLayer()
                    textLayer.string = "...";
                    let cgFont = CGFont.init(model.font.fontName as CFString)
                    textLayer.font = cgFont;
                    textLayer.fontSize = model.font.pointSize;
                    textLayer.foregroundColor = UIColor.black.cgColor;
                    textLayer.backgroundColor = UIColor.white.cgColor;
                    textLayer.frame = CGRect(x: startX, y: startY, width: 10, height: 20+rowSpan);
                    textLayer.contentsScale = UIScreen.main.scale;
                    self.layer.addSublayer(textLayer);
                    return
                }
                //更新X,Y坐标
                startX = columnSpan;
                startY += (rowHeight + rowSpan);
            }
            //生成坐标
            let rect = CGRect(x: startX, y: startY, width: width, height: rowHeight);
            //更新坐标值
            startX += (width + columnSpan)
            
            //创建元素
            if model.touchEnable{
                let btn = UIButton()
                btn.setTitle(model.text, for: UIControlState.normal);
                btn.setTitleColor(model.textColor, for: UIControlState.normal);
                btn.backgroundColor = model.backColor;
                btn.titleLabel?.textAlignment = .center;
                btn.titleLabel?.font = model.font;
                btn.frame = rect;
                btn.layer.cornerRadius = cornerRadius;
                btn.layer.masksToBounds = true;
                btn.addTarget(self, action: #selector(btnClick(btn:)), for: UIControlEvents.touchUpInside);
                btn.tag = index;
                self.addSubview(btn);
            }else{
                let textLayer = CATextLayer()
                textLayer.string = model.text;
                textLayer.frame = rect;
                textLayer.isWrapped = true;
                textLayer.backgroundColor = model.backColor.cgColor;
                textLayer.foregroundColor = model.textColor.cgColor;
                let cgFont = CGFont.init(model.font.fontName as CFString)
                textLayer.font = cgFont;
                textLayer.fontSize = model.font.pointSize;
                textLayer.alignmentMode = kCAAlignmentCenter;
                textLayer.cornerRadius = cornerRadius
                textLayer.contentsScale = UIScreen.main.scale;
                self.layer.addSublayer(textLayer);
            }
        }
    }
    
    
    
    //按钮点击
    @objc private func btnClick(btn:UIButton)->Void{
        if (tipDelegate != nil) {
            tipDelegate!.tipsClickIn(index: btn.tag, text: btn.titleLabel?.text ?? "");
        }
    }
    
    
    
}
