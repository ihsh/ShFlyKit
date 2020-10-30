//
//  ProgressLabel.swift
//  SHKit
//
//  Created by hsh on 2020/2/27.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit


//显示进度的label-从左往右-歌词动效
public class ProgressLabel: UILabel {
    //Vrriable
    public private(set) var allProgress:CGFloat = 0  //整体进度-(包括多行的情况)
    //Private
    private var progress:CGFloat = 0                 //当前单行进度
    private var step:CGFloat = 0                     //步进值
    private var duration:CGFloat = 0                 //总时长
    private var hightColor:UIColor!                  //高亮颜色
    private var rows:Int = 0                         //有多少行
    private var rowHeight:CGFloat = 0                //行高
    private var curRow:Int = 0                       //当前行
    
    
    //设置文本及其对应的属性
    public func setText(text:String,color:UIColor,font:UIFont,hightColor:UIColor){
        self.text = text;
        self.textColor = color;
        self.font = font;
        self.hightColor = hightColor;
        self.numberOfLines = 0;
    }
    
    
    //自动计算步进值-秒数
    public func setDuration(sec:CGFloat){
        self.duration = sec;
        if self.bounds.size.width > 0 {
            self.step = 1*CGFloat(self.rows)/(sec*60);
        }
    }
    
    
    //往前移动
    public func goForward()->Void{
        
        if self.text?.count == 0 {
            return;
        }
        //行数
        if rows == 0 {
            //单位高度
            self.rowHeight = ("高度" as NSString).height(forWidth: 100, font: self.font);
            let height = (self.text! as NSString).height(forWidth: self.bounds.size.width, font: self.font);
            self.rows = Int(ceil(height/self.rowHeight));
        }
        //步进值
        if self.step == 0 {
            self.setDuration(sec: self.duration);
        }
        
        if self.step > 0 {
            self.progress += self.step;
            
            if progress >= 1 {
                //换行
                if curRow < self.rows - 1 {
                    curRow += 1;
                    self.progress = 0;
                }
            }else{
                self.setNeedsDisplay();
            }
            let sub:CGFloat = CGFloat(1.0/CGFloat(self.rows));
            self.allProgress = CGFloat(self.curRow) * sub + sub * self.progress;
        }
    }
    
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect);
        //当前行
        let fillRect = CGRect(x: 0, y: self.rowHeight * CGFloat(self.curRow),
                              width: self.bounds.size.width*self.progress, height: self.rowHeight);
        if (hightColor != nil) {
            hightColor.set();
            //旧的区域直接画
            if curRow > 0 {
                let fillRectOld = CGRect(x: 0, y: 0, width: self.bounds.size.width,
                                         height: self.rowHeight * CGFloat(self.curRow));
                UIRectFillUsingBlendMode(fillRectOld, .sourceIn);
            }
            UIRectFillUsingBlendMode(fillRect, .sourceIn);
        }
    }
    
    
}
