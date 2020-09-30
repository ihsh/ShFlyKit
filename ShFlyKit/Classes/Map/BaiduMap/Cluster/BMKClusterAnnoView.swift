//
//  BMKClusterAnnoView.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

///自定义的百度点聚合AnnoView
class BMKClusterAnnoView: BMKAnnotationView {

    public var label:UILabel!
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier);
        self.backgroundColor = UIColor.red;
        self.layer.cornerRadius = 5;
        self.label = UILabel.initText(nil, font: kFont(16), textColor: UIColor.white, alignment: NSTextAlignment.center, super: self);
        label.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
