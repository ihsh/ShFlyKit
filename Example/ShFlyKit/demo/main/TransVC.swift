//
//  TransVC.swift
//  SHKit
//
//  Created by hsh on 2019/11/6.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class TransVC: UIViewController {
    public var showView:UIView?                 //不要直接设置vc.view，如果发现viewDidLoad不工作
    public var backColor:UIColor = .white;
    public var showRect:CGRect?
    public var navColorSame:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backColor;
        
        if showView != nil {
            self.view .addSubview(showView!);
            showView?.mas_makeConstraints({ (make) in
                make?.left.right()?.bottom()?.mas_equalTo()(self.view);
                if (self.navigationController?.navigationBar.isHidden ?? false) {
                    make?.top.mas_equalTo()(self.view);
                }else{
                    make?.top.mas_equalTo()(self.view)?.offset()(NavgationBarHeight()+StatusBarHeight());
                }
            })
        }
        if showRect != nil {
            showView?.mas_remakeConstraints({ (make) in
                make?.left.mas_equalTo()(self.view)?.offset()(showRect!.minX);
                if (self.navigationController?.navigationBar.isHidden ?? false) {
                    make?.top.mas_equalTo()(self.view)?.offset()(showRect!.minY);
                }else{
                    make?.top.mas_equalTo()(self.view)?.offset()(NavgationBarHeight()+StatusBarHeight()+showRect!.minY);
                }
                make?.width.mas_equalTo()(showRect!.width);
                make?.height.mas_equalTo()(showRect!.height);
            })
        }
        if navColorSame {
            self.makeNavTranslucent();
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        if navColorSame {
            self.restoreNavTranslucent();
        }
    }


}
