//
//  VedioVC.swift
//  SHKit
//
//  Created by hsh on 2019/9/18.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class VedioVC: UIViewController,ItemsViewDelegate,SHPhoneAssetsToolDelegate{
    
    private var tool = SHPhoneAssetsTool()
    private var imageURL:URL!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        let itemV = ItemsView()
        itemV.delegate = self;
        let height = itemV.initBtns(col: 4, items: ["视频转live"]);
        itemV.frame = CGRect(x:0, y: 100, width: ScreenSize().width, height: height);
        self.view.addSubview(itemV);
    }
    
    
    func objClickTitle(_ title: String) {
        if title == "视频转live" {
            tool.delegate = self;
            tool.cameraMovieAlert(vc: self);
        }
    }
    
    
    func pickerVedio(_ url: URL) {
        LivePhotoMaker .makeLivePhoto(byLibrary: url) { (result) in
            if result != nil{
                LivePhotoMaker .saveLivePhotoToAlbum(withMovPath: result!.movPath, imagePath: result!.jpgPath) { (success) in
                    if (success == true){
                        print("保存成功");
                    }else{
                        print("保存失败");
                    }
                }
            }
        }
    }
   
    
    func permissionDenyed(_ msg: String) {
        
    }

}
