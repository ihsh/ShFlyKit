//
//  LockCircleLayer.swift
//  SHKit
//
//  Created by hsh on 2018/10/24.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import QuartzCore


//密码圆圈类
public class LockCircleLayer: CALayer {
    // Variable
    public var highlighted:Bool = false                     //是否高亮-选中
    public var isError:Bool = false                         //是否错误
    public var showPath:Bool = true                         //是否显示路径
    public var passwordView:LockPasswordView!               //密码视图
    
    public var kLayerMargin:CGFloat = 2.0
    public var kDotHighlightedRadius:CGFloat = 4.0
    public var kBorderLineWidth:CGFloat = 2.0
    
    
    // MARK: - draw
    public override func draw(in ctx: CGContext) {
        
        UIGraphicsPushContext(ctx)
        
        var circleFrame = CGRect(x:kLayerMargin , y: kLayerMargin, width: self.bounds.size.width - kLayerMargin*2, height: self.bounds.size.height - kLayerMargin*2)
        let circlePath = UIBezierPath(roundedRect: circleFrame, cornerRadius: (circleFrame.size.height) / 2.0)
        
        if highlighted == false || showPath == false{
            ctx.setStrokeColor(self.passwordView.normalColor.cgColor);
            ctx.setLineWidth(kBorderLineWidth / UIScreen.main.scale);
            ctx.addPath(circlePath.cgPath);
            ctx.strokePath();
        }else{
            ctx.setStrokeColor(isError ? self.passwordView.errorColor?.cgColor ?? UIColor.red.cgColor : self.passwordView.highlightedColor.cgColor)
            ctx.setLineWidth(kBorderLineWidth/UIScreen.main.scale)
            ctx.addPath(circlePath.cgPath)
            ctx.strokePath()
            
            circleFrame = circleFrame.insetBy(dx: 13.0/2, dy: 13.0/2)
            
            let circlePath2 = UIBezierPath(roundedRect: circleFrame, cornerRadius: (circleFrame.size.height) / 2.0)
            ctx.setStrokeColor(isError ? self.passwordView.errorColor?.cgColor ?? UIColor.red.cgColor : self.passwordView.highlightedColor.cgColor)
            ctx.addPath(circlePath2.cgPath)
            ctx.strokePath()
            
            let dotRect = CGRect(x: self.bounds.size.width/2 - kDotHighlightedRadius,
                                 y: self.bounds.size.height/2-kDotHighlightedRadius,
                                 width: kDotHighlightedRadius*2, height: kDotHighlightedRadius*2)
            let dotPath = UIBezierPath(roundedRect: dotRect, cornerRadius: kDotHighlightedRadius)
            ctx.addPath(dotPath.cgPath)
            ctx.strokePath()
        }
        UIGraphicsPopContext()
    }
    
    

}
