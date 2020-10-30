//
//  CityListVC.swift
//  SHKit
//
//  Created by hsh on 2019/9/24.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


///代理
public protocol CityListDelegate : NSObjectProtocol{
    //选择城市
    func chooseCity(_ city:CityItem)
    //调用定位
    func callUserLocation()
}


///城市列表--选择城市
public class CityListVC: UIViewController , UITableViewDataSource,UITableViewDelegate , CityHeadViewDelegate {
    ///Varable
    public weak var delegate:CityListDelegate?
    public var allCitys:[CityItem] = []             //全部城市数据
    public var hotCitys:[CityItem] = []             //热门城市
    public var recents:[CityItem] = []              //最近的城市
    public var current:CityItem?                    //当前定位城市
    public var headV:CityHeadView!                  //头部视图-可以继承重写样式
    //UI配置
    public var sectionIndexColor = UIColor.colorHexValue("4A4A4A")          //索引的字体颜色
    public var sectionBackColor:UIColor = UIColor.colorHexValue("F3F4F5")   //段背景色
    public var rowHeight:CGFloat = 44               //cell行高
    //private
    private var tableV:UITableView!                 //表视图
    private var sectionTitles:[String] = []         //段标题
    private var sectionDic:[String:[CityItem]] = [:]//分段数据
    
    
    ///Load
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "城市列表";
        self.view.backgroundColor = UIColor.white;
        //创建视图
        self.initSubViews();
        //筛选数据
        self.sortCitys();
    }
    
    
    private func initSubViews(){
        //安全显示区域
        guard let main = UIScreenFit.createMainView() else { return };
        if self.presentingViewController != nil {
            main.frame = CGRect(x: 0, y: 0, width: ScreenSize().height, height: ScreenSize().height-ScreenBottomInset());
        }
        self.view.addSubview(main);
        //表视图
        tableV = UITableView.init(frame: CGRect.zero, style: .plain);
        main.addSubview(tableV);
        tableV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(main);
        }
        tableV.backgroundColor = UIColor.white;
        tableV.delegate = self;
        tableV.dataSource = self;
        tableV.rowHeight = rowHeight;
        tableV.sectionIndexColor = sectionIndexColor;       //索引颜色
        tableV.register(CityCell.self, forCellReuseIdentifier: "cell");
        tableV.separatorStyle = .none;
        //热门城市视图
        headV = CityHeadView();
        headV.allCitys = allCitys;
        headV.delegate = self;
        //设置数据
        headV.setCitys(cur: current, recents: recents, favorites: hotCitys);
    }
    
    
    //筛选数据
    private func sortCitys(){
        //按字母排序
        allCitys = allCitys.sorted(by: { (obj1, obj2) -> Bool in
            let en1 = obj1.name_en ?? obj1.name.transformToPinYin();
            let en2 = obj2.name_en ?? obj2.name.transformToPinYin();
            return en1.prefix(1) < en2.prefix(1);
        })
        //添加热门的索引
        sectionTitles.append("★")
        //分组数据
        for item in allCitys {
            //拼音
            let en = item.name_en ?? item.name.transformToPinYin();
            //拼音首字母大写
            let pre:String = String(en.prefix(1)).uppercased();
            //标题
            if sectionTitles.contains(pre) == false{
                sectionTitles.append(pre);
            }
            //字典
            if sectionDic.keys.contains(pre) {
                //存在就直接往数组里添加数据
                sectionDic[pre]?.append(item);
            }else{
                //没有新建一个
                var new:[CityItem] = []
                new.append(item);
                sectionDic[pre] = new;
            }
        }
        tableV.reloadData();
    }
    

    ///Delegate
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count;
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let pre = sectionTitles[section];
        let arr = sectionDic[pre];
        return arr?.count ?? 0;
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CityCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CityCell;
        let pre = sectionTitles[indexPath.section];
        let arr = sectionDic[pre];
        let item = arr?[indexPath.row];
        cell.titleL.text = item?.name;
        cell.selectionStyle = .none;
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headV;
        }else{
            let view = UIView()
            view.backgroundColor = sectionBackColor;
            let pre = sectionTitles[section];
            let label = UILabel.initText(pre, font: kFont(14), textColor: UIColor.colorHexValue("4A4A4A"), alignment: .left, super: view);
            label.mas_makeConstraints { (maker) in
                maker?.left.mas_equalTo()(view)?.offset()(16);
                maker?.centerY.mas_equalTo()(view);
            }
            return view;
        }
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return headV.allHeight;
        }
        return 30;
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pre = sectionTitles[indexPath.section];
        let arr = sectionDic[pre];
        let item = arr?[indexPath.row];
        self .selectCity(item!);
    }
    
    
    //索引的显示数据
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles;
    }
    
    
    //代理方法
    public func selectCity(_ city: CityItem) {
        delegate?.chooseCity(city);
        if (self.presentingViewController != nil) {
            self.dismiss(animated: true, completion: nil);
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    
    //请求重新定位
    public func callUserLocation() {
        delegate?.callUserLocation()
    }
    
    
    public func tableViewScrollEnable(_ enable: Bool) {
        self.tableV.isScrollEnabled = enable;
    }
    
    
}





//自定义Cell
public class CityCell:UITableViewCell{
    public static var font:UIFont = kFont(14)                                       //字号
    public static var textColor:UIColor = UIColor.colorHexValue("4A4A4A")           //文字颜色
    public static var backColor:UIColor = .white
    public static var sepaColor = UIColor.colorHexValue("9E9E9E",alpha: 0.3);
    public var titleL:UILabel!                                                      //标题
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        let view = UIView()
        view.backgroundColor = CityCell.backColor;
        self.contentView.addSubview(view);
        view.mas_makeConstraints { (maker) in
            maker?.left.top()?.bottom()?.mas_equalTo()(self.contentView);
            maker?.right.mas_equalTo()(self.contentView)?.offset()(30);
        }
        titleL = UILabel.initText(nil, font: CityCell.font, textColor: CityCell.textColor, alignment: .left, super: view);
        titleL.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.centerY.mas_equalTo()(view);
        }
        let line = UIView()
        line.backgroundColor = CityCell.sepaColor;
        view.addSubview(line);
        line.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(view)?.offset()(16);
            maker?.bottom.mas_equalTo()(view);
            maker?.height.mas_equalTo()(0.5);
            maker?.width.mas_equalTo()(ScreenSize().width - 32);
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


