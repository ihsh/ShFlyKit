//
//  ActivityView.swift
//  SHKit
//
//  Created by hsh on 2019/12/5.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import SDWebImage

//关闭按钮的位置
enum ClosePosition {
    case Bottom,RightCorner     //底部，右上角
}

@objc protocol ActivityViewDelegate:NSObjectProtocol {
    //点击链接
    func clickActivity(_ url:String)
    //点击消失
    @objc optional func clickDismiss();
}


///活动闪屏
class ActivityView: UIView,HeatBeatTimerDelegate{
    //Variable
    public weak var delegate:ActivityViewDelegate?
    
    private var queues:[ActivityModel] = []     //所有待显示的数据
    private var curModel:ActivityModel!         //当前正在展示的数据
    private var closeBtn:UIButton!              //关闭按钮
    private var mainImgV:UIImageView!           //主要展示视图
   
    
    //添加到活动显示序列
    public func queueActivity(_ activity:ActivityModel){
        queues.append(activity);
        HeatBeatTimer.shared.addTimerTask(identifier: "ActivityView", span: 1, repeatCount: 0, delegate: self);
    }
    
    
    //HeatBeatTimerDelegate
    func timeTaskCalled(identifier: String) {
        //当前无正在处理再继续
        if curModel == nil {
            let first = queues.first;
            if first != nil{
                self.showActivity(first!);
            }else{
                HeatBeatTimer.shared.cancelTaskForKey(taskKey: "ActivityView");
            }
        }
    }
    
    
    //展示活动
    private func showActivity(_ activity:ActivityModel){
        
        let window = UIApplication.shared.delegate!.window!!;
        //如果需要锁定view显示的话
        if activity.focusView != nil {
            //当前显示的控制器
            let vc = UIViewController.getCurrentVC();
            //锁定视图所在的控制器
            let fvc = activity.focusView?.viewController();
            //如果锁定视图控制器存在且不是当前显示的
            if (fvc != nil) {
                if vc.isEqual(fvc) == false {return}
            }
            var same = activity.ignoreWindow;
            //window总会有一个成员UILayoutContainerView,如果当前有弹窗等，会有别的视图UIView
            if window.subviews.count <= 1 {
                same = vc.view.isEqual(activity.focusView!);
            }else{
                //有弹窗
                for sub in window.subviews {
                    if sub.isEqual(activity.focusView) {
                        same = true;
                    }
                }
            }
            //对比失败，禁止继续
            if same == false {return}
        }
        //通过校验，显示
        curModel = activity;
        //遮罩色
        self.backgroundColor = activity.maskColor;
        self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        window.addSubview(self);
        
        //图片内容
        if mainImgV == nil {
            mainImgV = UIImageView()
            //自适应比例
            mainImgV.contentMode = .scaleAspectFit;
            mainImgV.isUserInteractionEnabled = true;
            self.addSubview(mainImgV);
            //添加点击按钮
            let btn = UIButton()
            btn.addTarget(self, action: #selector(clickActivity), for: .touchUpInside);
            mainImgV.addSubview(btn);
            btn.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(mainImgV);
            }
        }
        mainImgV.alpha = 1;
        //设置图片约束
        func setImageConstraints(image:UIImage){
            mainImgV.mas_remakeConstraints { (make) in
                make?.center.mas_equalTo()(self);
                let imgW:CGFloat = image.width();
                let imgH:CGFloat = image.height();
                var limit = ScreenSize().width - 32;
                //如果需要控制size
                if activity.imgWidth != nil{
                    let rate:CGFloat = ScreenSize().width/375.0;
                    let width:CGFloat = activity.imgWidth! * rate;
                    limit = min(limit,width);
                }
                let final = imgH * limit / imgW;
                make?.width.mas_equalTo()(limit);
                make?.height.mas_equalTo()(final);
            }
        }
        //查找图片
        let img = UIImage.init(named: activity.imgUrl);
        if img == nil {
            //下载图片,SDWebImage对ImageV是弱引用，不会造成循环引用
            mainImgV.sd_setImage(with: URL.init(string: activity.imgUrl), placeholderImage: activity.imgPlaceHolder, options: SDWebImageOptions.continueInBackground) { (image, error, _, _) in
                if (image != nil){
                    setImageConstraints(image: image!);
                }
            }
        }else{
            mainImgV.image = img;
            setImageConstraints(image: img!);
        }
        
        //关闭按钮
        if closeBtn == nil{
            closeBtn = UIButton()
            closeBtn.addTarget(self, action: #selector(closeActivity), for: .touchUpInside);
            self.addSubview(closeBtn);
        }
        closeBtn.isHidden = false;
        closeBtn.setImage(activity.closeBtnImg, for: .normal);
        //按钮的位置
        if activity.closePosition == .RightCorner {
            closeBtn.mas_remakeConstraints { (make) in
                make?.centerX.mas_equalTo()(mainImgV.mas_right)?.offset()(activity.offset.width);
                make?.centerY.mas_equalTo()(mainImgV.mas_top)?.offset()(-activity.offset.height);
            }
        }else if (activity.closePosition == .Bottom){
            closeBtn.mas_remakeConstraints { (make) in
                make?.centerY.mas_equalTo()(mainImgV);
                make?.top.mas_equalTo()(mainImgV.mas_bottom)?.offset()(-activity.offset.height);
            }
        }
        
    }
    
    
    //关闭
    @objc private func closeActivity(act:Bool){
        self.closeBtn.isHidden = true;
        //移除当前显示
        func removeCurShow(){
            self.removeFromSuperview();
            //移除当前显示的模型
            self.curModel = nil;
            self.queues.remove(at: 0);
        }
        //如果需要移动到指定点
        if curModel.targetPoint != nil {
            UIView.animate(withDuration: max(0.3,curModel!.animateDuration), animations: {
                self.mainImgV.frame = CGRect(x: self.curModel.targetPoint!.x,
                                             y: self.curModel.targetPoint!.y, width: 0, height: 0)
                self.mainImgV.alpha = 0;
            }) { (_) in
                removeCurShow()
            }
        }else{
            removeCurShow()
        }
        //单纯点击了隐藏,不想看的情况
        if act == false {
            delegate?.clickDismiss?()
        }
    }
    
    
    //点击活动
    @objc private func clickActivity(){
        //跳转链接
        delegate?.clickActivity(curModel.link);
        //有跳转的关闭
        closeActivity(act: true);
    }
    
    
    //点击消失
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        if curModel.touchDismiss {
            let touch = ((touches as NSSet).anyObject() as AnyObject);
            let point = touch.location(in: self);
            let rect = mainImgV.frame;
            let contains = rect.contains(point);
            if contains == false {
                closeActivity(act: false);
            }
        }
    }
    
}



//活动数据模型
class ActivityModel:NSObject{
    
    public var id:String!
    public var imgUrl:String!               //图片地址 例如 1.png/http:// 本地或者远程
    public var link:String!                 //点击图片对应跳转的链接
    
    public var ignoreWindow:Bool = false                                      //当有弹窗时是否继续
    public var touchDismiss:Bool = false                                      //点击图片之外的范围消失
    
    public var closePosition:ClosePosition = .RightCorner                     //关闭按钮的位置样式
    public var offset:CGSize = CGSize(width: 0, height: 0)                    //关闭按钮对于关键点(右上角/下中心)的偏移
    public var closeBtnImg = UIImage.name("navi_close_ex")                    //关闭按钮用的图片
    public var maskColor:UIColor = UIColor.colorHexValue("000000", alpha: 0.3)//遮罩背景色
    public var animateDuration:TimeInterval = 0.3                             //最小值0.3s
    
    public var imgWidth:CGFloat?            //设计图上的宽度-375屏幕宽度时的值,高度按比例计算
    public var imgPlaceHolder:UIImage?      //加载图片时的占位图
    public var targetPoint:CGPoint?         //关闭时运动到该点
    public var focusView:UIView?            //当前视图是该视图才显示
    
}
