//
//  MetrolLineV.swift
//  SHKit
//
//  Created by hsh on 2019/8/21.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


//地铁线路图
public class MetrolLineV: UIView , UIScrollViewDelegate , CAAnimationDelegate ,LineDataSource{
    //Variable
    private var scrollV:UIScrollView!               //滚动视图
    private var lineImageV:UIImageView!             //展示的图片
    private var imageRect:CGRect!                   //图片的尺寸
   
    private var views:[UIView] = []                 //视图数组
    private var drawPaths:[CAShapeLayer] = []       //绘制的路径
    private var start:DotInfo!                      //起点
    private var end:DotInfo!                        //终点
    private var rate:CGFloat = 0                    //与6的屏幕比例
    private var animateIndex:Int = 0                //当前动画下标
    private var results:[PlanInfo] = []             //路径计划
    
    
    //加载地铁线路图
    public func loadLine(img:UIImage){
        self.backgroundColor = UIColor.white;
        //填充整个视图
        scrollV = UIScrollView()
        scrollV.maximumZoomScale = 8;
        scrollV.minimumZoomScale = 1;
        scrollV.delegate = self;
        self.addSubview(scrollV);
        scrollV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        //获取图片的宽高
        let imgWidth = img.width();
        let imgHeight = img.height();
        //实际能显示的屏幕高度
        let height = ScreenSize().height-NavgationBarHeight()-StatusBarHeight()-ScreenBottomInset();
        //对应图片比例的宽度
        let width = imgWidth * height / imgHeight;
        //最终的显示区域
        imageRect = CGRect(x: 0, y: 0, width: width, height: height);
        //图片
        lineImageV = UIImageView.init(frame: imageRect);
        lineImageV.image = img;
        lineImageV.isUserInteractionEnabled = true;
        lineImageV.contentMode = .scaleAspectFit;
        scrollV.addSubview(lineImageV);
        scrollV.contentSize = CGSize(width: width, height: 0);
        //点击手势
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction));
        lineImageV.addGestureRecognizer(tap);
        //加载线路
        LineStaionV.shared.readFromPlist(name: "line")
        LineStaionV.shared.delegate = self;
        LineStaionV.shared.limit = 7;
    }
   
    
    //需要放大的图片
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return lineImageV;
    }
    
    
    //转换坐标
    private func convertPoint(_ dot:DotInfo,rate:CGFloat)->CGPoint{
        return CGPoint(x: dot.point.x * rate, y: dot.point.y * rate);
    }
    
    
    //点击的手势
    @objc private func tapAction(tap:UITapGestureRecognizer){
        let point = tap.location(in: lineImageV);
        //实际的屏幕与录屏的点的比例
        rate = imageRect.height / 603;
        let pointNew = CGPoint(x: point.x/rate, y:point.y/rate);
        //按比例缩小点
        let dot = LineStaionV.shared.getStation(pointNew);
        if dot != nil{
            if start == nil{
                start = dot;
                self.createLocName(start: true, point:convertPoint(start, rate: rate));
            }else if end == nil{
                self.createLocName(start: false, point: convertPoint(dot!, rate: rate));
                end = dot;
                LineStaionV.shared.getLinePlan(start.name, endName: end.name);
            }
        }else{
            if start != nil && end != nil{
                removeLocs();
            }
        }
    }
    
    
    //异步返回路线规划
    public func returnDataAsync(_ plans: [PlanInfo]) {
        results.removeAll();
        animateIndex = 0;
        results.append(contentsOf: plans);
        //开启下一个动画
        animationDidStop(CAAnimation(), finished: true);
    }
    
    
    //一个动画结束
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            DispatchQueue.main.async {
                if self.animateIndex <= self.results.count - 1 && self.start != nil && self.end != nil{
                    let plan = self.results[self.animateIndex];
                    print(plan.stations);
                    self.drawLine(plan, i: self.animateIndex);
                    self.animateIndex += 1;
                }
            }
        }
    }
    
    
    //绘制动画
    func drawLine(_ value:PlanInfo,i:Int) {
        //绘制动画
        let path = UIBezierPath()
        path.move(to: convertPoint(value.start, rate: rate));
        for sum in value.roads{
            for po in sum.points{
                path.addLine(to: convertPoint(po, rate: rate));
            }
        }
        //生产layer
        let layer = CAShapeLayer()
        layer.frame = self.lineImageV.bounds;
        layer.path = path.cgPath;
        layer.strokeColor = UIColor.rainbowColor(i).cgColor;
        layer.fillColor = UIColor.clear.cgColor;
        layer.lineWidth = CGFloat(9-CGFloat(i));
        layer.lineJoin = kCALineCapRound;
        layer.lineCap = kCALineCapRound;
        //添加动画
        let animate = CABasicAnimation(keyPath: "strokeEnd");
        animate.delegate = self;
        animate.duration = Double(value.stations.count) * 0.3;
        animate.fromValue = 0;
        animate.toValue = 1;
        layer.add(animate, forKey: "strokeEnd");
        //将轨道添加到视图层中
        let view = views.first;
        self.lineImageV.layer.insertSublayer(layer, below: view?.layer);
        self.drawPaths.append(layer);
    }
    
    
    //添加文字
    private func createLocName(start:Bool,point:CGPoint){
        let view = UIView()
        view.backgroundColor = start == true ? UIColor.colorRGB(red: 238, green: 28, blue: 37) : UIColor.colorRGB(red: 26, green: 178, blue: 10);
        view.center = point;
        let label = UILabel.initText(start ? "起" : "终", font: kFont(8), textColor: UIColor.white, alignment: .center, super: view);
        view.bounds = CGRect(x: 0, y: 0, width: 20, height: 20);
        view.layer.cornerRadius = 10;
        view.layer.masksToBounds = true;
        label.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(view);
        }
        lineImageV.addSubview(view);
        views.append(view);
    }
    
    
    //移除
    private func removeLocs(){
        start = nil;
        end = nil;
        animateIndex = 0;
        //移除视图
        for sub in views{
            sub.removeFromSuperview();
        }
        views.removeAll();
        //移除路径
        for layer in drawPaths{
            layer.removeFromSuperlayer();
        }
        drawPaths.removeAll();
    }
    
    
}
