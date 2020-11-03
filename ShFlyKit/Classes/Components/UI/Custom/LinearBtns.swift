//
//  LinearBtns.swift
//  SHKit
//
//  Created by hsh on 2018/10/30.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


//线性方向枚举值-水平，垂直
public enum LinearDirection{
    case Horizontal,Vertical
}


///用于创建连续的水平/垂直方向的大小一致，中间有分割线的按钮群
public class LinearBtns: UIView {

    //用于操作的视图数组
    private var managerViews = [UIView]()           //内部多个视图
    private var allZero:Bool = true                 //间距是否全部为0
    
    //添加子视图及其按钮对应的视图下标数组
    private func generateViews(direction:LinearDirection,margins:[CGFloat],btnsCount:NSInteger,btnSize:CGSize)->(CGFloat,[NSInteger]){
        //不足补0,补足所有间隙
        var spans = margins;
        while spans.count<btnsCount-1{
            spans.append(0);
        }
        //判断是否全为0
        for span in spans{
            if (span > 0) {
                allZero = false;
            }
        }
        //往span第0位加个0，方便计算p
        spans.insert(0, at: 0);
        //所有的距离之和
        var allSpan:CGFloat = 0;
        //对应下标的按钮对应的父视图的下标值数组
        var indexs = [NSInteger]();
        //每个单元格的间距
        let margin:CGFloat = direction == LinearDirection.Horizontal ? btnSize.width : btnSize.height;
        
        //使用变量
        var distance:CGFloat = 0;                    //次级视图的长度
        var lastSpan:CGFloat = 0;                    //最后一个间距
        var tmpSpan:CGFloat = 0;                     //临时间距变量
        
        for index in 0...btnsCount {//遍历次数=按钮个数+1
            //间距
            var span:CGFloat = 0;
            if index < spans.count {
                span = spans[index];
                if (span > 0) {
                    lastSpan = tmpSpan;
                    tmpSpan = span;
                }
            }
            //最后一个间距更新
            if index == btnsCount{
                lastSpan = tmpSpan;
            }
            //累加所有间隙
            allSpan += span;
            //有间隙时添加视图
            if (span != 0 || index == btnsCount || allZero){//之间间距不为0，下标为最后一个时，是否间距全部为0三种条件都添加视图
                //创建次级视图，之间有间距
                let view = UIView();
                view.backgroundColor = UIColor.white;
                self.addSubview(view);
                //最后一个视图
                let lastView = self.managerViews.last;
                view.mas_makeConstraints { (maker) in
                    if lastView != nil{
                        if direction == LinearDirection.Horizontal{
                            maker?.top.bottom().mas_equalTo()(lastView);
                            maker?.left.mas_equalTo()(lastView?.mas_right)?.offset()(lastSpan);
                            maker?.width.mas_equalTo()(distance);
                        }else{
                            maker?.left.right().mas_equalTo()(lastView);
                            maker?.top.mas_equalTo()(lastView?.mas_bottom)?.offset()(lastSpan);
                            maker?.height.mas_equalTo()(distance);
                        }
                    }else{
                        if direction == LinearDirection.Horizontal{
                            maker?.left.top()?.bottom().mas_equalTo()(self);
                            maker?.width.mas_equalTo()(distance);
                        }else{
                            maker?.left.top()?.right().mas_equalTo()(self);
                            maker?.height.mas_equalTo()(distance);
                        }
                    }
                }
                self.managerViews.append(view);
                distance = 0;//重置长度
            }
            //累加高度
            distance += margin;
            indexs.append(self.managerViews.count);
        }
        return (allSpan,indexs);
    }
    
    
    
    //初始化
    class public func initWithDirection(direction:LinearDirection,btns:[UIButton],spans:[CGFloat],btnSize:CGSize,
                                        lineColor:UIColor = UIColor.lightGray,dashline:Bool = false)->(LinearBtns,CGSize){
        
        //初始量
        let width:CGFloat = btnSize.width;
        let height:CGFloat = btnSize.height;
        //视图本身
        let linearBtns = LinearBtns();
        linearBtns.backgroundColor = UIColor.clear;//透明色
        //计算子视图结果
        let result = linearBtns.generateViews(direction: direction, margins: spans,btnsCount:btns.count, btnSize: btnSize);
        var allSpan = result.0          //所有间距之和
        let indexs = result.1           //所有按钮对应的次级视图的下标
        
        
        var lastBtn:UIView! = nil                 //最后一个按钮
        var lastIndex:NSInteger = 0;              //上次的下标值
        //添加视图
        if direction == LinearDirection.Horizontal {
            //视图的大小
            linearBtns.frame.size = CGSize(width: width*CGFloat(btns.count)+allSpan, height: height);
            //遍历添加
            for (index,btn) in btns.enumerated(){
                //对应视图的下标
                let viewIndex = indexs[index];
                //当前的下标与上次不一样，新选一个视图来添加
                if (viewIndex != lastIndex) {
                    lastIndex = viewIndex;
                    lastBtn = nil;
                }
                //取出对应视图，添加按钮
                let containView = linearBtns.managerViews[lastIndex];
                containView.addSubview(btn);
                containView.sendSubview(toBack: btn);
                btn.mas_makeConstraints { (maker) in
                    if lastBtn != nil{
                        maker?.left.mas_equalTo()(lastBtn.mas_right);
                        maker?.top.bottom().mas_equalTo()(lastBtn);
                        maker?.width.mas_equalTo()(width);
                    }else{
                        maker?.left.top()?.bottom().mas_equalTo()(containView);
                        maker?.width.mas_equalTo()(width);
                    }
                }
                lastBtn = btn;
                //下一个视图的下标
                var nextIndex = viewIndex;
                if (index+1) < indexs.count {
                    nextIndex = indexs[index + 1];
                }
                //同一个下标的次级视图内决定是否加载  / 全0间隙，除去第一个都要加
                let shouldAddLine = (viewIndex == nextIndex) || (linearBtns.allZero && viewIndex != 0);
                //加分割线
                if shouldAddLine == true{
                    var line = UIView(for:lineColor);
                    if dashline == true{
                        line = UIView(forDashLineSize: CGSize(width: 1, height: height), color: lineColor, length: 2, space: 2)
                    }
                    containView.addSubview(line!);
                    line!.mas_makeConstraints { (maker) in
                        if viewIndex == nextIndex{
                            maker?.left.mas_equalTo()(lastBtn.mas_right);
                        }else{
                            maker?.left.mas_equalTo()(containView);
                        }
                        maker?.width.mas_equalTo()(0.5);
                        maker?.top.mas_equalTo()(linearBtns.mas_top)?.offset()(2);
                        maker?.bottom.mas_equalTo()(linearBtns.mas_bottom)?.offset()(-2);
                    }
                }
            }
        }else{
            //视图的大小
            linearBtns.frame.size = CGSize(width: width, height: height*CGFloat(btns.count)+allSpan);
            //遍历添加
            for (index,btn) in btns.enumerated(){
                //对应视图的下标
                let viewIndex = indexs[index];
                //当前的下标与上次不一样，新选一个视图来添加
                if (viewIndex != lastIndex) {
                    lastIndex = viewIndex;
                    lastBtn = nil;
                }
                //取出对应视图，添加按钮
                let containView = linearBtns.managerViews[lastIndex];
                containView.addSubview(btn);
                containView.sendSubview(toBack: btn);
                btn.mas_makeConstraints { (maker) in
                    if lastBtn != nil{
                        maker?.top.mas_equalTo()(lastBtn.mas_bottom);
                        maker?.left.right()?.mas_equalTo()(containView);
                        maker?.height.mas_equalTo()(height);
                    }else{
                        maker?.top.mas_equalTo()(containView);
                        maker?.left.right()?.mas_equalTo()(containView);
                        maker?.height.mas_equalTo()(height);
                    }
                }
                lastBtn = btn;
                //下一个视图的下标
                var nextIndex = viewIndex;
                if (index+1) < indexs.count {
                    nextIndex = indexs[index + 1];
                }
                //同一个下标的次级视图内决定是否加载  / 全0间隙，除去第一个都要加
                let shouldAddLine = (viewIndex == nextIndex)  || (linearBtns.allZero && viewIndex != 0);
                //加分割线
                if shouldAddLine == true{
                    allSpan += 0.5;
                    var line = UIView(for: lineColor)
                    if dashline == true{
                        line = UIView(forDashLineSize: CGSize(width: width, height: 1), color: lineColor, length: 2, space: 2)
                    }
                    containView.addSubview(line!);
                    line!.mas_makeConstraints { (maker) in
                        if viewIndex == nextIndex{
                            maker?.top.mas_equalTo()(lastBtn.mas_bottom);
                        }else{
                            maker?.top.mas_equalTo()(containView);
                        }
                        maker?.height.mas_equalTo()(0.5);
                        maker?.left.mas_equalTo()(linearBtns.mas_left)?.offset()(2);
                        maker?.right.mas_equalTo()(linearBtns.mas_right)?.offset()(-2);
                    }
                }
            }
        }
        return (linearBtns,CGSize(width: linearBtns.width, height: linearBtns.height));
    }

    
    
    //设置分隔开的各部分按钮及其颜色
    public func setCorners(radius:CGFloat,color:UIColor,width:CGFloat)->Void{
        for subView in managerViews {
            subView.layer.cornerRadius = radius;
            subView.layer.borderColor = color.cgColor;
            subView.layer.borderWidth = width;
            subView.layer.masksToBounds = true;
        }
    }
    
    
}
