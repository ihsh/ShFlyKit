//
//  AnimateItemView.swift
//  SHKit
//
//  Created by hsh on 2019/4/22.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//外部代理方法
public protocol AnimateItemViewDelegate:NSObjectProtocol {
    //更改高度
    func changeHeight(_ height:CGFloat,obj:AnimateItemView)
    //非编辑状态下点击的下标
    func didSelectIndex(_ index:NSInteger)
}


//内部使用代理方法(另一个代理是本类)
public protocol AnimateItemViewDataSource:NSObjectProtocol {
    //移除当前界面的元素到代理视图中去
    func transforToDelegateView(item:AnimateItemFrame)
}


///增删减项目动画
public class AnimateItemView: UIView,AnimateItemViewDataSource {
    //Variable
    public weak var delegate:AnimateItemViewDelegate?               //UI代理
    public weak var dataSource:AnimateItemViewDataSource?           //数据代理
    private var items:[AnimateItemFrame] = []                       //数据
    private var viewHeight:CGFloat = 0                              //视图本身的高度
    private var moveView:AnimateItemFrame!                          //长按后可移动的视图模型
    private var isTap:Bool = true                                   //是否是点击事件，否为滑动事件
    private var isEdit:Bool = true                                  //是否可编辑
    //配置项
    public var maxColumn:NSInteger = 4                              //最大列数
    public var itemHeight:CGFloat = 30                              //一行的高度
    public var xMargin:CGFloat = 10                                 //X方向上的间距
    public var yMargin:CGFloat = 10                                 //Y方向上的间距
    public var xSpan:CGFloat = 16                                   //X方向上距离屏幕的间距
    public var ySpan:CGFloat = 10                                   //Y轴的起点间距
    public var cornerRadius:CGFloat = 15                            //圆角值
    public var borderWidth:CGFloat = 0.5                            //边线宽度
    public var textFont:UIFont = kFont(14)                          //文字大小
    public var textColor = UIColor.colorHexValue("212121")          //文字颜色
    public var borderColor = UIColor.colorRGB(red: 97, green: 170, blue: 248)//线圈颜色
    public var constraintUpView:UIView?                             //约束的.top的上一个视图
    
    
    
    ///Interface
    public func loadItems(_ items:[String]){
        //移除已经有的视图
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
        var step:NSInteger = 0;
        for text in items {
            let frame = calculFrame(index: step);                   //计算在当前视图上的坐标
            
            let label = UILabel()
            label.frame = frame;
            label.text = text;
            label.isUserInteractionEnabled = true;
            label.textAlignment = .center;
            label.textColor = textColor;
            label.layer.masksToBounds = true;
            label.layer.borderWidth = borderWidth;
            label.layer.cornerRadius = cornerRadius;
            label.font = textFont;
            label.layer.borderColor = borderColor.cgColor;
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTouch(tap:))));
            self.addSubview(label);
            
            let model:AnimateItemFrame = AnimateItemFrame()
            model.text = text;
            model.originFrame = frame;                          //初始坐标
            model.index = step;                                 //对应下标值
            model.label = label;
            model.label.tag = step;                             //手势点击时取用
            self.items.append(model);
            
            step += 1;
        }
        refreshAnimate(false)
    }

    
    //是否可编辑
    public func enableEdit(_ enable:Bool){
        isEdit = enable;
    }
    
    
    //返回所有数据
    public func getAllItems()->[AnimateItemFrame]{
        return self.items;
    }
    
    
    //从上个视图移除，添加到新的视图
    public func transforToDelegateView(item: AnimateItemFrame) {
        //数据添加到代理视图中去
        item.index = self.items.count;
        self.items.append(item);
        //更新点击事件为新的视图上,self为l另一个视图
        item.label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTouch(tap:))));
        self.addSubview(item.label);
        //按大小排序
        items.sort { (obj1, obj2) -> Bool in
            return obj1.index < obj2.index;
        }
        refreshAnimate(false)
    }
    
    
    
    //Private Method
    //触摸点击的处理回调
    public func indexOfTouch(_ touches: Set<UITouch>,block:((_ index:NSInteger,_ item:AnimateItemFrame)->Void)){
        let touch = ((touches as NSSet).anyObject() as AnyObject)
        let point = touch.location(in: self)
        for (index,item) in self.items.enumerated() {
            let frame = calculFrame(index: index);
            if (point.x > frame.origin.x && point.x < (frame.origin.x + frame.size.width + xMargin)) &&
                (point.y > frame.origin.y && (point.y < frame.origin.y + frame.size.height + yMargin)){
                block(index,item);
            }
        }
    }
    
    
    //移动操作
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event);
        if isEdit == true{
            indexOfTouch(touches) { (index, item) in
                moveView = item;
            }
        }
        isTap = true;
    }
    
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event);
        isTap = false;
        if moveView != nil {
            let touch = ((touches as NSSet).anyObject() as AnyObject)
            let point = touch.location(in: self)
            //当前的下标
            indexOfTouch(touches) { (touchIndex, item) in
                //跟着移动
                moveView.label.center = point;
                //获取临时模型
                let tmp = getFrameModel(index: touchIndex);
                if (tmp.index != touchIndex){
                    //移动临时模型的下标
                    tmp.index = touchIndex;
                    items.sort { (obj1, obj2) -> Bool in
                        return obj1.index <= obj2.index;
                    }
                    refreshAnimate(true);
                }
            }
        }
    }
    
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        //获取当前下标
        if moveView != nil {
            var ended:Bool = false;
            indexOfTouch(touches) { (index, item) in
                ended = true;
                endMove(index: index);
            }
            if ended == false{
                endMove(index: moveView.index);
            }
        }
    }
    
    
    private func endMove(index:NSInteger){
        UIView.animate(withDuration: 0.3, animations: {
            self.moveView?.label.frame = self.calculFrame(index: index);
        })
        for (_,value) in items.enumerated() {
            value.dashLabel?.removeFromSuperview();
            value.dashLabel = nil;
        }
        moveView = nil;
        refreshAnimate(true);
    }
    
    
    //手势点击调用方法
    @objc private func tapGestureTouch(tap:UITapGestureRecognizer){
        //手势点击所在的父视图
        let view = tap.view;
        if view != nil {
            let index:NSInteger = view!.tag;                    //这个视图，即label的tag
            if isTap == false {
                self.endMove(index: index);
                return;
            }
            let item = self.items[index];                       //取对应下标的模型
            let frame = item.label.frame;
            let itemSuperRect = item.label.superview?.frame;    //label的父视图的坐标
            //判断是在上还是下
            var isUp:Bool = true;
            var lastView:UIView?;
            var count:NSInteger = 0;
            for sub in self.superview!.subviews{
                //在父视图的子视图中寻找相同的AnimateItemView视图
                if (sub.isKind(of: AnimateItemView.self)){
                    //坐标Y值不同，就不是该视图
                    if (itemSuperRect?.origin.y) != sub.frame.origin.y{
                        lastView = sub;
                    }else{
                        if count > 0 {          //找到这个视图的时候，如果不是第一个，那它就不是在上面
                            isUp = false;
                        }
                    }
                    count += 1;
                }
            }
            //当有两个AnimateItemView视图，即使是在上面，循环也会继续,lastView不为nil
            if lastView == nil{
                return;
            }
            //计算从A视图移除后，在B视图的初始坐标
            var offset:CGFloat = 0;
            if isUp{
                let distance = fabs(itemSuperRect!.origin.y - lastView!.frame.origin.y);
                let distanceSub = fabs(distance - frame.origin.y);
                offset = -distanceSub;
            }else{
                let distance = fabs(itemSuperRect!.origin.y - lastView!.frame.origin.y);
                offset = frame.origin.y + distance;
            }
            item.animateFrame = CGRect(x: frame.origin.x, y: offset, width: frame.size.width, height: frame.size.height);
            self.click(index: index);
        }
    }
   
    
    //点击操作
    @objc private func click(index:NSInteger){
        var step:NSInteger = index;
        for (i,item) in items.enumerated() {
            if (i < index){
                //点击之前的保持不变
                item.targetFrame = item.originFrame;
            }else if (i == index){
                //点击的项从当前界面移除，并移除点击事件
                item.label.removeFromSuperview();
                item.label.removeGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(tapGestureTouch(tap:))));
                //代理视图加视图
                dataSource?.transforToDelegateView(item: item);
            }else{
                //下一个取前一个的坐标
                let tmp:AnimateItemFrame = items[step];
                item.targetFrame = tmp.originFrame;
                step += 1;
            }
        }
        //移除虚线框
        for item in self.items{
            item.dashLabel?.removeFromSuperview();
            item.dashLabel = nil;
        }
        //移除数据
        items.remove(at: index);
        refreshAnimate(true);
    }
    

    
    //刷新动画
    private func refreshAnimate(_ animate:Bool){
        //重排顺序,去掉了去除的下标
        for (index,value) in items.enumerated() {
            let frame = calculFrame(index: index);
            if animate == true{
                value.animateFrame = calculFrame(index: value.index);
            }
            value.targetFrame = frame;
            value.index = index;
            value.label.tag = index;
        }
        //动画
        for (_,item) in items.enumerated() {
            if (item.targetFrame != nil){
                //如果有动画起始坐标，就用动画的那个图标
                if item.animateFrame != nil{
                    item.label.frame = item.animateFrame;
                }
                //运动到目标坐标
                [UIView.animate(withDuration: 0.3, animations: {
                    if (item.targetFrame != nil) {
                        item.label.frame = item.targetFrame;
                    }
                    if (item.dashLabel != nil){
                        item.dashLabel.frame = item.targetFrame;
                    }
                }, completion: { (finish) in
                    item.originFrame = item.targetFrame;
                    item.targetFrame = nil;
                    item.animateFrame = nil;
                })];
            }
        }
        //计算高度
        let row:NSInteger = NSInteger(ceil(Double(items.count) / Double(maxColumn)));
        let height = CGFloat(row)*(itemHeight+yMargin)+ySpan;
        if height != self.viewHeight {
            delegate?.changeHeight(height, obj: self);
            self.viewHeight = height;
        }
    }
    
    
    
    //获取下标为index的坐标模型
    private func getFrameModel(index:NSInteger)->AnimateItemFrame{
        var result:AnimateItemFrame!
        for item in self.items {
            if item.dashLabel != nil{
                result = item;
                break;
            }
        }
        if result == nil {
            let label = UILabel()
            label.isUserInteractionEnabled = true;
            let frame = calculFrame(index: index);
            label.frame = frame;
            self.addSubview(label);
            //添加虚线边框
            let border = CAShapeLayer()
            border.strokeColor = textColor.cgColor;
            border.fillColor = UIColor.clear.cgColor;
            border.path = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: label.frame.size.width,
                                                                height: label.frame.size.height), cornerRadius: cornerRadius).cgPath;
            border.frame = CGRect(x: 0, y: 0, width: label.frame.size.width, height: label.frame.size.height);
            border.lineWidth = borderWidth;
            border.lineDashPattern = [NSNumber.init(value: 4),NSNumber.init(value: 2)];
            label.layer .addSublayer(border);
            
            let model = self.items[index];
            model.dashLabel = label;
            result = model;
        }
        return result;
    }
    
    
    
    //计算坐标
    private func calculFrame(index:NSInteger)->CGRect{
        let width:CGFloat = (ScreenSize().width - CGFloat(maxColumn-1) * xMargin - 2 * xSpan)/CGFloat(maxColumn);
        let row:NSInteger = index / maxColumn;
        let column:NSInteger = index % maxColumn;
        let frame = CGRect(x: CGFloat(column)*(width+xMargin)+xSpan, y: CGFloat(row)*(itemHeight+yMargin)+ySpan, width: width, height: itemHeight);
        return frame;
    }
    
    
}





//动画模型
public class AnimateItemFrame: NSObject {
    public var text:String!                     //文本
    public var originFrame:CGRect!              //原坐标
    public var targetFrame:CGRect!              //目标坐标
    public var animateFrame:CGRect!             //动画的起点坐标
    public var label:UILabel!                   //按钮
    public var dashLabel:UILabel!               //虚线的label
    public var index:NSInteger = 0              //下标
}
