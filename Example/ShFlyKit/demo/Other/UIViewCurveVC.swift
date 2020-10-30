//
//  UIViewCurveVC.swift
//  SHKit
//
//  Created by hsh on 2019/6/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class UIViewCurveVC: UIViewController,VerifyCodeViewDelegate {
    //Variable
    public var bubble:BubbleMenu!
    public var activity:ActivityView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let main:UIView = UIScreenFit.createMainView();
        main.backgroundColor = UIColor.randomColor();
        self.view.addSubview(main);
    
        
        let curView = CurveView()
        main.addSubview(curView);
        curView.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(main);
            maker?.top.mas_equalTo()(main)?.offset()(150);
            maker?.height.mas_equalTo()(200);
        }
        curView.direction = .Down;
        
        
        
        let segment = SegmentColtrolView()
        curView.addSubview(segment);
        segment.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(curView);
            make?.centerY.mas_equalTo()(curView);
            make?.height.mas_equalTo()(40);
        }
        segment.autoWidth = true;
        segment.itemWidth = ScreenSize().width/6.0;
        segment.initSubviews(["福建","深圳","重庆","北京","天津","上海","黑龙江"]);
        
    
        
        let view = UIView(for: UIColor.randomColor());
        main.addSubview(view);
        view.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(main);
            make?.top.mas_equalTo()(curView.mas_bottom)?.offset()(10);
            make?.width.mas_equalTo()(50);
            make?.height.mas_equalTo()(50);
        }
        view.setShadow(.gray, opacity: 0.9, offset: CGSize(width: 0, height: 2), radius: 5);
        view.setRadius(5, corners: UIRectCorner.topLeft )
        
        
        
        let codeV = VerifyCodeView()
        codeV.delegate = self;
        codeV.style = .Line;
        codeV.lineWidth = 2;
        codeV.codeLength = 6;
        codeV.cursorColor = codeV.selectColor;
        codeV.initSubViews(ScreenSize().width);
        main.addSubview(codeV);
        codeV.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(main);
            make?.bottom.mas_equalTo()(curView.mas_top)?.offset()(-20);
            make?.height.mas_equalTo()(70);
        }
        codeV.textField.resignFirstResponder();
        
        bubble = BubbleMenu();
        bubble.animate = false;
        bubble.backColor = UIColor.colorHexValue("000000",alpha: 0.3)
        bubble.initMenu(["扫一扫","添加好友","通讯录","面对面"],images: [UIImage.name("seat_available")], startPos: CGPoint(x:ScreenSize().width-40, y: 40));
        
        
        activity = ActivityView();
        let model = ActivityModel()
        model.imgUrl = "jietu";
        model.targetPoint = CGPoint(x: 300, y: 210);
        model.imgWidth = 300;
        
        let model2 = ActivityModel()
        model2.imgUrl = "jietu";
         model2.targetPoint = CGPoint(x: 100, y: 310);
        
        let model3 = ActivityModel()
        model3.imgUrl = "jietu";
        model3.touchDismiss = true;
        
        let model4 = ActivityModel()
        model4.imgUrl = "jietu";
        model4.focusView = self.view;
        
        activity.queueActivity(model);
        activity.queueActivity(model2);
        activity.queueActivity(model3);
        activity.queueActivity(model4);
        
    }
    
    
    func endInputVerifyCode(_ code: String) {
        bubble.showMenu();
    }
   
    

}
