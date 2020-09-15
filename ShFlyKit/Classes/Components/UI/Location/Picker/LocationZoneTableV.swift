//
//  LocationZoneTableV.swift
//  SHKit
//
//  Created by hsh on 2019/9/20.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//协议
protocol LocationZoneTableDelegate:NSObjectProtocol {
    //完成选择地址
    func selectAddress(result:AddressResult,type:AddressType)
    //没有数据重新请求
    func reCallDataSource(type:AddressType)
}


///选择地理区域的控件--列表样式
class LocationZoneTableV: UIView , UITableViewDelegate , UITableViewDataSource , LocSegmentDelegate {
    //Variable
    public weak var delegate:LocationZoneTableDelegate?         //代理协议
    //配置项
    public var showLevel:UInt = 3                               //显示多少级别(1-4)
    public var completeCheck:Bool = false                       //完成需要确认
    public var listViewHeight:CGFloat = 320                     //列表总高度
    public var contentHeight:CGFloat = 420                      //视图总高度
    public var backColor = UIColor.colorHexValue("000000", alpha: 0.3)//背景黑色
    public var closeImage:UIImage?                              //关闭按钮的图片
    //视图
    public var contentV:UIView!                                 //容器视图--开放添加自定义视图
    public var titleL:UILabel!                                  //标题视图
    public var closeBtn:UIButton!                               //关闭按钮
    public var listView:UITableView!                            //选择列表
    public var segmentV:LocSegment!                             //头部选择视图
    //私有数据
    private var listDataSource:AddressModel!                    //选择器数据源
    private var contactType:AddressType!                        //地址类型
    private var result:AddressResult?                           //结果暂存
    private var components = LocMatchComponents()               //当前匹配信息
    
   
    
    ///Interface
    //展示视图
    public func animateIn(view:UIView,type:AddressType){
        //已经加载
        if self.superview != nil {
            return;
        }
        contactType = type;
        listDataSource = (type == AddressType.Send ? LocDataSource.shared.sendAddress : LocDataSource.shared.receiveAddress);
        //没有数据，重新请求
        if listDataSource == nil || listDataSource.provinces.count == 0{
            delegate?.reCallDataSource(type: type);
            return;
        }
        //坐标
        self.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height);
        self.contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: contentHeight);
        view.addSubview(self);
        UIView.animate(withDuration: 0.3) {
            self.contentV.frame = CGRect(x: 0, y: ScreenSize().height-self.contentHeight-ScreenBottomInset(), width: ScreenSize().width, height: self.contentHeight);
        }
        self.listView.reloadData();
        //点击消失
        closeBtn = UIButton.initTitle("关闭", textColor: UIColor.colorHexValue("4A4A4A"), back: UIColor.white, font: kFont(14), super: contentV);
        closeBtn.addTarget(self, action: #selector(closeBtnClick(_:)), for: .touchUpInside);
        closeBtn.mas_makeConstraints { (maker) in
            maker?.top.right()?.mas_equalTo()(contentV);
            maker?.height.mas_equalTo()(45);
            maker?.width.mas_equalTo()(60);
        }
    }
    
    
    //移除视图
    @objc public func dismissFromSuper(){
        UIView.animate(withDuration: 0.3, animations: {
            self.contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: self.contentHeight);
        }) { (finish) in
            self.removeFromSuperview();
        }
    }

    
    
    //Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listDataSource != nil {
            if components.current == 0 {return listDataSource.provinces.count};
            let province = listDataSource.provinces[components.provinceIndex];
            if components.current == 1 {return province.citys.count};
            let city = province.citys[components.cityIndex];
            if components.current == 2 {return city.coutrys.count};
            let courtry = city.coutrys[components.coutryIndex];
            if components.current == 3 {return courtry.towns.count};
        }
        return 0;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tmpStr:String?
        let cell:LocationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocationTableViewCell;
        switch components.current{
        case 0:
            let province = listDataSource.provinces[indexPath.row];
            tmpStr = province.provinceName;
            cell.isSelected(tmpStr == result?.province);
        case 1:
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[indexPath.row];
            tmpStr = city.cityName;
            cell.isSelected(tmpStr == result?.city);
        case 2:
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[components.cityIndex];
            let coutry = city.coutrys[indexPath.row];
            tmpStr = coutry.coutryName;
            cell.isSelected(tmpStr == result?.coutry);
        case 3:
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[components.cityIndex];
            let coutry = city.coutrys[components.coutryIndex];
            let town = coutry.towns[indexPath.row];
            tmpStr = town.townName;
            cell.isSelected(tmpStr == result?.coutry);
        default:
            break;
        }
        cell.titleL.text = tmpStr;
        cell.selectionStyle = .none;
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch components.current {
        case 0:
            components.provinceIndex = indexPath.row;
            let province = listDataSource.provinces[indexPath.row];
            //切换了省，重新初始化数据
            if (result != nil && result?.province != province.provinceName) || result == nil {
                result = AddressResult()
                closeImage != nil ? closeBtn.setImage(closeImage!, for: .normal) : closeBtn.setTitle("关闭", for: .normal);
            }
            result?.province = province.provinceName;
            result?.provinceCode = province.provinceCode;
            components.current = 1;
            segmentV.setResults(result!, index: 0,curent: components.current);
        case 1:
            components.cityIndex = indexPath.row;
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[components.cityIndex];
            //清空区的选择
            if result?.city != city.cityName {
                result?.coutry = nil;
                result?.coutryCode = 0;
                closeImage != nil ? closeBtn.setImage(closeImage!, for: .normal) : closeBtn.setTitle("关闭", for: .normal);
            }
            result?.city = city.cityName;
            result?.cityCode = city.cityCode;
            //可选第三级
            if showLevel >= 2 {
                components.current = 2;
            }
            segmentV.setResults(result!, index: 1,curent: components.current);
        case 2:
            components.coutryIndex = indexPath.row;
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[components.cityIndex];
            let coutry = city.coutrys[components.coutryIndex];
            //设置区
            func setCoutry(){
                result?.coutry = coutry.coutryName;
                result?.coutryCode = coutry.coutryCode;
                segmentV.setResults(result!, index: 2,curent: components.current);
            }
            //有乡镇一级
            if showLevel > 3 {
                if result?.coutry != coutry.coutryName {
                    result?.town = nil;
                    result?.townCode = 0;
                    closeImage != nil ? closeBtn.setImage(closeImage!, for: .normal) : closeBtn.setTitle("关闭", for: .normal);
                }
                //往下一级显示
                components.current = 3;
                setCoutry();
            }else{
                setCoutry();
                //生成地址
                result?.fullZone = String(format: "%@%@%@", result!.province,result!.city,result?.coutry ?? "");
                result?.isMatch = true;
                //需要点完成
                if completeCheck == true{
                    closeBtn.setTitle("完成", for: .normal);
                }else{//直接返回结果
                    delegate?.selectAddress(result: result!, type: contactType);
                    dismissFromSuper();
                }
            }
        case 3:
            components.townIndex = indexPath.row;
            let province = listDataSource.provinces[components.provinceIndex];
            let city = province.citys[components.cityIndex];
            let coutry = city.coutrys[components.coutryIndex];
            let town = coutry.towns[components.townIndex];
            result?.town = town.townName;
            result?.townCode = town.townCode;
            
            result?.fullZone = String(format: "%@%@%@%@", result!.province,result!.city,result!.coutry ?? "",result?.town ?? "");
            result?.isMatch = true;
            
            segmentV.setResults(result!, index: 3,curent: components.current);
            if completeCheck == true{
                closeBtn.setTitle("完成", for: .normal);
            }else{//返回结果
                delegate?.selectAddress(result: result!, type: contactType);
                dismissFromSuper();
            }
        default:
            break;
        }
        listView.reloadData();
    }
    
    
    //右上角按钮点击
    @objc private func closeBtnClick(_ sender:UIButton){
        if sender.titleLabel?.text == "完成" {
            delegate?.selectAddress(result: result!, type: contactType);
        }
        dismissFromSuper();
    }
    
    
    //Delegate-切换选择的级别
    func selectComponent(_ component: Int) {
        components.current = component;
        listView.reloadData()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = backColor;
        //内容视图
        contentV = UIView()
        contentV.backgroundColor = UIColor.white;
        self.addSubview(contentV);
        //列表
        listView = UITableView.init(frame: CGRect.zero, style: .plain);
        listView.register(LocationTableViewCell.self, forCellReuseIdentifier: "cell");
        listView.rowHeight = 40;
        contentV.addSubview(listView);
        listView.dataSource = self;
        listView.delegate = self;
        listView.separatorStyle = UITableViewCellSeparatorStyle.none;
        listView.mas_makeConstraints { (maker) in
            maker?.bottom.right()?.left()?.left()?.mas_equalTo()(contentV);
            maker?.height.mas_equalTo()(listViewHeight);
        }
        //头部点击视图
        segmentV = LocSegment()
        contentV.addSubview(segmentV);
        segmentV.delegate = self;
        segmentV.mas_updateConstraints { (maker) in
            maker?.left.mas_equalTo()(self)?.offset()(16);
            maker?.bottom.mas_equalTo()(listView.mas_top);
            maker?.right.mas_equalTo()(self)?.offset()(-16);
            maker?.height.mas_equalTo()(40);
        }
        //标题
        let label = UILabel.initText("配送至", font: kMediumFont(18), textColor: UIColor.black, alignment: .center, super: contentV);
        label.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(contentV);
            maker?.top.mas_equalTo()(contentV)?.offset()(16);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}



protocol LocSegmentDelegate:NSObjectProtocol {
    func selectComponent(_ component:Int)
}


//选择的视图
class LocSegment:UIView{
    //配置
    public static var font:UIFont = kFont(16)               //分段标题的字号
    public static var color:UIColor = UIColor.black         //分段标题有值的颜色
    public static var separaColor = UIColor.colorHexValue("000000", alpha: 0.1)
    public static var nullColor = UIColor.red               //分段标题无值的颜色
    public static var lineHeight:CGFloat = 2                //分割线的高度
    public static var divideAverage:Bool = false            //是否均分显示
    public weak var delegate:LocSegmentDelegate?            //分段的代理
    //variable
    private var views:[SegCompontV] = []                    //分段里面的视图
    private var strs:[Int:String] = [:]                     //标题文本
    private var widths:[Int:CGFloat] = [:]                  //标题的宽度
    private var tint:UIView!                                //指示条
    
    
    //各个按钮
    class SegCompontV: UIView {
        public var titleL:UILabel!      //标题
        public var btn:UIButton!        //点击标题的按钮
        
        class func initSeg()->SegCompontV{
            let view = SegCompontV()
            view.titleL = UILabel.initText(nil, font:LocSegment.font, textColor: LocSegment.color, alignment: .center, super: view);
            view.titleL.adjustsFontSizeToFitWidth = true;       //宽度不够自动适应
            view.titleL.mas_makeConstraints { (maker) in
                maker?.centerY.mas_equalTo()(view);
                maker?.left.right()?.mas_equalTo()(view);
            }
            view.btn = UIButton()
            view.addSubview(view.btn);
            view.btn.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(view);
            }
            return view;
        }
    }
    
    
    //设置标题，宽度再变化
    public func setResults(_ result:AddressResult,index:Int,curent:Int){
        //文案
        strs[0] = result.province ?? "请选择";
        strs[1] = result.city ?? (curent == 1 ? "请选择" : "");
        strs[2] = result.coutry ?? (curent == 2 ? "请选择" : "");
        strs[3] = result.town ?? (curent == 3 ? "请选择" : "");
        
        if index >= 0 && index <= 3 {
            var last:UIView?
            var showIndex:Int = -1;
            for (i,view) in views.enumerated(){
                let str = strs[i] ?? "";
                let tmp:NSString = str as NSString;
                var width = (tmp.length == 0) ? 0 : tmp.width(with: LocSegment.font) + 6;
                //宽度是否均分
                if LocSegment.divideAverage == true {
                    width = ScreenSize().width/4.0;
                }
                widths[i] = width;
                view.titleL.text = str;
                if str == "请选择" || str == "" {
                    view.titleL.textColor = LocSegment.nullColor;
                    if showIndex < 0 {showIndex = i};
                }else{
                    view.titleL.textColor = LocSegment.color;
                }
                view.mas_remakeConstraints { (maker) in
                    if last != nil{
                        maker?.left.mas_equalTo()(last?.mas_right);
                    }else{
                        maker?.left.mas_equalTo()(self);
                    }
                    maker?.top.bottom()?.mas_equalTo()(self);
                    maker?.width.mas_equalTo()(width);
                }
                last = view;
            }
            self.selectTint(showIndex);
        }
    }
    
    
    //指示条变更
    private func selectTint(_ index:Int){
        self.tint.isHidden = index < 0;
        var start:CGFloat = 0;
        var step:Int = 0;
        while(step < index){
            start += (widths[step] ?? 0);
            step += 1;
        }
        UIView.animate(withDuration: 0.3) {
            self.tint.frame = CGRect(x: start, y: 40-LocSegment.lineHeight, width: self.widths[index] ?? 0, height: LocSegment.lineHeight);
        }
    }
    
    
    @objc private func clickSegment(_ sender:UIButton){
        delegate?.selectComponent(sender.tag);
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        for i in 0...3{
            let view = SegCompontV.initSeg();
            self.addSubview(view);
            views.append(view);
            view.btn.tag = i;
            view.btn.addTarget(self, action: #selector(clickSegment(_:)), for: .touchUpInside);
        }
        //指示条
        tint = UIView()
        tint.backgroundColor = LocSegment.nullColor;
        self.addSubview(tint);
        self.setResults(AddressResult(), index: 0,curent:0);
        //分割线
        let line = UIView()
        line.backgroundColor = LocSegment.separaColor;
        self.addSubview(line);
        line.mas_makeConstraints { (maker) in
            maker?.left.bottom().right()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(0.5);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



///自定义的cell
class LocationTableViewCell:UITableViewCell{
    public static var selectColor:UIColor = UIColor.colorRGB(red: 205, green: 0, blue: 13)  //cell选中的颜色样式
    public static var normalColor:UIColor = UIColor.colorHexValue("4A4A4A")                 //正常的cell文字颜色
    public static var font:UIFont = kFont(16)                                               //字体
    public static var separatorColor = UIColor.colorHexValue("000000", alpha: 0.1)          //分割线颜色
    //variable
    public var titleL:UILabel!                                                              //显示文本
    
    
    public func isSelected(_ select:Bool){
        titleL.textColor = select ? LocationTableViewCell.selectColor : LocationTableViewCell.normalColor;
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        titleL = UILabel()
        titleL.font = LocationTableViewCell.font;
        titleL.textColor = LocationTableViewCell.normalColor;
        self.contentView.addSubview(titleL);
        titleL.mas_makeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(self.contentView);
            maker?.left.mas_equalTo()(self.contentView)?.offset()(16);
        }
        let line = UIView()
        line.backgroundColor = LocationTableViewCell.separatorColor;
        self.contentView.addSubview(line);
        line.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(self.contentView)?.offset()(16);
            maker?.right.mas_equalTo()(self.contentView)?.offset()(-16);
            maker?.bottom.mas_equalTo()(self.contentView);
            maker?.height.mas_equalTo()(0.5);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
