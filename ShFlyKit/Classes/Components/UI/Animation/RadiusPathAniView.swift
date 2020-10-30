//
//  RadiusPathAniBtn.swift
//  SHKit
//
//  Created by hsh on 2020/5/6.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import QuartzCore


public protocol RadiusPathAniViewDelegate:NSObjectProtocol {
    //选中了某个下标
    func itemTapIndex(_ index:NSInteger);
}


///展示半径径向展开的动画
public class RadiusPathAniView: UIView,RadiusCenterBtnDelegate,RadiusPathBtnDelegate {
    //Variable
    public weak var delegate:RadiusPathAniViewDelegate?         //代理对象
    public var bloomRadius:CGFloat = 105                        //半径
    public var bloomSize:CGSize!                                //放大的区域
    public var foldCenterXoffset:CGFloat = 0                    //收缩点X的偏移
    public var foldCenterYoffset:CGFloat = -225                 //收缩点Y的偏移
    public var maskColor:UIColor = .black                       //遮罩颜色
    //Variable
    private var isBloom:Bool = false                            //当前状态
    private var foldedSize:CGSize!                              //收缩的大小
    private var foldedCenter:CGPoint!                           //收缩的中心
    private var itemBottons:[RadiusPathBtn] = []                //按钮群
    private var pathBloomCenter:CGPoint!                        //放大的中心
    private var bottomView:UIView!                              //遮罩
    private var centerBtn:RadiusCenterBtn!                      //中心按钮
    
    
    ///Interface
    public func initCenterImg(center:UIImage,hight:UIImage){
        
        //收缩状态的大小就是图片的大小
        self.foldedSize = center.size;
        //没有指定大小，放大的大小就是全屏
        if bloomSize == nil {
            self.bloomSize = UIScreen.main.bounds.size;
        }
        //坐标
        self.foldedCenter = CGPoint(x:self.bloomSize.width/2.0 + foldCenterXoffset,y:self.bloomSize.height + foldCenterYoffset);
        self.frame = CGRect(x:0,y:0,width:self.foldedSize.width,height:self.foldedSize.height);
        self.center = self.foldedCenter;
        //中间按钮
        self.centerBtn = RadiusCenterBtn.init(image: center, highlightedImage: hight);
        self.centerBtn.center = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0);
        self.centerBtn.delegate = self;
        self.addSubview(centerBtn);
        //遮罩
        self.bottomView = UIView();
        self.bottomView.frame = CGRect(x: 0, y: 0, width: self.bloomSize.width, height: self.bloomSize.height);
        self.bottomView.backgroundColor = UIColor.black;
        self.bottomView.alpha = 0;
    }
    
    
    //添加按钮
    public func addPathItem(norName:String,hight:String,backImg:String,hightBack:String){
        let btn = RadiusPathBtn();
        btn.initWith(img: UIImage.name(norName), hight: UIImage.name(hight), backImg: UIImage.name(backImg), backHightImg: UIImage.name(hightBack));
        btn.delegate = self;
        self.itemBottons.append(btn);
    }
    
    
    
    //Delegate
    //中间按钮点击
    public func centerBtnTapped() {
        if self.isBloom {
            self.pathCenterFold()
        }else{
            self.pathCenterBloom();
        }
    }
    
    
    //按钮点击
    public func itemBtnTap(btn: RadiusPathBtn) {

        let senderBtn = self.itemBottons[btn.tag];
        //选中的按钮放大和消失
        UIView.animate(withDuration: 0.0618*5) {
            senderBtn.transform = CGAffineTransform(scaleX: 3, y: 3);
            senderBtn.alpha = 0;
        }
        //未选中的恢复鸳鸯
        for (i,unBtn) in self.itemBottons.enumerated() {
            if i == senderBtn.tag {
                continue;
            }
            UIView.animate(withDuration: 0.0618*2) {
                unBtn.transform = CGAffineTransform(scaleX: 0, y: 0);
            }
        }
        delegate?.itemTapIndex(senderBtn.tag);
        //恢复原样
        self.resizeToFoldedFrame();
    }
    
    
    //收回
    private func pathCenterFold(){
        for (i,item) in self.itemBottons.enumerated() {
            let curAngel:CGFloat = CGFloat(i+1)/(CGFloat(self.itemBottons.count)+1.0);
            let farPoint:CGPoint = self.createEndPointWith(radius: self.bloomRadius + 5.0, angel: curAngel);
            let foldAni = self.foldAnimationFromPos(end: item.center, farPos: farPoint);
            item.layer.add(foldAni, forKey: "foldAnimation");
            item.center = self.pathBloomCenter;
        }
        self.bringSubview(toFront: self.centerBtn);
        self.resizeToFoldedFrame();
    }
    
    
    //收回的动画
    private func foldAnimationFromPos(end:CGPoint,farPos:CGPoint)->CAAnimationGroup{
        //旋转
        let rotateAnim = CAKeyframeAnimation.init(keyPath: "transform.rotation.z");
        rotateAnim.values = [0,Double.pi,Double.pi * 2];
        rotateAnim.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear);
        rotateAnim.duration = 0.35;
        //路径
        let path = CGMutablePath()
        path.move(to: end);
        path.addLine(to: farPos);
        path.addLine(to: self.pathBloomCenter);
        //移动
        let moveAnim = CAKeyframeAnimation.init(keyPath: "position");
        moveAnim.keyTimes = [NSNumber.init(value: 0.0),NSNumber.init(value: 0.75),NSNumber.init(value: 1.0)];
        moveAnim.path = path;
        moveAnim.duration = 0.35;
        //动画组
        let group = CAAnimationGroup()
        group.animations = [rotateAnim,moveAnim];
        group.duration = 0.35;
        return group;
    }
    
    
    //恢复原样
    private func resizeToFoldedFrame(){
        //按钮恢复
        UIView.animate(withDuration: 0.0618*3, delay: 0.0618*2, options: .curveEaseIn, animations: {
            self.centerBtn.transform = CGAffineTransform.identity;
        }, completion: nil);
        //遮罩隐藏
        UIView.animate(withDuration: 0.1, delay: 0.35, options: .curveLinear, animations: {
            self.bottomView.alpha = 0;
        }, completion: nil);
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
            for btn in self.itemBottons{
                btn.removeFromSuperview();
            }
            self.frame = CGRect(x: 0, y: 0, width: self.foldedSize.width, height: self.foldedSize.height);
            self.center = self.foldedCenter;
            self.centerBtn.center = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0);
            self.bottomView.removeFromSuperview();
        }
        self.isBloom = false;
    }
    
    
    //展开
    private func pathCenterBloom(){
        
        self.pathBloomCenter = self.center;
        //更新坐标
        self.frame = CGRect(x: 0, y: 0, width: self.bloomSize.width, height: self.bloomSize.height);
        self.center = CGPoint(x: self.bloomSize.width/2.0, y: self.bloomSize.height/2.0);
        //插入遮罩
        self.insertSubview(self.bottomView, belowSubview: self.centerBtn);
        //遮罩
        UIView.animate(withDuration: 0.0618*3, delay: 0, options: .curveEaseIn, animations: {
            self.bottomView.alpha = 0.618;
        }, completion: nil);
        //中心按钮旋转一定角度
        UIView.animate(withDuration: 0.1575) {
            self.centerBtn.transform = CGAffineTransform(rotationAngle: CGFloat(-0.75*Double.pi));
        }
        //中心按钮复位
        self.centerBtn.center = self.pathBloomCenter;
        
        let basicAngel = 180.0/CGFloat(self.itemBottons.count+1);
        
        for (i,item) in self.itemBottons.enumerated() {
            item.tag = i;
            item.transform = CGAffineTransform(translationX: 1, y: 1);
            item.alpha = 1;
            let curAngel = (basicAngel * CGFloat(i+1))/180.0;
            item.center = self.pathBloomCenter;
            self.insertSubview(item, belowSubview: self.centerBtn);
            //三个点
            let endPos = self.createEndPointWith(radius: self.bloomRadius, angel: curAngel);
            let farPos = self.createEndPointWith(radius: self.bloomRadius + 10.0, angel: curAngel);
            let nearPos = self.createEndPointWith(radius: self.bloomRadius - 5.0, angel: curAngel);
            //根据路径添加动画组
            let bloomAnimation = self.bloomAnimationWith(end: endPos, farpos: farPos, near: nearPos);
            item.layer.add(bloomAnimation, forKey: "bloomAnimation");
            item.center = endPos;
        }
        self.isBloom = true;
    }
    
    
    //展开的动画组
    private func bloomAnimationWith(end:CGPoint,farpos:CGPoint,near:CGPoint)->CAAnimationGroup{
        //旋转
        let rotateAnim = CAKeyframeAnimation.init(keyPath: "transform.rotation.z");
        rotateAnim.values = [0,-Double.pi,-Double.pi * 1.5,-Double.pi*2];
        rotateAnim.duration = 0.3;
        rotateAnim.keyTimes = [NSNumber.init(value: 0),NSNumber.init(value: 0.3),NSNumber.init(value: 0.6),NSNumber.init(value: 1)];
        //路径
        let path = CGMutablePath()
        path.move(to: self.pathBloomCenter);
        path.addLine(to: farpos);
        path.addLine(to: near);
        path.addLine(to: end);
        //移动
        let moveAnim = CAKeyframeAnimation.init(keyPath: "position");
        moveAnim.path = path;
        moveAnim.keyTimes = [NSNumber.init(value: 0),NSNumber.init(value: 0.5),NSNumber.init(value: 0.7),NSNumber.init(value: 1)];
        moveAnim.duration = 0.3;
        //动画组
        let group = CAAnimationGroup()
        group.animations = [rotateAnim,moveAnim];
        moveAnim.duration = 0.3;
        return group;
    }
    
    
    //生成点
    private func createEndPointWith(radius:CGFloat,angel:CGFloat)->CGPoint{
        return CGPoint(x: self.pathBloomCenter.x - CGFloat(cosf(Float(angel) * Float(Double.pi))) * radius,
                       y: self.pathBloomCenter.y - CGFloat(sinf(Float(angel) * Float(Double.pi))) * radius);
    }
    

}





public protocol RadiusPathBtnDelegate:NSObjectProtocol {
    func itemBtnTap(btn:RadiusPathBtn);
}


//自定义的展开按钮
public class RadiusPathBtn:UIImageView{
    //Variable
    public weak var delegate:RadiusPathBtnDelegate?
    private var frontImg:UIImageView!                  //最上层的图片
    
    
    //Load
    public func initWith(img:UIImage,hight:UIImage,backImg:UIImage?,backHightImg:UIImage?){
        //获取背景或者图片的尺寸
        var itemFrame = CGRect(x: 0, y: 0, width: backImg?.size.width ?? 0, height: backImg?.size.height ?? 0);
        if backImg == nil || backHightImg == nil {
            itemFrame = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height);
        }
        self.frame = itemFrame;
        self.image = backImg;   //self是背景图
        self.highlightedImage = backHightImg;
        self.isUserInteractionEnabled = true;
        //front盖在背景图上
        self.frontImg = UIImageView.init(image: img, highlightedImage: hight);
        self.frontImg.center = CGPoint(x: self.bounds.size.width/2.0, y: self.bounds.size.height/2.0);
        self.addSubview(self.frontImg);
    }
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHighlighted = false;
        self.frontImg.isHighlighted = true;
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = ((touches as NSSet).anyObject() as AnyObject)
        let curPoint = touch.location(in: self);
        let rect = self.scaleRect(origin: self.bounds);
        //当前是否选中
        if rect.contains(curPoint) == false {
            self.isHighlighted = false;
            self.frontImg.isHighlighted = false;
            return;
        }
        self.isHighlighted = true;
        self.frontImg.isHighlighted = true;
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.itemBtnTap(btn: self);
        self.isHighlighted = false;
        self.frontImg.isHighlighted = false;
    }
    
    
    private func scaleRect(origin:CGRect)->CGRect{
        return CGRect(x: -origin.size.width/2.0, y: -origin.size.height/2.0, width: origin.size.width*5, height: origin.size.height*5);
    }
    
}






public protocol RadiusCenterBtnDelegate:NSObjectProtocol {
    func centerBtnTapped();
}


//中间按钮
public class RadiusCenterBtn: UIImageView {
    public weak var delegate:RadiusCenterBtnDelegate?
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage);
        self.isUserInteractionEnabled = true;
        self.image = image;
        self.highlightedImage = highlightedImage;
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func scaleRect(origin:CGRect)->CGRect{
        return CGRect(x: -origin.size.width/2.0, y: -origin.size.height/2.0, width: origin.size.width*5, height: origin.size.height*5);
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHighlighted = true;
        delegate?.centerBtnTapped();
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = ((touches as NSSet).anyObject() as AnyObject)
        let curPoint = touch.location(in: self);
        let rect = self.scaleRect(origin: self.bounds);
        if rect.contains(curPoint) == false {
            self.isHighlighted = false;
            return;
        }
        self.isHighlighted = true;
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHighlighted = false;
    }
    
}
