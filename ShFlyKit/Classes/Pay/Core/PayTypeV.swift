//
//  PayTypeV.swift
//  SHKit
//
//  Created by hsh on 2019/4/1.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry

//自定义UI代理
protocol PayTypeDelegate:NSObjectProtocol {
    //自定义Cell
    func customCellForIndex(indexPath:IndexPath,data:PayTypeData)->UITableViewCell?
    //展开更多的视图
    func viewForUnFoldMore()->UIView
    //返回展开更多的视图高度
    func heightForUnFoldMore()->CGFloat
}


///支付方式界面
class PayTypeV: UIView,UITableViewDataSource,UITableViewDelegate{
    //Variable
    public weak var delegate:PayTypeDelegate?
    
    private var foldRow:Int = 0                             //当支付方式过多的时候从第几行开始折叠，0为不折叠
    private var tableView:UITableView!
    private var originTypes:[PayTypeData] = []              //所有的支付类型
    private var dataSource:[PayTypeData] = []               //支付方式数组
    
    
    ///Interface
    public func initTypes(_ datas:[PayTypeData],hideUnInstalled:Bool = false,foldRow:Int){
        self.originTypes = datas;
        dataSource.removeAll();
        for (index,data) in datas.enumerated() {
            let install:Bool = PayFunction.shared.isInstalled(type: data.type!);
            if (install == true || hideUnInstalled == false){
                if (index < foldRow || foldRow == 0){
                     dataSource.append(data);
                }
            }
        }
        self.foldRow = foldRow;
        tableView.reloadData()
    }
    
    
    //展开所有
    public func unFoldPayTypes(){
        self.foldRow = 0;
        self.initTypes(originTypes, foldRow: foldRow);
    }
    
    
    //返回支付的高度
    public func heightForPayType()->CGFloat{
        var height:CGFloat = 0;
        for (index,data) in dataSource.enumerated(){
            if (index < foldRow || foldRow == 0){
                height += data.cellHeight;
            }
        }
        height += (foldRow == 0 ? 0 : delegate?.heightForUnFoldMore() ?? 0);
        return height;
    }
    
    
    //获取已经选择的支付方式
    public func choosePayType()->PayType?{
        for data in dataSource {
            if data.isSelect == true {
                return data.type!
            }
        }
        return nil;
    }
    
    
    
    ///Delegate
    //UITableViewDataSource,UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = dataSource[indexPath.row];
        return data.cellHeight;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = dataSource[indexPath.row];
        if delegate != nil{
            let cell = delegate?.customCellForIndex(indexPath: indexPath, data: data);
            if cell != nil{
                return cell!;
            }
        }
        let cell:PayTypeCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PayTypeCell;
        cell.loadData(data);
        cell.selectionStyle = .none;
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index,data) in dataSource.enumerated() {
            data.isSelect = indexPath.row == index;
        }
        tableView.reloadData();
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height = delegate?.heightForUnFoldMore();
        return foldRow == 0 ? 0 : height ?? 0;
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = delegate?.viewForUnFoldMore();
        return foldRow == 0 ? nil : view;
    }
    
    //Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initSubViews(){
        tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain);
        self.addSubview(tableView);
        tableView.mas_makeConstraints { (maker) in
            maker?.left.top()?.bottom()?.right()?.mas_equalTo()(self);
        }
        tableView.isScrollEnabled = false;
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        tableView.register(PayTypeCell.self, forCellReuseIdentifier: "cell");
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
}



//支付数据
class  PayTypeData: NSObject {
    public var type:PayType!                //支付方式
    public var content:String!              //描述的内容
    public var cellHeight:CGFloat = 56      //行高
    public var isSelect:Bool = false        //是否选中
    public var isForbid:Bool = false        //是否禁用
    
    class public func initType(_ type:PayType)->PayTypeData{
        let data = PayTypeData()
        data.type = type;
        return data;
    }
}



//支付方式Cell
class PayTypeCell: UITableViewCell {
    //variable
    private var icon:UIImageView!           //图标
    private var titleLable:UILabel!         //支付方式标题
    private var contenL:UILabel!            //内容
    private var image1:UIImageView!         //小图标
    private var image2:UIImageView!         //小图标2
    private var selectDot:UIImageView!      //选择样式
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        self.initSubviews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func loadData(_ data:PayTypeData){
        //勾选的状态
        selectDot.image = data.isSelect == true ? UIImage.name("ic_selected") : UIImage.name("ic_diselected")
        selectDot.isHidden = data.isForbid;
        contenL.text = data.content;
        image1.isHidden = true;
        image2.isHidden = true;
        
        if data.content != nil && data.content.count > 0 {
            titleLable.mas_remakeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(icon.centerY)?.offset()(-8);
                maker?.left.mas_equalTo()(icon.mas_right)?.offset()(8);
            }
            contenL.isHidden = false;
            contenL.mas_remakeConstraints { (maker) in
                maker?.top.mas_equalTo()(titleLable.mas_bottom)?.offset()(2);
                maker?.left.mas_equalTo()(icon.mas_right)?.offset()(8);
            }
        }else{
            titleLable.mas_remakeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(icon);
                maker?.left.mas_equalTo()(icon.mas_right)?.offset()(8);
            }
            contenL.isHidden = true;
        }
        
        switch data.type! {
        case .ZhiFubao:
            icon.image = UIImage.name("ic_payment_alipay_on");
            titleLable.text = "支付宝";
        case .WeChat:
            icon.image = UIImage.name("ic_payment_wechat_on");
            titleLable.text = "微信";
        case .Union:
            icon.image = UIImage.name("ic_payment_yunquickpass");
            image1.isHidden = false;
            image2.isHidden = false;
            titleLable.text = "云闪付";
        case .ApplePay:
            icon.image = UIImage.name("ic_payment_applepay");
            image1.isHidden = false;
            image2.isHidden = true;
            titleLable.text = "Apple Pay";
        case .Wallet:
            icon.image = UIImage.name("ic_payment_wallet_on");
            titleLable.text = "余额支付";
        case .Cash:
            icon.image = UIImage.name("ic_payment_cash_on");
            titleLable.text = "现金支付";
        default:
            icon.image = nil;
            titleLable.text = nil;
        }
    }
    
    
    
    private func initSubviews()->Void{
        let view = UIView()
        view.backgroundColor = UIColor.white;
        self.contentView.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self.contentView);
        }
        //图标
        icon = UIImageView()
        view.addSubview(icon);
        icon.mas_makeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(view)
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.width.height()?.mas_equalTo()(42);
        }
        //支付方式标题
        titleLable = UILabel()
        titleLable.font = kFont(14);
        titleLable.textColor = UIColor.colorHexValue("212121");
        view.addSubview(titleLable);
        titleLable .mas_makeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(icon);
            maker?.left.mas_equalTo()(icon.mas_right)?.offset()(8);
        }
        //内容
        contenL = UILabel()
        contenL.font = kFont(12);
        contenL.textColor = UIColor.colorHexValue("9E9E9E");
        view.addSubview(contenL);
        contenL.isHidden = true;
        //勾选的状态
        selectDot = UIImageView()
        view.addSubview(selectDot);
        selectDot.mas_makeConstraints { (maker) in
            maker?.right.mas_equalTo()(view)?.offset()(-16);
            maker?.centerY.mas_equalTo()(view);
            maker?.width.height()?.mas_equalTo()(24);
        }
        //标识
        image1 = UIImageView()
        image1.image = UIImage.name("ic_yinlian");
        view.addSubview(image1);
        image1.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(titleLable.mas_right)?.offset()(8);
            maker?.centerY.mas_equalTo()(titleLable);
            maker?.size.mas_equalTo()(CGSize(width: 22, height: 14));
        }
        image2 = UIImageView()
        image2.image = UIImage.name("ic_quickpass");
        view.addSubview(image2);
        image2.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(image1.mas_right)?.offset()(4);
            maker?.centerY.mas_equalTo()(image1);
            maker?.size.mas_equalTo()(CGSize(width: 22, height: 14));
        }
    }
    
}
