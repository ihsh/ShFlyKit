//
//  SHAdressBookUI.swift
//  SHKit
//
//  Created by hsh on 2019/5/10.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//UI代理
@objc protocol SHAdressBookUIDelegate:NSObjectProtocol {
    //代理返回cell
    @objc optional func cellForIndexPath(_ cell:UITableViewCell,indexPath: IndexPath, contact:SHAddressItem)->UITableViewCell
    //点击选择了Cell
    @objc optional func didSelectCell(_ indexPath:IndexPath,contact:SHAddressItem)
}


//通讯录显示界面
class SHAdressBookUI: UIViewController,UITableViewDataSource,UITableViewDelegate,HeatBeatTimerDelegate,SHSearchBarDelegate {
    //Variable
    private var mainView:UIView!
    private var dataSource:[SHAddressSection] = []           //分数的数据
    private var searchDataSource:[SHAddressItem] = []        //搜索的结果
    private var isSearching:Bool = false                     //是否正在搜索
    private var customCell:Bool = false                      //是否自定义cell
    private var searchView:SHSearchBar!                      //搜索栏
    private var sectionIndexs:[String]!                      //索引字母数组
    private var tableView:UITableView!                       //表视图
    private var searchTableV:UITableView!                    //搜索结果视图
    private var selectTimeStamp:TimeInterval = 0             //滚动选择条的时间戳
    
    public weak var delegate:SHAdressBookUIDelegate?         //代理
    public var bigShowView:UIView!                           //放大显示字符视图
    public var bigLabel:UILabel!                             //放大显示的字母
    public var rowHeight:CGFloat = 56                        //行高
    public var sectionHeight:CGFloat = 28                    //段高
    public var sectionIndexColor:UIColor = UIColor.colorHexValue("212121") //索引文字的颜色
    public var sectionHeaderBackColor:UIColor = UIColor.colorRGB(red: 231, green: 231, blue: 231)//段头背景色
    public var sectionChaColor:UIColor = UIColor.colorHexValue("212121")   //段头文字颜色
    
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white;
        //创建一个在安全区域内的视图
        self.mainView = UIScreenFit.createMainView();
        self.view.addSubview(mainView);
        //获取数据
        SHAddressBook.fetchData { (data, msg) in
            let result = SHAddressBook.sortBySection(SHAddressBook.separateByPhone(data));
            self.dataSource = result.0;
            self.sectionIndexs = result.1;
            self.tableView.reloadData()
        };
        //搜索视图
        searchView = SHSearchBar()
        searchView.delegate = self;
        searchView.frame = CGRect(x: 0, y: 0, width:ScreenSize().width, height: 50);
        self.mainView.addSubview(searchView);
        //初始化表视图
        tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.plain);
        tableView.register(AddressBookCell.self, forCellReuseIdentifier: "cell");
        tableView.rowHeight = rowHeight;
        tableView.separatorStyle = .none;
        tableView.sectionIndexColor = sectionIndexColor;
        tableView.dataSource = self;
        tableView.delegate = self;
        self.mainView.addSubview(tableView);
        tableView.mas_makeConstraints { (maker) in
            maker?.left.right()?.bottom()?.mas_equalTo()(self.mainView);
            maker?.top.mas_equalTo()(searchView.mas_bottom);
        }
        //搜索表视图
        searchTableV = UITableView.init(frame: CGRect.zero, style: .plain);
        searchTableV.rowHeight = rowHeight;
        searchTableV.separatorStyle = .none;
        searchTableV.delegate = self;
        searchTableV.dataSource = self;
        searchTableV.register(AddressBookCell.self, forCellReuseIdentifier: "cell");
        self.mainView.addSubview(searchTableV);
        searchTableV.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.mainView);
            maker?.top.mas_equalTo()(searchView.mas_bottom);
            maker?.bottom.mas_equalTo()(self.mainView);
        }
        searchTableV.isHidden = true;
        //放大的显示
        bigShowView = UIView()
        bigShowView.layer.cornerRadius = 10;
        bigShowView.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.7);
        self.view.addSubview(bigShowView);
        bigShowView.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(self.view);
            maker?.width.height()?.mas_equalTo()(100);
        }
        bigLabel = UILabel()
        bigLabel.textColor = UIColor.white;
        bigLabel.font = kMediumFont(40);
        bigShowView.addSubview(bigLabel);
        bigLabel.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(bigShowView);
        }
        bigShowView.isHidden = true;
        HeatBeatTimer.shared.addTimerTask(identifier: "hideBigShow", span: 1, repeatCount: 0, delegate: self);
    }
    
    
    //注册cell
    public func registerCellClass(_ cellClass:AnyClass,delegate:SHAdressBookUIDelegate){
        self.delegate = delegate;
        customCell = true;
        tableView.register(cellClass, forCellReuseIdentifier: "custom");
        searchTableV.register(cellClass, forCellReuseIdentifier:"custom");
    }
    
    
    //HeatBeatTimerDelegate--可换用简单定时器回调的方式
    func timeTaskCalled(identifier: String) {
        let time = NSDate().timeIntervalSince1970;
        if fabs(time - selectTimeStamp) > 1{
            bigShowView.isHidden = true;
        }
    }

    
    //SHSearchBarDelegate
    func textDidChange(_ text: String) {
        isSearching = true;
        searchTableV.isHidden = (isSearching == false)
        //筛选结果
        var tmpResult:[SHAddressItem] = [];
        if text.count > 0 {
            for section in dataSource {
                for item in section.contacts{
                    if (item.showName.contains(text) || (item.organazation ?? "").contains(text)){
                        tmpResult.append(item);
                    }else{
                        var finded:Bool = false;
                        if (item.phones.count > 0){
                            for phone in item.phones {
                                if (phone.contains(text)){
                                    tmpResult.append(item);
                                    finded = true;
                                    break;
                                }
                            }
                        }
                        if (item.address.count > 0 && finded == false){
                            for address in item.address {
                                if (address.fullAddress.contains(text)){
                                    tmpResult.append(item);
                                    finded = true;
                                    break;
                                }
                            }
                        }
                        if (item.mails.count > 0 && finded == false){
                            for mail in item.mails {
                                if (mail.contains(text)){
                                    tmpResult.append(item);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        searchDataSource.removeAll();
        searchDataSource.append(contentsOf: tmpResult);
        searchTableV.reloadData();
    }
    
    
    //停止搜索
    func textDidEndEdit() {
        searchTableV.isHidden = true;
    }
    
    
    //键盘高度变更
    func keyboardChangeFrame(_ height: CGFloat) {
        searchTableV.mas_remakeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.mainView);
            maker?.top.mas_equalTo()(searchView.mas_bottom);
            maker?.bottom.mas_equalTo()(self.mainView)?.offset()(-height);
        }
    }
    
    
    //UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.isEqual(searchTableV) {
            return 1;
        }
        return dataSource.count;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(searchTableV) {
            return searchDataSource.count;
        }
        let data = dataSource[section];
        return data.contacts.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AddressBookCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressBookCell;
        cell.selectionStyle = .none;
        if (tableView.isEqual(searchTableV)){
            let data = searchDataSource[indexPath.row];
            cell.loadContact(item: data);
            if (customCell) {
                let custom = tableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath);
                return delegate?.cellForIndexPath?(custom, indexPath: indexPath, contact: data) ?? UITableViewCell();
            }
        }else{
            let data = dataSource[indexPath.section];
            let contact:SHAddressItem = data.contacts[indexPath.row];
            cell.loadContact(item: contact);
            if (customCell) {
                let custom = tableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath);
                return delegate?.cellForIndexPath?(custom, indexPath: indexPath, contact: contact) ?? UITableViewCell();
            }
        }
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var contact:SHAddressItem!
        if tableView.isEqual(searchTableV) {
            contact = searchDataSource[indexPath.row];
        }else{
            let data = dataSource[indexPath.section];
            contact = data.contacts[indexPath.row];
        }
        delegate?.didSelectCell?(indexPath, contact: contact);
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight;
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = sectionHeaderBackColor;
        let label = UILabel()
        if tableView.isEqual(searchTableV) {
            label.text = "最佳搜索结果";
        }else{
            let data = dataSource[section];
            label.text = data.character;
        }
        label.font = kFont(14);
        label.textColor = sectionChaColor;
        view.addSubview(label);
        label.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.centerY.mas_equalTo()(view);
        }
        return view;
    }
    
    
    //索引的显示数据
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView.isEqual(searchTableV) == false{
             return sectionIndexs;
        }
        return [];
    }
    
    
    //滚动索引，显示字母
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let character = sectionIndexs[index];
        bigLabel.text = character;
        selectTimeStamp = NSDate().timeIntervalSince1970;
        bigShowView.isHidden = false;
        return index;
    }
    
    
}



//联系人Cell
class AddressBookCell: UITableViewCell {
    public var headpImgV:UIImageView!           //头像
    public var headpLabel:UILabel!              //头像文字
    public var name:UILabel!                    //名字
    public var content:UILabel!                 //内容
    public var line:UIView!                     //线条
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        //头像
        headpImgV = UIImageView()
        self.contentView.addSubview(headpImgV);
        headpImgV.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self.contentView)?.offset()(16);
            maker?.centerY.mas_equalTo()(self.contentView);
            maker?.width.height()?.mas_equalTo()(40);
        }
        headpImgV.layer.cornerRadius = 20;
        headpImgV.layer.masksToBounds = true;
        //头像文字
        headpLabel = UILabel()
        self.contentView.addSubview(headpLabel);
        headpLabel.mas_makeConstraints { (maker) in
            maker?.left.centerY().mas_equalTo()(headpImgV);
            maker?.width.height()?.mas_equalTo()(40);
        }
        headpLabel.layer.cornerRadius = 20;
        headpLabel.textAlignment = .center;
        headpLabel.font = kFont(20);
        headpLabel.layer.masksToBounds = true;
        headpLabel.isHidden = true;
        //名字
        name = UILabel()
        name.font = kFont(14);
        name.textColor = UIColor.colorHexValue("212121");
        self.contentView.addSubview(name);
        name.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self.headpImgV.mas_right)?.offset()(12);
            maker?.centerY.mas_equalTo()(self.contentView)?.offset()(-8);
        }
        //描述
        content = UILabel();
        content.font = kFont(12);
        content.textColor = UIColor.colorHexValue("9e9e9e");
        self.contentView.addSubview(content);
        content.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(name);
            maker?.top.mas_equalTo()(name.mas_bottom)?.offset()(3);
        }
        
        line = UIView()
        line.backgroundColor = UIColor.colorRGB(red: 231, green: 231, blue: 231);
        self.contentView.addSubview(line);
        line.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(name);
            maker?.bottom.mas_equalTo()(self.contentView);
            maker?.right.mas_equalTo()(self.contentView)?.offset()(-12);
            maker?.height.mas_equalTo()(0.5);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func loadContact(item:SHAddressItem){
        name.text = item.showName;
        content.text = item.phones.first;
        if item.headp != nil {
            headpLabel.isHidden = true;
            headpImgV.isHidden = false;
            headpImgV.image = item.headp;
        }else{
            headpLabel.isHidden = false;
            headpImgV.isHidden = true;
            headpLabel.backgroundColor = item.headpTextBackColor ?? UIColor.randomColor(alpha: 0.8);   //背景颜色
            headpLabel.textColor = UIColor.white;
            if (item.showName != nil && item.showName.count > 0){
                let index = item.showName.index(item.showName.endIndex, offsetBy: -1);
                headpLabel.text = String(item.showName.suffix(from: index));
            }else{
                headpLabel.text = "#";
            }
        }
    }
    
    
}
