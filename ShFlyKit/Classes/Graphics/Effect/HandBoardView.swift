//
//  HandBoardView.swift
//  SHKit
//
//  Created by hsh on 2020/1/9.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import Masonry


//手写板-涂鸦,白板
public class HandBoardView: UIView {
    //Variable
    public var painColor:UIColor = .black           //涂鸦颜色
    public var painLineWidth:CGFloat = 2            //涂鸦线宽
    //Private
    private var paths:[PainPathContent] = []        //所有路径
    private var curPath:PainPathContent!            //当前绘制的路径
    private var tmpImage:UIImage?                   //路径绘制完成后的混合图
    private var lastColor:UIColor!                  //上一次的颜色
    private var reBack:Bool = false                 //是否在撤销
    
    
    ///Interface
    //获取当前最终混合图
    public func getFinalImage()->UIImage?{
        generateSnapImage();
        return tmpImage;
    }
    
    
    //撤销一步
    public func undoPain(){
        reBack = true;
        self.setNeedsDisplay();
        generateSnapImage()
    }
    
    
    //撤销所有
    public func undoAll(){
        reBack = true;
        paths.removeAll();
        self.setNeedsDisplay();
        generateSnapImage();
    }
    
    
    //设置为擦除模式
    public func erasePain(){
        lastColor = painColor;
        painColor = .clear;
    }
    
    
    //恢复最近的笔颜色
    public func restorePainColor(){
        if lastColor != nil {
            painColor = lastColor;
        }
    }
    
    
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        self.backgroundColor = .clear;
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        //创建路径
        let path = PainPathContent()
        path.path.lineWidth = painLineWidth;
        path.color = painColor;
        path.path.move(to: point);
        //保存路径
        paths.append(path);
        curPath = path;
        reBack = false;
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        let previous = touch.previousLocation(in: self);
        let mid = midPoint(of: previous, point2: point);
        //路径加点
        curPath.path.addQuadCurve(to: mid, controlPoint: previous);
        
        self.setNeedsDisplay();
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        let previous = touch.previousLocation(in: self);
        
        curPath.path.addQuadCurve(to: point, controlPoint: previous);
        self.setNeedsDisplay();
        //生产最后的临时图片
        generateSnapImage();
    }
    
    
    //生成截图
    private func generateSnapImage(){
        tmpImage = self.normalSnapshotImage();
    }
    
    
    public override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        //完成一次绘制
        func strokePaths(path:PainPathContent){
            path.color.setStroke();
            //橡皮檫还是画笔
            if path.color == UIColor.clear {
                ctx?.setBlendMode(.clear);
            }else{
                ctx?.setBlendMode(.normal);
            }
            path.path.stroke();
        }
        //撤销模式
        if reBack {
            if paths.count > 0 {
                //撤销当前一步
                paths.removeLast();
                for path in paths{
                    strokePaths(path: path);
                }
            }
        }else{
            //绘入上一次的结果
            if tmpImage != nil {
                tmpImage!.draw(at: .zero);
            }
            //当前路径
            if curPath != nil {
                strokePaths(path: curPath);
            }
        }
        super.draw(rect);
    }
    
    
}



//手写板混合背景图片
public class HandBoardMixImageView: UIView {
    //Variable
    public private(set) var imageV = UIImageView()      //背景图片
    public private(set) var handBoard:HandBoardView!    //涂鸦板
    
    
    //设置图片
    public func setOriginImage(image:UIImage){
        //添加照片视图
        if imageV.superview == nil {
            self.addSubview(imageV);
            imageV.mas_makeConstraints { (make) in
                make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
            }
        }
        //涂鸦板
        if handBoard == nil {
            handBoard = HandBoardView()
            self.addSubview(handBoard);
            handBoard.mas_makeConstraints { (make) in
                make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
            }
        }
        imageV.image = image;
    }
    
    
    //混合输出照片
    public func generateMixImage()->UIImage?{
        let image1 = imageV.image;
        let image2 = handBoard.getFinalImage();
        //混合
        if image1 != nil {
            image1?.draw(at: .zero);
        }
        if image2 != nil {
            image2?.draw(at: .zero);
        }
        //输出图片
        let result = self.normalSnapshotImage();
        return result;
    }
    
    
}




///路径信息
public class PainPathContent:NSObject{
    public var path:UIBezierPath = UIBezierPath()
    public var color:UIColor!
}
