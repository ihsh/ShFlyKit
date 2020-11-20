//
//  ChartZoomView.swift
//  ShFlyKit
//
//  Created by mac on 2020/11/19.
//

import UIKit


//滚动视图
class ChartZoomView: UIView ,UIScrollViewDelegate{
    //Variable
    public var minRate:CGFloat = 0.5
    public var maxRate:CGFloat = 10
    public var zoomV:UIView?
    private var scrollV:UIScrollView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Interface
    public func setZoomView(_ view:UIView){
        scrollV = UIScrollView();
        scrollV.delegate = self;
        scrollV.minimumZoomScale = minRate;
        scrollV.maximumZoomScale = maxRate;
        scrollV.bouncesZoom = true;
        self.addSubview(scrollV);
        scrollV .mas_makeConstraints { (make) in
            make?.top.left()?.right()?.bottom()?.mas_equalTo()(self);
        }
        zoomV = view;
        scrollV.addSubview(view);
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomV;
    }

}
