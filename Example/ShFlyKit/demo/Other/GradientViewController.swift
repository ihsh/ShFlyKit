//
//  GradientViewController.swift
//  SHKit
//
//  Created by hsh on 2019/2/28.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class GradientViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
   
    let tableview = UITableView()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewTrans = ViewGradientTransfer()
        self.view.addSubview(viewTrans);
        viewTrans.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.view);
        }
        self.view.backgroundColor = UIColor.white;
        self.navigationController?.isNavigationBarHidden = true;
        
        //创建uitableview
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.rowHeight = 60;
        let head = UIView()
        head.backgroundColor = UIColor.randomColor();
        head.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: 200);
        tableview.tableHeaderView = head;
        viewTrans.setContentView(tableview);
        
        viewTrans.setCustomNav(createClearTextView(), height: 100);
        
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.white;
        return cell;
    }
    
    
    
    public func createClearTextView()->UIView{
        let view = UIView()
        view.backgroundColor = UIColor.clear;
        
        let label = UILabel.initText("推荐", font: kFont(14), textColor: UIColor.white, alignment: NSTextAlignment.center, super: view);
        label.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.bottom.mas_equalTo()(view.mas_bottom)?.offset()(-10);
        }
        return view;
    }
   

}
