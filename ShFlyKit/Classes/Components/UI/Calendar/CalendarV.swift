//
//  CalendarV.swift
//  SHKit
//
//  Created by hsh on 2019/9/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//代理方法
public protocol CalendarBaseVDelegate:NSObjectProtocol {
    //勾选了某年月日
    func choose(year:Int,month:Int,day:Int,isToday:Bool);
    //滑动到的年月
    func update(year:Int,month:Int);
}


///日历视图本身
public class CalendarBaseV: UIView , UICollectionViewDataSource , UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout , UIScrollViewDelegate{
    //Variable
    public var config = CalendarUIConfig()                          //UI配置项
    public weak var delegate:CalendarBaseVDelegate?                 //代理对象
    private var scrollV:UIScrollView!                               //滚动视图
    private var collections:[UICollectionView] = []                 //集合视图的集合 5个
    private var originDatas:[Int:CalendarSectionData] = [:]         //源数据  ["0":数据,"-1":数据]  当前月份的偏移数
    private var dataSource:[CalendarSectionData] = []               //一个数据是一个月份,一直是5个数据，从源数据来
    private var currentIndex:Int = -2                               //目前获取的数据下标,用于生产dataSource
    private var originDate:Date!                                    //初始日期
    private var direction:Int = 0                                   //滚动方向  0无滚动 1左翻 2右翻
    private var lastX:CGFloat = 0                                   //最后的x坐标，用来计算方向
    private var selectDay:Int = 0                                   //选择的日期的下标
    
    
    //Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        //滚动视图
        scrollV = UIScrollView()
        self.addSubview(scrollV);
        //翻页
        scrollV.isPagingEnabled = true;
        scrollV.showsVerticalScrollIndicator = false;
        scrollV.showsHorizontalScrollIndicator = false;
        scrollV.delegate = self;
        scrollV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        //创建集合数组
        for i in 0...4{
            //每个collectionView需要单独对应一个layout
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            layout.scrollDirection = .vertical;
            //需要一个单独的layout对应
            let collecV = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout);
            collecV.isPrefetchingEnabled = true;
            collecV.showsVerticalScrollIndicator = false;
            collecV.showsHorizontalScrollIndicator = false;
            collecV.backgroundColor = UIColor.white;
            collecV.delegate = self;
            collecV.dataSource = self;
            collecV.tag = i;
            collecV.register(CalendarCell.self, forCellWithReuseIdentifier: "cell");
            collections.append(collecV);
            scrollV.addSubview(collecV);
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews();
        let width = self.width;
        let height = self.height;
        for (i,view) in collections.enumerated() {
            view.frame = CGRect(x: CGFloat(i)*width, y: 0, width: width, height: height);
            view.reloadData();
        }
        scrollV.contentSize = CGSize(width: CGFloat(collections.count) * width, height: height);
        //滚动到中间，其实是第三个视图，总共排列5个
        scrollV.setContentOffset(CGPoint(x: width * 2, y: 0), animated: false);
        lastX = scrollV.contentOffset.x;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///Interface
    public func initData(date:Date){
        originDate = date;
        //从设置的起点开始
        for i in -2...2{
            let new = date.offsetMonthDate(i);
            originDatas[i] = CalendarDataSource.initData(new);
        }
        //生成数据
        generateData()
        //刷新
        refresh();
    }
    
    
    //手动调用滚动
    public func manualScroll(offset:Int){
        self.direction = offset;
        let width = self.width;
        if offset == 1 {
            self.scrollV.setContentOffset(CGPoint(x: width, y: 0), animated: true);
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.scrollViewDidEndDecelerating(self.scrollV);
            }
        }else if offset == 2{
            self.scrollV.setContentOffset(CGPoint(x: width*3, y: 0), animated: true);
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self.scrollViewDidEndDecelerating(self.scrollV);
            }
        }
    }
    
    
    
    //刷新
    private func refresh(){
        //勾选当前的数据
        let data = self.dataSource[2];
        delegate?.update(year: data.year, month: data.month);
        //是否有当日
        var today:Int = 0;
        for day in data.days {
            if day.isToday {
                today = day.day;break;
            }
        }
        //选择过日期，当前月越界则取最大值
        if selectDay != 0 && selectDay > data.daysCount{
            selectDay = data.daysCount;
        }
        if config.monthSelectDay > 0 {
            if (today > 0) {
                delegate?.choose(year: data.year, month: data.month, day: today,isToday: true);
            }else{
                selectDay = config.monthSelectDay;
                delegate?.choose(year: data.year, month: data.month, day: selectDay,isToday: false);
            }
        }else{
            if (today > 0) {
                delegate?.choose(year: data.year, month: data.month, day: today,isToday: true);
            }else{
                delegate?.choose(year: data.year, month: data.month, day: selectDay,isToday: false);
            }
        }
        
        for view in collections{
            //UICollectionView会自动生成相应cell的size，并缓存起来,提高性能,数据源改变需要清空
            view.collectionViewLayout.invalidateLayout();
            view.reloadData();
        }
    }
    
    
    //组装数据 0是起点
    private func generateData(){
        //字典无序
        var mi = 0;
        var ma = 0;
        for i in originDatas.keys{
            mi = min(mi,i);
            ma = max(ma,i);
        }
        if currentIndex < mi{
            for i in currentIndex...mi{
                if i < mi {
                    let new = originDate.offsetMonthDate(i);
                    originDatas[i] = CalendarDataSource.initData(new);
                }
            }
        }
        if currentIndex + 4 > ma{
            for i in ma...currentIndex+4{
                if i > ma {
                    let new = originDate.offsetMonthDate(i);
                    originDatas[i] = CalendarDataSource.initData(new);
                }
            }
        }
        //从currentIndex开始捞数据
        var result:[CalendarSectionData] = []
        for i in currentIndex...currentIndex+4{
            let data = originDatas[i];
            result.append(data!);
        }
        dataSource = result;
    }
    
    
    
    ///UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = self.width;
        if direction == 1 {
            currentIndex -= 1;
        }else if direction == 2{
            currentIndex += 1;
        }
        //有滚动
        if direction != 0 {
            scrollV.setContentOffset(CGPoint(x: width * 2, y: 0), animated: false);
            lastX = scrollView.contentOffset.x;
            generateData()//重新生产数据
            refresh();
        }
    }
    
    
    //开始滚动
    private func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
         direction = 0;
    }
    
    
    //判断方向
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = self.width;
        let x = scrollView.contentOffset.x;
        let sub = fabs(x-lastX);
        if x < lastX && sub > width/2.0 {
            direction = 1;
        }else if x > lastX && sub > width/2.0 {
            direction = 2;
        }
    }
    
    
    
    ///UICollectionView
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag >= dataSource.count {
            return 0;
        }
        let sectionData = dataSource[collectionView.tag];
        return sectionData.days.count;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CalendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell;
        let data = dataSource[collectionView.tag];
        let day = data.days[indexPath.row];
        cell.loadData(day,config: config,select: (day.day == selectDay && day.isCurrent));
        return cell;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 7.0, height: config.cellHeight);
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionData = dataSource[collectionView.tag];
        //选中的日子
        let data = sectionData.days[indexPath.row];
        selectDay = data.day;
        //是否要翻页
        let offset = sectionData.isCurrentMonth(indexPath.row);
        if offset == 0 {
            collectionView.reloadData();
            delegate?.choose(year: data.year, month: data.month, day: data.day,isToday: data.isToday);
        }else{
            //前后月份翻
            if config.showHeadTail {
                direction = offset;
                scrollViewDidEndDecelerating(scrollV);
            }
        }
    }
    

}



//日历上显示星期的条
public class CalendarBar:UIView{
    //Variable
    static let barHeight:CGFloat = 40                                                       //高度
    public var bgColor:UIColor = UIColor.colorRGB(red: 242, green: 244, blue: 246)          //背景颜色
    public var workColor:UIColor = UIColor.colorRGB(red: 143, green: 149, blue: 164)        //工作日颜色
    public var weekendColor:UIColor = UIColor.colorRGB(red: 246, green: 200, blue: 75)      //周末的颜色
    public var font:UIFont = kFont(14)                                                      //字体
    
    
    //使用配置构造界面
    public func makeConfig(){
        for sub in self.subviews{
            sub.removeFromSuperview();
        }
        self.backgroundColor = bgColor;         //背景色
        //星期
        let array = ["日","一","二","三","四","五","六"];
        var last:UIView!
        for (index,str) in array.enumerated(){
            let isWeekend = index == 0 || index == array.count-1;
            let label = UILabel.initText(str, font: font, textColor: isWeekend ? weekendColor : workColor, alignment: .center, super: self);
            label.mas_makeConstraints { (maker) in
                if last == nil {
                    maker?.left.mas_equalTo()(self);
                }else{
                    maker?.left.mas_equalTo()(last.mas_right);
                    maker?.width.mas_equalTo()(last);
                }
                maker?.top.bottom()?.mas_equalTo()(self);
                if index == array.count - 1 {
                    maker?.right.mas_equalTo()(self);
                }
            }
            last = label;
        }
    }
    
    
}



///日历视图与顶部条结合
public class CalenDarV:UIView{
    //Variable
    public var topBar:CalendarBar!                  //顶部条
    public var calendar:CalendarBaseV!              //日历本身
    
    
    //load
    override init(frame: CGRect) {
        super.init(frame: frame);
        //顶部条
        topBar = CalendarBar()
        self.addSubview(topBar);
        topBar.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.mas_equalTo()(self);
            maker?.height.mas_equalTo()(CalendarBar.barHeight);
        }
        topBar.makeConfig();
        //日历
        calendar = CalendarBaseV()
        self.addSubview(calendar);
        calendar.mas_makeConstraints { (maker) in
            maker?.left.bottom()?.right()?.mas_equalTo()(self);
            maker?.top.mas_equalTo()(topBar.mas_bottom);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
