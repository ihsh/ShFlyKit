//
//  BubbleMenu.swift
//  SHKit
//
//  Created by hsh on 2019/12/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//菜单的位置
enum MenuDirection {
    case TopLeft,TopRight,BottemLeft,BottomRight
}


protocol BubbleMenuDelegate:NSObjectProtocol {
    func menuSelect(index:Int,title:String)
}


///下拉菜单
class BubbleMenu: UIView {
    //Variable
    public weak var delegate:BubbleMenuDelegate?
    public var itemH:CGFloat = 50                           //单元格高度
    public var menuW:CGFloat = 150                          //菜单视图的宽度
    public var topDis:CGFloat = 60                          //菜单顶部距离起始点的距离
    public var edgeStart:CGFloat = 20                       //起点往最近的屏幕边缘的X偏移
    public var backColor:UIColor = .clear                   //整体的背景色
    public var menuColor:UIColor = .white                   //菜单与箭头的背景色
    public var textColor:UIColor = .black                   //菜单文字颜色
    public var textFont:UIFont = kFont(14)                  //菜单文字字号
    public var iconTextMargin:CGFloat = 10                  //图片与文字间距
    public var iconLeftMargin:CGFloat = 16                  //图片距左间距
    public var direction:MenuDirection = .TopRight          //展开样式
    public var animate:Bool = true                          //是否动画展开关闭
    //Private
    public private(set) var menuV:UIView!
    private var startPos:CGPoint!                           //起点-点击的点传入
    private var items:[String]!                             //传入的文字
    private var arrowLayer:CAShapeLayer!                    //箭头图层
    private var animateStart:CGRect!                        //动画起点坐标
    
    
    ///初始化
    public func initMenu(_ titles:[String],images:[UIImage]? = nil,startPos:CGPoint){
        //保存
        self.startPos = startPos;
        self.items = titles;
        //创建菜单视图
        menuV = UIView()
        menuV.backgroundColor = menuColor;
        menuV.layer.cornerRadius = 5;
        menuV.layer.masksToBounds = true;
        //添加文本
        for (index,str) in titles.enumerated() {
            let label = UILabel.initText(str, font: textFont, textColor: textColor, alignment: .center, super: menuV);
            label.mas_makeConstraints { (make) in
                make?.height.mas_equalTo()(itemH);
                make?.top.mas_equalTo()(menuV)?.offset()(itemH*CGFloat(index));
                make?.centerX.mas_equalTo()(menuV);
            }
            let image:UIImage? = images?[index < images!.count ? index : 0];
            if image != nil {
                let imageV = UIImageView.init(image: image);
                imageV.contentMode = .scaleAspectFit;
                menuV.addSubview(imageV);
                imageV.mas_makeConstraints { (make) in
                    make?.height.mas_equalTo()(itemH);
                    make?.top.mas_equalTo()(menuV)?.offset()(itemH*CGFloat(index));
                    make?.left.mas_equalTo()(menuV)?.offset()(iconLeftMargin);
                }
                label.mas_remakeConstraints { (make) in
                    make?.centerY.mas_equalTo()(imageV);
                    make?.left.mas_equalTo()(imageV.mas_right)?.offset()(iconTextMargin);
                }
                label.textAlignment = .left;
            }
        }
        //箭头
        arrowLayer = CAShapeLayer()
        arrowLayer.bounds = self.bounds;
        arrowLayer.fillColor = menuColor.cgColor;
        arrowLayer.lineJoin = kCALineJoinRound;
        //路径
        let path = CGMutablePath();
        if direction == .TopLeft || direction == .TopRight {
            path.move(to: CGPoint(x: startPos.x - 10, y: startPos.y + topDis));
            path.addLine(to: CGPoint(x: startPos.x + 10, y: startPos.y + topDis));
            path.addLine(to: CGPoint(x: startPos.x, y: startPos.y + topDis - 10));
            path.addLine(to: CGPoint(x: startPos.x - 10, y: startPos.y + topDis));
        }else{
            path.move(to: CGPoint(x: startPos.x - 10, y: startPos.y - topDis));
            path.addLine(to: CGPoint(x: startPos.x + 10, y: startPos.y - topDis));
            path.addLine(to: CGPoint(x: startPos.x, y: startPos.y - topDis + 10));
            path.addLine(to: CGPoint(x: startPos.x - 10, y: startPos.y - topDis));
        }
        arrowLayer.path = path;
        self.layer.addSublayer(arrowLayer);
    }
    
    
    //展开显示
    public func showMenu(){
        //当前视图所在位置
        self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        self.backgroundColor = backColor;
        let window:UIWindow = UIApplication.shared.delegate!.window!!;
        window.addSubview(self);
        //菜单视图
        self.addSubview(menuV);
        let menuHeight:CGFloat = CGFloat(items.count)*itemH;
        var endFrame:CGRect!
        switch self.direction {
        case .TopLeft:
            animateStart = CGRect(x: startPos.x - edgeStart, y: startPos.y + topDis, width: 0, height: 0);
            endFrame = CGRect(x: startPos.x - edgeStart, y: startPos.y + topDis, width: menuW, height: menuHeight);
        case .TopRight:
            animateStart = CGRect(x: startPos.x + edgeStart, y: startPos.y + topDis, width: 0, height: 0);
            endFrame = CGRect(x: startPos.x + edgeStart - menuW, y: startPos.y + topDis, width: menuW, height: menuHeight);
        case .BottemLeft:
            animateStart = CGRect(x: startPos.x - edgeStart, y: startPos.y - topDis, width: 0, height: 0);
            endFrame = CGRect(x: startPos.x - edgeStart, y: startPos.y - topDis - menuHeight, width: menuW, height: menuHeight);
        case .BottomRight:
            animateStart = CGRect(x: startPos.x + edgeStart, y: startPos.y - topDis, width: 0, height: 0);
            endFrame = CGRect(x: startPos.x + edgeStart - menuW, y: startPos.y - topDis - menuHeight, width: menuW, height: menuHeight);
        }
        //动画
        self.menuV.frame = animateStart;
        self.menuV.alpha = 0;
        if animate == true {
            UIView.animate(withDuration: 0.3) {
                self.menuV.frame = endFrame;
                self.menuV.alpha = 1;
            }
        }else{
            self.menuV.frame = endFrame;
            self.menuV.alpha = 1;
        }
    }
    
    
    //隐藏收缩
    public func disMiss(){
        if animate == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.menuV.frame = self.animateStart;
                self.menuV.alpha = 0;
            }) { (_) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.menuV.removeFromSuperview();
                    self.removeFromSuperview();
                }
            }
        }else{
            self.menuV.frame = self.animateStart;
            self.menuV.alpha = 0;
            self.menuV.removeFromSuperview();
            self.removeFromSuperview();
        }
    }
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event);
        //如果点击在当前视图，则透过到下层
        if hitView?.isKind(of: type(of: self)) ?? false {
            return nil;
        }else{
            //在当前视图内
            disMiss()
            let pos = self.convert(point, to: menuV);
            let index:Int = Int(floor(pos.y / itemH));
            let name = items[index];
            delegate?.menuSelect(index: index, title: name);
        }
        return hitView;
    }
    

}
