//
//  ImageColorFetchVC.swift
//  SHKit
//
//  Created by hsh on 2019/5/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class ImageColorFetchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let mainV:UIView = UIScreenFit.createMainView();
        self.view.addSubview(mainV);
        
        let fetch = ImageColorFetch()
        mainV.addSubview(fetch);
        fetch.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(mainV)?.offset()(20);
            maker?.right.mas_equalTo()(mainV)?.offset()(-20);
            maker?.top.mas_equalTo()(mainV)?.offset()(20);
            maker?.height.mas_equalTo()(200);
        }
        fetch.setImage(UIImage.name("jietu", cls: ImageColorFetch.self, bundleName: "Graphics"));
        
        let view = UIView()
        mainV.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(mainV);
            maker?.top.mas_equalTo()(fetch.mas_bottom)?.offset()(50);
            maker?.height.mas_equalTo()(60);
            maker?.width.mas_equalTo()(200);
        }
        fetch.indicateView = view;
        
    }
    

   

}
