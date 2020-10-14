//
//  AMapClusterAnnoView.swift
//  SHKit
//
//  Created by hsh on 2019/1/16.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit

///自定义的点聚合AnnoView类
class AMapClusterAnnoView: MAAnnotationView {

    public var label:UILabel!
    
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier);
        self.layer.cornerRadius = 5;
        self.backgroundColor = UIColor.red;
        self.label = UILabel.initText(nil, font: kFont(16), textColor: UIColor.white, alignment: NSTextAlignment.center, super: self);
        label.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
