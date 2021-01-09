//
//  ShareDemoVC.swift
//  SHLibrary
//
//  Created by hsh on 2018/7/18.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit

class ShareDemoVC: UIViewController ,SHShareUIDelegate{
    
    public var shareUI:SHShareUI!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        shareUI = SHShareUI()
        shareUI.delegate = self;
        self.view.addSubview(shareUI);
        shareUI.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        
        //注册自定义按钮
        let mini = ShareConfig.initConfig(title: "QQ登录", image: UIImage.name("share_qq"), type: nil);
        let download = ShareConfig.initConfig(title: "微信登录", image: UIImage.name("share_wechat"), type: nil);
        let print = ShareConfig.initConfig(title: "微博登录", image: UIImage.name("share_sina"), type: nil);
        shareUI.customActions = [mini,download,print];
        shareUI.boardSpan = 10;
        shareUI.contentOffset = 10;
        shareUI.defaultShow();
        
        
    }
    
    
    
    //自定义cell用
    func cellForIndexPath(_ cell: UICollectionViewCell, indexPath: IndexPath, config: ShareConfig) -> UICollectionViewCell {
        let showCell:ShareDefaultCell = cell as! ShareDefaultCell;
        showCell.loadData(config: config);
        return showCell;
    }
    
    
    func shareClick(config: ShareConfig) {
        if config.type != nil {

        }else{

        }
       
    }

    
    
    
}
