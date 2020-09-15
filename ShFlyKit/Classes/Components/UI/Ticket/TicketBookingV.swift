//
//  TicketBookingV.swift
//  SHKit
//
//  Created by hsh on 2019/11/7.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//协议
protocol TicketBookingDelegate:NSObjectProtocol {
    //座位发生变化-当前选中的数量和发生变化的座位
    func seatsValueChanged(_ count:Int,seat:TicketSeatInfo)
    //达到最高座位限制-代理弹提示语
    func limitSelectCount(_ count:Int);
}


///订票视图
class TicketBookingV: UIView , UIScrollViewDelegate ,HeatBeatTimerDelegate {
    //Variable
    public weak var delegate:TicketBookingDelegate?
    public var config = TicketUIConfig()                    //视图的UI配置
    public private(set) var dataSource:TicketInfo!          //座位信息数据
    //视图
    public private(set) var scrollV:UIScrollView!           //座位所在的滚动视图
    public private(set) var zoomV:UIView!                   //实现缩放的视图-座位所在视图
    public private(set) var screenScroll:UIScrollView!      //屏幕视图需要使用的滚动视图
    public var headV:UIView!                                //示例视图
    public var screenV:UIView!                              //银幕视图
    public var indicaterV:IndicaterV!                       //指示条
    public var thumbnailV:UIView!                           //位置缩略图
    
    private var screenLayer:CAShapeLayer!                   //屏幕视图的CAShapeLayer
    private var zoneLayer:CAShapeLayer!                     //缩略图选择区域CAShapeLayer
    private var scrollLastTime:TimeInterval!                //滚动时间
    
    public var maxSelectCount:Int = 6                       //最多可一次购票张数
    public private(set) var maxHeight:CGFloat!              //最大的高度
    
    
    
    ///加载界面
    public func initViewWithData(_ data:TicketInfo)->CGFloat{
        //保存数据
        self.dataSource = data;
        //背景色
        self.backgroundColor = config.backColor;
        //滚动视图
        addScrollView(data: data);
        //添加头视图
        addHeadV();
        //银幕的视图
        addScreenView(data: data);
        //添加缩略图
        addThumbnailView(data: data);
        //返回这个视图的高度
        return maxHeight + config.scroll.topSpan;
    }
    
    
    
    ///获取已选位置数组
    public func getSelectSeats()->[TicketSeatInfo]{
        var tmp:[TicketSeatInfo] = [];
        for row in self.dataSource.rows {
            for seat in row.seats {
                if seat.status == .select {
                    tmp.append(seat);
                }
            }
        }
        return tmp;
    }
    
    
    
    //更新座位显示-自己实现推荐算法，并更新UI
    public func updateSeats(){
        for row in self.dataSource.rows {
            for seat in row.seats{
                setBtnSelect(seat.btn, seat: seat);
            }
        }
    }
    
    
    
    ///Delegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.isEqual(scrollV) {
            //重新绘制屏幕弧边
            let path = CGMutablePath();
            //限制宽度范围
            var width = config.screen.width * scrollView.zoomScale * config.screen.zoomRate;
            width = max(width,config.screen.width);
            width = min(width,config.screen.width + config.screen.zoomWidth);
            //限制y范围
            var y = scrollView.zoomScale * config.screen.curveY;
            y = min(y, config.screen.curveY + config.screen.zoomHeight);
            y = max(y,config.screen.curveY);
            //绘制路径
            let sub = (width-config.screen.width);
            path.move(to: CGPoint(x: 0-sub, y: y));
            path.addQuadCurve(to: CGPoint(x: width, y: y), control: CGPoint(x: width/2.0-sub, y: 0));
            //重新赋值路径
            screenLayer.path = path;
        }
    }
     
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView.isEqual(scrollV){
            return zoomV;
        }
        return nil;
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateScroll(scrollView, animate: false)
        thumbnailV.alpha = 1;
        scrollLastTime = Date().timeIntervalSince1970;
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateScroll(scrollView, animate: false)
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateScroll(scrollView, animate: false)
    }
    
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateScroll(scrollView, animate: true)
    }
    
    
    //HeatBeatTimerDelegate
    func timeTaskCalled(identifier: String) {
        let time = Date().timeIntervalSince1970;
        if scrollLastTime != nil {
            let sub = time - scrollLastTime;
            if sub > config.thumbnail.hideTimes {
                UIView.animate(withDuration: 0.3) {
                    self.thumbnailV.alpha = 0;
                }
            }
        }
    }
    
    
    ///Private
    private func updateScroll(_ scrollView:UIScrollView,animate:Bool){
        if scrollView.isEqual(scrollV) {
            //屏幕跟着滚动
            screenViewRecorectContentOffset(scrollView,animate: animate);
            //更新指示条
            indicaterUpdate(scrollView);
            //更新缩略图中的红线
            updateZoneLayer(dataSource, scrollView: scrollView);
        }
    }
    
    
    //重新更新屏幕的滚动跟随
    @objc private func screenViewRecorectContentOffset(_ scrollView:UIScrollView,animate:Bool){
        //放大后的中心X-原本的中心x
        let sub = (scrollView.zoomScale - 1)/2.0 * ScreenSize().width;
        //当前滚动视图的滚动X
        let offset = scrollView.contentOffset.x;
        //实际上滚动的距离
        let result = sub - offset;
        //屏幕跟着中轴线滚动
        screenScroll.setContentOffset(CGPoint(x: -result, y: 0), animated: animate);
    }
    
    
    //更新指示条的frame
    @objc private func indicaterUpdate(_ scrollView:UIScrollView){
        let scale = scrollView.zoomScale;
        let offsetY = scrollView.contentOffset.y;
        indicaterV.mas_updateConstraints { (maker) in
            maker?.height.mas_equalTo()(maxHeight*scale);
            maker?.top.mas_equalTo()(scrollV)?.offset()(-offsetY+config.scroll.yMargin);
        }
    }
    
    
    //按钮点击
    @objc private func btnClick(_ sender:UIButton){
        //获取对应的行列
        let tag = sender.tag;
        let row = tag / 100;
        let column = tag % 100;
        
        //继续勾选
        for tmp in self.dataSource.rows {
            //找到对应行
            if tmp.row == row {
                for seat in tmp.seats {
                    //找到对应位置
                    if seat.column == column {
                        //需要是非已售
                        if seat.status != .solded {
                            //滚动视图放大到指定比例
                            self.scrollV.setZoomScale(config.scroll.clickZoomScale, animated: true);
                            //往左右滚动一点
                            let count = self.dataSource.maxColumn % 2 == 0 ? self.dataSource.optimalColumn : self.dataSource.optimalColumn + 1;
                            if seat.column <= count - 1 {
                                self.scrollV.setContentOffset(CGPoint(x: 0, y: 0), animated: true);
                            }else if (seat.column >= count + 1)  {
                                let contentX = self.scrollV.contentSize.width;
                                let width = self.scrollV.width;
                                self.scrollV.setContentOffset(CGPoint(x: contentX - width, y: 0), animated: true);
                            }
                            //如果是要勾选的话
                            if seat.status == .availble {
                                //是否达到最大限制
                                if getSelectSeats().count >= maxSelectCount {
                                    delegate?.limitSelectCount(maxSelectCount);
                                    return;
                                }
                                seat.status = .select;
                            }else if (seat.status == .select){
                                seat.status = .availble;
                            }
                            //更新显示
                            self.setBtnSelect(sender, seat: seat);
                            //缩略图点选
                            for sub in self.thumbnailV.subviews {
                                if sub.tag == tag {
                                    //获取选择图片中像素点的颜色
                                    sub.backgroundColor = seat.status == .select ? config.thumbnail.selectColor : config.thumbnail.gridColor;
                                }
                            }
                            //通知代理
                            delegate?.seatsValueChanged(getSelectSeats().count, seat: seat);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    
    //设置按钮是否选中
    @objc private func setBtnSelect(_ btn:UIButton, seat:TicketSeatInfo){
        if seat.status == .solded {
            btn.setImage(config.image.soldImage, for: .normal);
        }else if seat.status == .select{
            btn.setImage(config.image.selectImage, for: .normal);
        }else{
            btn.setImage(config.image.norImage, for: .normal);
        }
    }
    
    
    //添加头视图
    private func addHeadV(){
        //创建按钮视图
        func createIndicaterBtn(title:String,super:UIView,index:Int)->UIView{
            let view = UIView()
            let btn = UIButton()
            btn.imageView?.contentMode = .scaleAspectFit;
            view.addSubview(btn);
            btn.mas_makeConstraints { (make) in
                make?.left.mas_equalTo()(view)?.offset()(6);
                make?.size.mas_equalTo()(CGSize(width: config.head.btnWidth, height: config.head.btnHeight));
                make?.centerY.mas_equalTo()(view);
            }
            let label = UILabel.initText(title, font: config.head.font, textColor: config.head.textColor, alignment: .center, super: view);
            label.mas_makeConstraints { (maker) in
                maker?.left.mas_equalTo()(btn.mas_right)?.offset()(3);
                maker?.centerY.mas_equalTo()(view);
            }
            if index == 0{
                let seat = TicketSeatInfo();
                seat.status = .availble;
                self.setBtnSelect(btn, seat: seat);
            }else if index == 1{
                let seat = TicketSeatInfo();
                seat.status = .solded;
                self.setBtnSelect(btn, seat: seat);
            }else{
                if config.image.bestZoneImage != nil {
                    btn.setImage(config.image.bestZoneImage, for: .normal);
                }else{
                    //画红色边框线
                    let zoneLayer = CAShapeLayer()
                    zoneLayer.bounds = btn.bounds;
                    zoneLayer.fillColor = UIColor.clear.cgColor;
                    zoneLayer.strokeColor = config.head.layerColor.cgColor;
                    zoneLayer.lineWidth = config.head.layerWidth;
                    zoneLayer.lineJoin = kCALineJoinRound;
                    zoneLayer.lineDashPattern = config.head.layerDash;
                    //虚线的路径
                    let zonePath = CGMutablePath();
                    zonePath.move(to: CGPoint(x:0, y:0));
                    zonePath.addLine(to: CGPoint(x: config.head.btnWidth-1, y: 0));
                    zonePath.addLine(to: CGPoint(x: config.head.btnWidth-1, y: config.head.btnHeight-1));
                    zonePath.addLine(to: CGPoint(x: 0, y: config.head.btnHeight-1));
                    zonePath.addLine(to: CGPoint(x: 0, y: 0));
                    zoneLayer.path = zonePath;
                    btn.layer.addSublayer(zoneLayer);
                }
            }
            super.addSubview(view);
            return view;
        }
        //头视图
        self.headV = UIView()
        self.headV.backgroundColor = config.backColor;
        self.addSubview(headV);
        headV.mas_makeConstraints { (maker) in
            maker?.left.right()?.top().mas_equalTo()(self);
            maker?.height.mas_equalTo()(config.head.height);
        }
        let norV = createIndicaterBtn(title: config.head.norText,super: self.headV,index: 0);
        let soldV = createIndicaterBtn(title: config.head.soldText,super: self.headV,index: 1);
        let goodV = createIndicaterBtn(title:  config.head.bestZoneText,super: self.headV,index: 2);
        //约束
        soldV.mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self.headV);
            make?.width.mas_equalTo()(config.head.subWidth);
        }
        norV.mas_makeConstraints { (make) in
            make?.right.mas_equalTo()(soldV.mas_left);
            make?.width.mas_equalTo()(config.head.subWidth);
            make?.centerY.mas_equalTo()(soldV);
        }
        goodV.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(soldV.mas_right);
            make?.width.mas_equalTo()(config.head.subWidth);
            make?.centerY.mas_equalTo()(soldV);
        }
    }

    
    
    //设置银幕视图
    private func addScreenView(data:TicketInfo){
        //添加滚动视图
        self.screenScroll = UIScrollView()
        screenScroll.backgroundColor = config.screen.backColor;
        self.addSubview(screenScroll);
        screenScroll.mas_makeConstraints { (make) in
            make?.left.right()?.mas_equalTo()(self);
            make?.top.mas_equalTo()(headV.mas_bottom);
            make?.height.mas_equalTo()(config.screen.scrollHeight);
        }
        self.screenV = UIView()
        screenScroll.addSubview(screenV);
        screenV.mas_makeConstraints { (make) in
            make?.centerX.top().mas_equalTo()(screenScroll);
            make?.height.mas_equalTo()(config.screen.height);
            make?.width.mas_equalTo()(config.screen.width);
        }
        //没有设置不显示
        if config.screen.screenText != nil {
            //添加弧线
            let layer = CAShapeLayer()
            layer.bounds = self.screenV.bounds;
            layer.fillColor = UIColor.clear.cgColor;
            layer.strokeColor = config.screen.layerColor.cgColor;
            layer.lineWidth = config.screen.layerWidth;
            layer.lineJoin = kCALineJoinRound;
            //添加阴影
            layer.shadowOffset = CGSize(width: 0, height: config.screen.shadowoOffset);
            layer.shadowRadius = config.screen.shadowRadius;
            layer.shadowColor = config.screen.layerColor.cgColor;
            layer.shadowOpacity = config.screen.shadowOpacity;
            //路径
            let path = CGMutablePath();
            path.move(to: CGPoint(x: 0, y: config.screen.curveY));
            path.addQuadCurve(to: CGPoint(x: config.screen.width, y: config.screen.curveY), control: CGPoint(x: config.screen.width/2.0, y: 0));
            layer.path = path;
            self.screenV.layer.addSublayer(layer);
            screenLayer = layer;
            //文字
            let title = UILabel.initText(config.screen.screenText, font: config.screen.font, textColor: config.screen.textColor, alignment: .center, super: screenV);
            title.mas_makeConstraints { (make) in
                make?.centerY.mas_equalTo()(screenV)?.offset()(config.screen.textYspan);
                make?.centerX.mas_equalTo()(screenV);
            }
        }
    }
    
    
    
    //添加滚动视图
    private func addScrollView(data:TicketInfo){
        self.scrollV = UIScrollView()
        self.scrollV.bounces = true;
        self.scrollV.delegate = self;
        self.scrollV.maximumZoomScale = config.scroll.maximumZoomScale;
        self.scrollV.minimumZoomScale = 1;
        self.scrollV.bouncesZoom = true;
        self.addSubview(scrollV);
        scrollV.mas_makeConstraints { (make) in
            make?.left.bottom().right()?.mas_equalTo()(self);
            make?.top.mas_equalTo()(self)?.offset()(config.scroll.topSpan);
        }
        //加载视图
        zoomV = UIView()
        maxHeight = 0;
        var maxOffset:CGFloat = 0;
        let width:CGFloat = (ScreenSize().width - CGFloat(data.maxColumn + 1) * config.scroll.xMargin) / CGFloat(data.maxColumn);
        for (rowIndex,info) in data.rows.enumerated() {
            //添加按钮
            for seat in info.seats {
                let btn = UIButton();
                btn.imageView?.contentMode = .scaleAspectFit;
                btn.tag = seat.row * 100 + seat.column;
                btn.showsTouchWhenHighlighted = false;
                btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside);
                btn.frame = CGRect(x: config.scroll.xMargin + (width + config.scroll.xMargin) * CGFloat(seat.column - 1),
                                   y: config.scroll.yMargin + (config.scroll.yMargin + width) * CGFloat(seat.row +  data.getOffsetRow(info.row) - 1),
                                   width: width,
                                   height: width);
                //按钮的状态
                self.setBtnSelect(btn, seat: seat);
                //捕获引用
                seat.btn = btn;
                zoomV.addSubview(btn);
                //计算出宽最大值
                maxOffset = max(maxOffset,config.scroll.xMargin + (width + config.scroll.xMargin) * CGFloat(seat.column));
            }
            //计算最高高度
            maxHeight = max(config.scroll.yMargin + (config.scroll.yMargin + width) * CGFloat(rowIndex+1)-config.scroll.yMargin,maxHeight);
        }
        zoomV.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: maxHeight)
        scrollV.addSubview(zoomV);
        //滚动视图的滚动范围
        scrollV.contentSize = CGSize(width: maxOffset, height: maxHeight);
        //画中间分割线
        let layer = CAShapeLayer()
        layer.bounds = self.bounds;
        layer.fillColor = UIColor.clear.cgColor;
        layer.strokeColor = config.scroll.separatorColor.cgColor;
        layer.lineWidth = config.scroll.separatorLineWidth;
        layer.lineJoin = kCALineJoinRound;
        layer.lineDashPattern = config.scroll.separatorlineDashPattern;
        //虚线的路径-放在最底下
        let path = CGMutablePath();
        path.move(to: CGPoint(x: maxOffset/2.0, y: config.scroll.yMargin));
        path.addLine(to: CGPoint(x: maxOffset/2.0, y: maxHeight));
        layer.path = path;
        self.zoomV.layer.addSublayer(layer);
        //画红色边框线
        let zoneLayer = CAShapeLayer()
        zoneLayer.bounds = self.bounds;
        zoneLayer.fillColor = UIColor.clear.cgColor;
        zoneLayer.strokeColor = config.scroll.zoneColor.cgColor;
        zoneLayer.lineWidth = config.scroll.zoneLineWidth;
        zoneLayer.lineJoin = kCALineJoinRound;
        zoneLayer.lineDashPattern = config.scroll.zonelineDashPattern;
        //红色边框虚线的路径
        let zonePath = CGMutablePath();
        //最优的列数
        let count = data.maxColumn % 2 == 0 ? data.optimalColumn : data.optimalColumn + 1;
        //x偏移
        let halfX = (width + config.scroll.xMargin) * CGFloat(count) / 2.0;
        let startY = (config.scroll.yMargin + width) * CGFloat(data.optimalRow - 1 + data.getOffsetRow(data.optimalRow)) + config.scroll.yMargin / 2.0;
        let offsetY = (width + config.scroll.yMargin) * CGFloat(data.optimalCount);
        //路径
        zonePath.move(to: CGPoint(x: maxOffset / 2.0 - halfX, y: startY));
        zonePath.addLine(to: CGPoint(x: maxOffset / 2.0 + halfX, y: startY));
        zonePath.addLine(to: CGPoint(x: maxOffset / 2.0 + halfX, y: startY + offsetY));
        zonePath.addLine(to: CGPoint(x: maxOffset / 2.0 - halfX, y: startY + offsetY));
        zonePath.addLine(to: CGPoint(x: maxOffset / 2.0 - halfX, y: startY));
        zoneLayer.path = zonePath;
        self.zoomV.layer.insertSublayer(zoneLayer, at: 0);
        //指示条
        indicaterV = IndicaterV.initWithTickets(data, maxHeight: maxHeight,config: config);
        self.addSubview(indicaterV);
        indicaterV.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(config.indicater.leftSpan);
            make?.top.mas_equalTo()(scrollV)?.offset()(-config.scroll.yMargin);
            make?.width.mas_equalTo()(width);
            make?.height.mas_equalTo()(maxHeight);
        }
    }

    
    
    //添加缩略图
    private func addThumbnailView(data:TicketInfo){
        //整个缩略图的宽高
        let width = CGFloat(data.maxColumn - 1) * config.thumbnail.xSpan + CGFloat(data.maxColumn) * config.thumbnail.grid + config.thumbnail.space * 2;        //间距 + 单元格 + 最左右间距
        let height = CGFloat(data.rows.count - 1) * config.thumbnail.ySpan + config.thumbnail.grid * CGFloat(data.rows.count) + config.thumbnail.space + config.thumbnail.topSpace; //间距 + 单元格 + 最底间距 + 顶部间距
        //添加视图
        self.thumbnailV = UIView()
        self.addSubview(thumbnailV);
        thumbnailV.backgroundColor = config.thumbnail.backColor;
        thumbnailV.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(config.thumbnail.viewLeftSpan);
            make?.top.mas_equalTo()(headV.mas_bottom);
            make?.width.mas_equalTo()(width);
            make?.height.mas_equalTo()(height);
        }
        
        for (row,info) in data.rows.enumerated() {
            //空行偏移
            var offsetRow = data.getOffsetRow(info.row);
            offsetRow = max(0,offsetRow-1);
            for seat in info.seats {
                let view = UIView();
                view.backgroundColor = seat.status == SeatStatus.solded ? config.thumbnail.soldColor : config.thumbnail.gridColor;
                view.layer.cornerRadius = config.thumbnail.cornerRadius;
                view.tag = seat.row * 100 + seat.column;
                view.layer.masksToBounds = true;
                view.frame = CGRect(x: (config.thumbnail.grid + config.thumbnail.xSpan) * CGFloat(seat.column - 1) + config.thumbnail.space,y: (config.thumbnail.ySpan + config.thumbnail.grid) * CGFloat(row + offsetRow) + config.thumbnail.topSpace,width: config.thumbnail.grid,height: config.thumbnail.grid);
                thumbnailV.addSubview(view);
            }
        }
        //画红色边框线
        let layer = CAShapeLayer()
        layer.bounds = self.thumbnailV.bounds;
        layer.fillColor = config.thumbnail.zoneFillColor.cgColor;
        layer.strokeColor = UIColor.clear.cgColor;
        //虚线的路径
        let path = CGMutablePath();
        //最优的列数
        let count = data.maxColumn % 2 == 0 ? data.optimalColumn : data.optimalColumn + 1;
        //x偏移
        let halfX = (config.thumbnail.grid + config.thumbnail.xSpan) * CGFloat(count) / 2.0;
        let startY = (config.thumbnail.ySpan + config.thumbnail.grid) * CGFloat(data.optimalRow - 1 + data.getOffsetRow(data.optimalRow)) + config.thumbnail.ySpan / 2.0 + config.thumbnail.topSpace - config.thumbnail.ySpan;
        let offsetY = (config.thumbnail.grid + config.thumbnail.ySpan) * CGFloat(data.optimalCount);
        //路径
        path.move(to: CGPoint(x: width / 2.0 - halfX, y: startY));
        path.addLine(to: CGPoint(x: width / 2.0 + halfX, y: startY));
        path.addLine(to: CGPoint(x: width / 2.0 + halfX, y: startY + offsetY));
        path.addLine(to: CGPoint(x: width / 2.0 - halfX, y: startY + offsetY));
        path.addLine(to: CGPoint(x: width / 2.0 - halfX, y: startY));
        layer.path = path;
        self.thumbnailV.layer.addSublayer(layer);
        //区域线
        self.zoneLayer = CAShapeLayer()
        zoneLayer.bounds = self.thumbnailV.bounds;
        zoneLayer.fillColor = UIColor.clear.cgColor;
        zoneLayer.strokeColor = config.screen.layerColor.cgColor;
        zoneLayer.lineWidth = 1;
        zoneLayer.lineJoin = kCALineJoinRound;
        self.thumbnailV.layer.addSublayer(zoneLayer);
        //添加定时器
        HeatBeatTimer.shared.addTimerTask(identifier: "ticket", span: 1, repeatCount: 0, delegate: self);
    }
    
    
    
    //更新缩略图的红色线区域
    private func updateZoneLayer(_ data:TicketInfo,scrollView:UIScrollView){
        //整个缩略图的宽高
        let width = CGFloat(data.maxColumn - 1) * config.thumbnail.xSpan + CGFloat(data.maxColumn) * config.thumbnail.grid + config.thumbnail.space * 2;        //间距 + 单元格 + 最左右间距
        let height = CGFloat(data.rows.count - 1) * config.thumbnail.ySpan + config.thumbnail.grid * CGFloat(data.rows.count) + config.thumbnail.space + config.thumbnail.topSpace; //间距 + 单元格 + 最底间距 + 顶部间距
        
        let zoneHeight = height - config.thumbnail.topSpace;    //区域的高度
        let scale = scrollView.zoomScale;                       //比例
        let offsetX = scrollView.contentOffset.x;
        let offsetY = scrollView.contentOffset.y;
        //计算出四个点
        let startX:CGFloat = max(0,offsetX/4.0);
        let endX:CGFloat = min(width,startX+min(width,width+(offsetX-config.thumbnail.xSpan)/4.0)/scale);
        let startY:CGFloat = max(config.thumbnail.topSpace + offsetY/5.0, config.thumbnail.topSpace);
        let endY:CGFloat = min(height,startY+zoneHeight);
        //可变路径
        let zonePath = CGMutablePath();
        //弧边
        zonePath.move(to: CGPoint(x: 20, y: 10));
        zonePath.addQuadCurve(to: CGPoint(x: width - 20, y: 10), control: CGPoint(x: width/2.0, y: 0));
        //区间
        zonePath.move(to: CGPoint(x: startX, y: startY));
        zonePath.addLine(to: CGPoint(x: endX, y: startY));
        zonePath.addLine(to: CGPoint(x: endX, y: endY));
        zonePath.addLine(to: CGPoint(x: startX, y: endY));
        zonePath.addLine(to: CGPoint(x: startX, y: startY));
        zoneLayer.path = zonePath;
    }
    

    
    ///指示条--定义为内部类--为了重写hitTest方法
    class IndicaterV: UIView {
    
        //视图初始化
        class public func initWithTickets(_ data:TicketInfo,maxHeight:CGFloat,config:TicketUIConfig)->IndicaterV{
            //左边指示条
            let view = IndicaterV();
            view.backgroundColor = config.indicater.backColor;
            view.alpha = config.indicater.alpha;
            view.layer.cornerRadius = config.indicater.cornerRadius;
            view.frame = CGRect(x: 0, y: 0, width: config.indicater.width, height: maxHeight);

            var last:UILabel!
            for (index,row) in data.rows.enumerated() {
                //支持空行
                let text = row.seats.count > 0 ? String(format: "%ld", row.row) : "";
                let label = UILabel.initText(text, font: config.indicater.font,
                                             textColor:config.indicater.textColor,
                                             alignment: .center, super: view);
                label.mas_makeConstraints { (make) in
                    make?.left.right()?.mas_equalTo()(view);
                    if last != nil{
                        make?.top.mas_equalTo()(last.mas_bottom);
                        make?.height.mas_equalTo()(last);
                    }else{
                        make?.top.mas_equalTo()(view);
                    }
                    if index == data.rows.count - 1 {
                        make?.bottom.mas_equalTo()(view);
                    }
                }
                last = label;
            }
            return view;
        }
     
        
        //想避开自己，点击能触发底下的按钮，需要在该视图里面写hitTest方法
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let hitView = super.hitTest(point, with: event);
            //如果点击在当前视图，则透过到下层
            if hitView?.isKind(of: type(of: self)) ?? false {
                return nil;
            }
            return hitView;
        }
    
        
    }
    
    
    
}






