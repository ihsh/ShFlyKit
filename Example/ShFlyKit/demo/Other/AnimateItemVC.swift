//
//  AnimateItemVC.swift
//  SHKit
//
//  Created by hsh on 2019/4/22.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class AnimateItemVC: UIViewController,AnimateItemViewDelegate{
    
    
    //Vaariable
    public var view1:AnimateItemView!
    public var view2:AnimateItemView!
    
    //load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        let header1 = createHeader(section: 0);
        self.view.addSubview(header1);
        header1.mas_makeConstraints { (maker) in
            maker?.top.mas_equalTo()(self.view)?.offset()(100);
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(40);
        }
        let arr = ["要闻","科技","深圳","重庆","房产","历史","旅游","福建","游戏","健康","推荐"];
        let arr2 = ["视频","新时代","财经","娱乐","体育","军事","时尚","国际","文化","图片","新国风","汽车","股票","理财","情感","家具","电竞","政法网事","公益","电视剧","法制","情感"];
        view1 = AnimateItemView()
        self.view.addSubview(view1);
        view1.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(header1.mas_bottom);
            maker?.height.mas_equalTo()(150);
        }
        view1.constraintUpView = header1;
        
        let header2 = createHeader(section: 1);
        self.view.addSubview(header2);
        header2.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(40);
            maker?.top.mas_equalTo()(view1.mas_bottom);
        }
        view2 = AnimateItemView()
        self.view.addSubview(view2);
        view2.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(header2.mas_bottom);
            maker?.height.mas_equalTo()(360);
        }
        view2.constraintUpView = header2;
        view2.dataSource = view1;
        view1.dataSource = view2;
        view2.delegate = self;
        view1.delegate = self;
        
        view1.loadItems(arr);
        view2.loadItems(arr2);
    }

    
    func didSelectIndex(_ index: NSInteger) {
        print(index);
    }
    
    
    //更改高度
    func changeHeight(_ height: CGFloat, obj: AnimateItemView) {
        if obj.isEqual(view1) {
            view1.mas_remakeConstraints { (maker) in
                maker?.left.right()?.mas_equalTo()(self.view);
                maker?.top.mas_equalTo()(obj.constraintUpView?.mas_bottom);
                maker?.height.mas_equalTo()(height);
            }
        }else{
            view2.mas_remakeConstraints { (maker) in
                maker?.left.right()?.mas_equalTo()(self.view);
                maker?.top.mas_equalTo()(obj.constraintUpView?.mas_bottom);
                maker?.height.mas_equalTo()(height);
            }
        }
    }
    
    
    
    
    //创建标题
    private func createHeader(section:Int)->UIView{
        let view = UIView()
        let label = UILabel()
        view.addSubview(label);
        label.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.top.bottom()?.mas_equalTo()(view);
        }
        label.font = kFont(14);
        label.textColor = UIColor.colorHexValue("212121");
        if section == 0 {
            label.text = "已选频道";
        }else if section == 1{
            label.text = "精选频道";
        }
        return view;
    }
    

    
}
