//
//  AutoScrollLables.swift
//  SHKit
//
//  Created by hsh on 2019/2/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

//点击的代理协议
@objc protocol AutoScrollDelegate:NSObjectProtocol {
    //点击选中的下标
    func scrollDidSelect(index:NSInteger)
}

//滚动方向
@objc enum ScrollDirection:Int {
    case Horizontal,Vertical
}


///滚动的容器类--自动无限循环滚动/手动循环滚动  水平/垂直方向  翻页/不翻页
class AutoScrollView: UIView,DisplayDelegate,UIScrollViewDelegate,HeatBeatTimerDelegate {
    //mark-variable
    public weak var delegate:AutoScrollDelegate?        //点击代理--设置了代理后自动添加点击
    private (set) var scrollWidth:CGFloat = 0           //滚动视图宽度
    private (set) var scrollHeight:CGFloat = 0          //滚动视图高度
    public  var autoScroll:Bool = true                  //是否自动滚动
    public  var pageEnable:Bool = false                 //是否翻页
    public  var pageInterval:NSInteger = 5              //翻页的时间间隔
    public  var rate:CGFloat = 0.5                      //滚动的速率
    
    private var direction:ScrollDirection!              //滚动方向
    private var scrollV:UIScrollView!                   //滚动容器
    private var contentWidth:CGFloat = 0                //水平滚动时,一份视图滚动的宽度值
    private var contentHeight:CGFloat = 0               //垂直滚动时，一份视图滚动的高度值
    private var startPoint:CGFloat = 0                  //滚动的起点
    private var step:NSInteger = 0                      //滚动时的步
    private var pageNum:NSInteger = 0                   //翻页数
    private var pageMargin:CGFloat = 0
    
  
    ///MARK-Load
    @objc class public func initView(width:CGFloat,height:CGFloat)->AutoScrollView{//返回视图和视图的高度
        let scroll = AutoScrollView()
        scroll.scrollWidth = width;
        scroll.scrollHeight = height;
        scroll.scrollV = UIScrollView()
        scroll.scrollV.showsVerticalScrollIndicator = false;
        scroll.scrollV.showsHorizontalScrollIndicator = false;
        scroll.addSubview(scroll.scrollV);
        scroll.scrollV.bounces = true;
        scroll.scrollV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(scroll);
        }
        return scroll;
    }
    
    
    //外部创建的三份同样的视图，一组公用的宽度值，一组公用的间距值(仅水平方向使用)，仅设置水平有效，垂直方向是视图的大小
    @objc public func customView(direction:ScrollDirection,previews:[UIView],views:[UIView],reviews:[UIView],margin:CGFloat,span:CGFloat)->Void{
        //滚动方向
        self.direction = direction;
        //页码数
        self.pageNum = views.count;
        //清空原有视图
        for sub in scrollV.subviews {
            sub.removeFromSuperview()
        }
        //是否翻页
        scrollV.isPagingEnabled = pageEnable;
        //自动滚动的不允许自己手动滚动
        scrollV.isScrollEnabled = autoScroll == false;
        //变量清零
        self.contentWidth = 0;
        self.contentHeight = 0;
        pageMargin = margin + span;
        //统一的添加按钮的方法-一个完全覆盖的按钮
        func addClickBtn(_ view:UIView,index:NSInteger)->Void{
            let btn = UIButton.init();
            btn.tag = index;
            btn.addTarget(self, action: #selector(clickIndex(_:)), for: UIControl.Event.touchUpInside);
            view.addSubview(btn);
            btn.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(view);
            }
        }
        //添加视图
        if direction == ScrollDirection.Horizontal {
            //水平方向时
            func addViews(_ views:[UIView],calculate:Bool,start:CGFloat)->CGFloat{
                var length:CGFloat = 0;                                                             //统计这次添加的所有k宽度
                for (index,view) in views.enumerated() {
                    length += span;
                    view.frame = CGRect(x: length+start, y: 0, width: margin, height: scrollHeight);
                    length += margin;
                    scrollV.addSubview(view);
                    if delegate != nil{
                        addClickBtn(view, index: index)
                    }
                    if calculate{//有效滚动范围
                        contentWidth += (margin+span);
                    }
                }
                return length;
            }
            let end1 = addViews(previews, calculate: false,start: 0);
            let end2 = addViews(views, calculate: true,start: end1);
            let end3 = addViews(reviews, calculate: false,start: end1+end2);
            //滚动的起点
            startPoint = end1;
            //设置滚动距离
            scrollV.contentSize = CGSize(width: end1+end2+end3, height: 0);
            if (pageEnable == true) {
                scrollV.clipsToBounds = false;
                //将滚动视图的的大小刚好设置成一页和间距的大小，并且，按照间距的距离往左移动一半的间距
                scrollV.mas_updateConstraints { (maker) in
                    maker?.left.mas_equalTo()((scrollWidth-pageMargin)/2.0-span/2.0);
                    maker?.right.mas_equalTo()(self)?.offset()(-((scrollWidth-pageMargin)/2.0+span/2.0));
                    maker?.top.bottom()?.mas_equalTo()(self);
                }
            }
            //设置好久跑到启动点
            scrollV.setContentOffset(CGPoint(x: startPoint, y: 0), animated: false);
            //当滚动距离大于屏幕宽度，需要滚动
            if contentWidth > scrollWidth {
                if autoScroll {
                    if pageEnable {//使用页码滚动定时器，每秒一次
                         HeatBeatTimer.shared.addTimerTask(identifier: "自动滚动", span: 1, repeatCount: 0, delegate: self);
                    }else{//使用帧率速度调用的定时器
                         HeatBeatTimer.shared.addDisplayTask(self);
                    }
                }else{//手动滚动
                    scrollV.delegate = self;
                }
            }
        }else{
            //垂直方向时
            func addViews(_ views:[UIView],calculate:Bool,start:CGFloat)->CGFloat{
                var length:CGFloat = 0;
                for (_,view) in views.enumerated() {
                    pageMargin = scrollHeight;
                    //视图的坐标
                    view.frame = CGRect(x: 0, y: length+start, width: scrollWidth, height: scrollHeight);
                    length += scrollHeight;
                    scrollV.addSubview(view);
                    if calculate{//有效滚动范围
                        contentHeight += scrollHeight;
                    }
                }
                return length;
            }
            let end1 = addViews(previews, calculate: false,start: 0);
            let end2 = addViews(views, calculate: true,start: end1);
            let end3 = addViews(reviews, calculate: false,start: end1+end2);
            startPoint = end1;
            //设置滚动距离
            scrollV.contentSize = CGSize(width: 0, height: end1+end2+end3);
            scrollV.setContentOffset(CGPoint(x: 0, y: startPoint), animated: false);
            //当滚动距离大于屏幕宽度，需要滚动
            if contentHeight > scrollHeight {
                if autoScroll {
                    if pageEnable {//使用页码滚动定时器，每秒一次
                        HeatBeatTimer.shared.addTimerTask(identifier: "自动滚动", span: 1, repeatCount: 0, delegate: self);
                    }else{//使用帧率速度调用的定时器
                        HeatBeatTimer.shared.addDisplayTask(self);
                    }
                }else{//手动滚动
                    scrollV.delegate = self;
                }
            }
        }
    }
    
    
    
    
    //CADisplay回调--自动滚动--不翻页---水平垂直--匀速
    func displayCalled() {
        var value:CGFloat  = CGFloat(step) * rate + startPoint;
        if value > (direction == ScrollDirection.Horizontal ? contentWidth + startPoint : contentHeight + startPoint) {
            value = startPoint;
            step = 0;
        }
        step += 1;
        let x = direction == ScrollDirection.Horizontal ? value : 0;
        let y = direction == ScrollDirection.Horizontal ? 0 : value;
        scrollV.setContentOffset(CGPoint(x: x, y: y), animated: false);
    }
    
    
    
    //手动滚动--水平/垂直
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if direction == ScrollDirection.Horizontal{
            let offset = scrollView.contentOffset.x;
            if offset > contentWidth + startPoint {
                scrollV.setContentOffset(CGPoint(x: startPoint, y: 0), animated: false);
            }else if offset < startPoint {
                scrollV.setContentOffset(CGPoint(x: contentWidth+startPoint, y: 0), animated: false);
            }
        }else{
            let offset = scrollView.contentOffset.y;
            if offset > contentHeight + startPoint {
                scrollV.setContentOffset(CGPoint(x: 0, y: startPoint), animated: false);
            }else if offset < 0 {
                scrollV.setContentOffset(CGPoint(x: 0, y: contentHeight + startPoint), animated: false);
            }
        }
    }
    
    
    
    //定时器回调-水平/垂直-自动-翻页滚动
    func timeTaskCalled(identifier: String) {
        //steo相当于秒数
        step += 1;
        //当达到秒数间隔执行
        if step % pageInterval == 0 {
            let curPage = Int(step / pageInterval)
            //当到达最后一页时,先翻到下一页后再回到起点
            if curPage >= pageNum {
                if direction == ScrollDirection.Horizontal{
                    self.scrollV.setContentOffset(CGPoint(x: CGFloat(curPage) * pageMargin + startPoint, y: 0), animated: true);
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(pageInterval)/2.0) {
                        self.scrollV.setContentOffset(CGPoint(x: self.startPoint, y: 0), animated: false);//滚动完迅速回到起点位置
                    }
                }else{
                    self.scrollV.setContentOffset(CGPoint(x: 0, y: CGFloat(curPage) * pageMargin + startPoint), animated: true);
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(pageInterval)/2.0) {
                        self.scrollV.setContentOffset(CGPoint(x: 0, y: self.startPoint), animated: false);
                    }
                }
                step = 0;
            }else{
                if direction == ScrollDirection.Horizontal{
                    scrollV.setContentOffset(CGPoint(x: CGFloat(curPage) * pageMargin + startPoint, y: 0), animated: true);
                }else{
                    scrollV.setContentOffset(CGPoint(x: 0, y: CGFloat(curPage) * pageMargin + startPoint), animated: true);
                }
            }
        }
    }
    
    
    
    //点击事件
    @objc private func clickIndex(_ sender:UIButton)->Void{
        delegate?.scrollDidSelect(index: sender.tag);
    }
    
    
    
}
