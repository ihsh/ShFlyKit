//
//  MainTabVC.swift
//  SHKit
//
//  Created by hsh on 2018/10/23.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import EventKitUI


class MainTabVC: UIViewController,SHPhoneAssetsToolDelegate,ItemsViewDelegate,TimeScrollBarDelegate,EKEventEditViewDelegate {
    //action数组
    var actionArr:[String]!
    var tool = SHPhoneAssetsTool()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SHKit"
        actionArr = ["地图","界面元素","OCR","健康","分享",
                     "web","频道选择","通讯录","取色器","图片取色",
                     "声波","画弧","应用评分","拍照","摄像",
                     "支付","二维码","安全验证","动画帧","地理位置",
                     "地铁线路","文字路径","日历","打印","视频",
                     "图表","音乐","订票","站点","付款码",
                     "扫码","立体相册","天气动画","涂鸦","弹窗","时间轴",
                     "系统信息","路径动画","日历日程"];
        self.initSubViews();
    }
    
    
    func objClickTitle(_ title: String) {
        if title == "地图" {
            let mapVC = MapViewController()
            self.navigationController?.pushViewController(mapVC, animated: true)
        }else if title == "界面元素"{
            let otherVC = OtherVC()
            self.navigationController?.pushViewController(otherVC, animated: true);
        }else if title == "OCR"{
            let vc = OcrTestVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "健康"{
            let vc = HealthTestVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "分享"{
            let vc = ShareDemoVC();
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "web"{
            let web = SHWebBaseVC.webInit(title: "零担首页", url: "http://baidu.com");
            self.navigationController?.pushViewController(web, animated: true);
        }else if title == "频道选择"{
            let vc = AnimateItemVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "通讯录"{
            let addressVC = SHAdressBookUI()
            self.navigationController?.pushViewController(addressVC, animated: true);
        }else if title == "取色器"{
            let colorVC = ColorWheelVC()
            self.navigationController?.pushViewController(colorVC, animated: true);
        }else if title == "图片取色"{
            let imageFetchVC = ImageColorFetchVC()
            self.navigationController?.pushViewController(imageFetchVC, animated: true);
        }else if title == "声波"{
            let waveVC = WaveLineVC()
            self.navigationController?.pushViewController(waveVC, animated: true);
        }else if title == "画弧"{
            let vc = UIViewCurveVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "应用评分"{
            AppScore .dialog("喜欢给个评价", reviewTitle: "去评价", noActionTitle: "继续逛逛", scoreTitle: "去评分", appID: "940562664")
        }else if title == "拍照"{
            tool.cameraPhotoAlert(vc: self);
            tool.delegate = self;
        }else if title == "摄像"{
            tool.cameraMovieAlert(vc: self);
            tool.delegate = self;
        }else if title == "支付"{
            let vc = QueryAnimateVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "二维码"{
            let vc = QRCodeVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "安全验证"{
            let vc = SecurityVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "动画帧"{
            let vc = GifFrameVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "地理位置"{
            let vc = LocationPickerVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "文字路径"{
            let vc = TextVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "地铁线路"{
            let vc = UIViewController()
            let view = MetrolLineV()
            vc.view.addSubview(view);
            view.mas_makeConstraints { (maker) in
                maker?.left.right()?.mas_equalTo()(vc.view);
                maker?.top.mas_equalTo()(vc.view)?.offset()(NavgationBarHeight()+StatusBarHeight());
                maker?.bottom.mas_equalTo()(vc.view);
            }
            view.loadLine(img: UIImage.name("shenzhen"));
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "日历"{
            let vc = CalendarVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "打印"{
            let vc = PrintTestVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "视频"{
            let vc = VedioVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "图表"{
            let vc = ChartVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "音乐" {
            let vc = TransVC();
            vc.showView = AudioPlayerUI()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "订票"{
            let vc = TransVC();
            let view = TicketBookingV();
            vc.showView = view;
            let info = TicketInfo.initSeatInfos(["1-1-0","1-2-0","1-3-0","1-4-0","1-5-0","1-6-0","1-7-0","1-8-0","1-9-0","1-10-0","1-11-0","1-12-0","1-13-0","1-14-0","1-15-0","1-15-0","2-1-0","2-2-0","2-2-0","2-3-0","2-4-0","2-5-0","2-6-0","2-7-0","2-8-0","2-9-0","2-10-0","2-11-0","2-12-0","2-13-0","2-14-0","2-15-0","3-1-0","3-2-0","3-3-0","3-4-0","3-5-0","3-6-0","3-7-0","3-8-0","3-9-0","3-10-0","3-11-0","3-12-0","3-13-0","3-14-0","3-15-0","4-0-0","4-5-0","4-6-0","4-7-0","4-8-0","4-9-0","4-10-1","4-11-0","4-12-0","4-13-0","4-14-0","4-15-0","4-16-0","4-16-0","5-4-0","5-5-1","5-6-1","5-7-0","5-8-0","5-9-1","5-10-0","5-11-0","5-12-0","5-13-0","5-14-1","5-15-0","5-16-0","6-6-0","6-9-0","6-7-0","6-8-0","6-10-1","6-11-0","6-12-0","6-13-0","6-14-0","6-15-0","6-16-0","7-6-0","7-7-0","7-8-0","7-9-0","7-10-0","7-11-0","7-12-0","7-13-0","7-14-0","7-15-0","7-16-0","8-7-0","8-8-0","8-9-0","8-10-0","8-11-0","8-12-0","8-13-0","8-14-0","8-15-0","8-16-0","9-9-0","9-10-0","9-11-0","9-12-0","9-13-0","9-14-0","9-15-0","9-16-0","10-7-0","10-8-0","10-9-0","10-10-0","10-11-0","10-12-0","10-13-0","10-14-0"])
            view.config.screen.screenText = "5号厅 银幕";
            view.initViewWithData(info);
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "站点"{
            let vc = TransVC();
            let view = TrainLinesV();
            vc.showView = view;
            let data = TrainStationData()
            data.limitColumn = 3;
            data.generate(stations: ["深圳北","惠州南","汕尾","揭阳","潮汕","云霄","漳州","厦门北","泉州","莆田","福清","福州南","宁德","温州南","绍兴","杭州东","桐庐","上海虹桥"], times: ["9:48","10:00"]);
            view .showStations(data);
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "付款码"{
            let vc = TransVC();
            vc.title = "付款";
            vc.navColorSame = true;
            vc.backColor = UIColor.randomColor();
            let view = PayCodeView()
            view.makeUI();
            vc.showView = view;
            vc.showRect = CGRect(x: 16, y: 30, width: ScreenSize().width-32, height: 450);
            view.payBankV.updateBankAndLogo("交通银行 信用卡 (0283)", logo: UIImage.name("ic_yinlian"))
            var str:String = String()
            for _ in 0...18{
                let num = arc4random()%10;
                str.append(String(format: "%ld", num));
            }
            view.updatePayCode(code: str, logo: nil)
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "扫码"{
            let vc = QRCodeRecognizerVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "立体相册"{
            let vc = SphereVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "天气动画"{
           
            let view = WeatherEffect();
            
            let vc = TransVC()
            vc.showView = view;
            vc.backColor = UIColor.randomColor();
            self.navigationController?.pushViewController(vc, animated: true);
            vc.showRect = CGRect(x: 0, y: 0, width: ScreenSize().width, height: ScreenSize().height/3.0*2.0);
        
            //闪电
            let thunderConfig = WeatherConfig.Thunder();
            view.thunderFlash(config: thunderConfig);
            //添加云
            view.addCloud(isRain: true, count: 11,mixColor: UIColor.black);
            view.rain(config: WeatherConfig.Rain());
            view.sunShine(config: WeatherConfig.Sun());
            let config = EmitterConfig()
            config.content = UIImage.name("rain");
            config.scale = 0.1;
            config.scaleRange = 0;
            config.position = CGPoint(x: ScreenSize().width/2.0, y: 75);
            view.showEmitter(config: config);

            let config2 = EmitterConfig()
            config2.content = UIImage.name("ele_snow");
            config2.scale = 0.3;
            config2.scaleRange = 0.3;
            config2.spin = 3;
            config2.position = CGPoint(x: ScreenSize().width/2.0, y: 75);
            view.showEmitter(config: config2);
        }else if title == "涂鸦"{
            let vc = HandBoardVC()
            self.navigationController?.pushViewController(vc, animated: true);
        }else if title == "弹窗"{
            
            let config = DiaLogConfig.initConfig(title: "温馨提示", msg: "确认退出", type: .ActionSheet, delegateView: nil, comfirm: DiaLogAction.initAction("确认", action: { (title) in
                
            }), cancel: DiaLogAction.initAction("取消", action: { (title) in
                
            }))
            config.touchDismiss = true;
            DiaLog.showAlert(config);
        }else if title == "时间轴"{
            let view = TimeScrollBar()
            view.delegate = self;
            let vc = TransVC();
            vc.backColor = .black;
            vc.showView = view;
            vc.showRect = CGRect(x: 0, y: 200, width: ScreenSize().width, height: 130);
            self.navigationController?.pushViewController(vc, animated: true);
            
            let model = TimeModel();
            model.day = "3.11";
            model.appendTimeSpan(start: 1583910000, end: 1583920000, width: (12*24-1)*view.scaleSpan);
            model.appendTimeSpan(start: 1583920100, end: 1583922300, width: (12*24-1)*view.scaleSpan);
            model.appendHitSpan(start: 1583910010, end: 1583911000, width: (12*24-1)*view.scaleSpan);
            let model2 = TimeModel();
            model2.day = "3.12";
            model2.appendTimeSpan(start: 1583910000, end: 1583920000, width: (12*24-1)*view.scaleSpan);
            model2.appendTimeSpan(start: 1583920100, end: 1583922300, width: (12*24-1)*view.scaleSpan);
            model2.appendHitSpan(start: 1583910010, end: 1583911000, width: (12*24-1)*view.scaleSpan);
            
            let model3 = TimeModel();
            model3.day = "实时";
            let calendar:NSCalendar = NSCalendar.current as NSCalendar;
            let date:NSDate = NSDate();
            let components:NSDateComponents = calendar.components([.day,.year,.month], from: date as Date) as NSDateComponents;
            let new:NSDate = calendar.date(from: components as DateComponents)! as NSDate;
            let dayBegin = new.timeIntervalSince1970;
            
            model3.appendTimeSpan(start: dayBegin + 3600 * 9, end: dayBegin + 3600 * 10, width: (12*24-1)*view.scaleSpan);
            model3.appendTimeSpan(start: dayBegin + 3600 * 11, end: dayBegin + 3600 * 11 + 500, width: (12*24-1)*view.scaleSpan);
            model3.appendHitSpan(start: dayBegin + 3600 * 11, end: dayBegin + 3600 * 11 + 100, width: (12*24-1)*view.scaleSpan);
            view.loadData(data: [model,model2,model3])
        }else if (title == "系统信息"){
            let vc = SystemInfoVC();
            self.navigationController?.pushViewController(vc, animated: true);
        }else if (title == "路径动画"){
            let view = UIView();
            let radiusV = RadiusPathAniView()
            radiusV.bloomRadius = 150;
            radiusV.initCenterImg(center: UIImage.name("chooser-button-tab"), hight: UIImage.name("chooser-button-tab-highlighted"));
            radiusV.addPathItem(norName: "chooser-moment-icon-music", hight: "chooser-moment-icon-music-highlighted",
                                backImg: "chooser-moment-button",hightBack: "chooser-moment-button-highlighted")
            radiusV.addPathItem(norName: "chooser-moment-icon-place", hight: "chooser-moment-icon-place-highlighted",
                                backImg: "chooser-moment-button",hightBack: "chooser-moment-button-highlighted")
            radiusV.addPathItem(norName: "chooser-moment-icon-camera", hight: "chooser-moment-icon-camera-highlighted",
                                backImg: "chooser-moment-button",hightBack: "chooser-moment-button-highlighted")
            radiusV.addPathItem(norName: "chooser-moment-icon-thought", hight: "chooser-moment-icon-thought-highlighted",
                                backImg: "chooser-moment-button",hightBack: "chooser-moment-button-highlighted")
            radiusV.addPathItem(norName: "chooser-moment-icon-sleep", hight: "chooser-moment-icon-sleep-highlighted",
                                backImg: "chooser-moment-button",hightBack: "chooser-moment-button-highlighted")
            view.addSubview(radiusV);
            
            let vc = TransVC()
            vc.showView = view;
            vc.backColor = UIColor.white;
            //轨迹路线动画
            let path = TrackPathView()
            view.addSubview(path);
            path.mas_makeConstraints { (make) in
                make?.center.mas_equalTo()(view);
                make?.width.height()?.mas_equalTo()(200);
            }
            path.drawPattern();
            self.navigationController?.pushViewController(vc, animated: true);
        }else if (title == "日历日程"){
            let handle = CalendarEventHandler()
//            handle.saveCalendar(title: "生产系统发布", location: "18:00，23楼-有成长会议室", note: "", start: Date().addingTimeInterval(120), durations: 300, alarmOffset: -60);
            handle.callEKEventEdit(holdVC: self);
          
        }
    }
    
    
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if action == EKEventEditViewAction.cancelled {
            self.dismiss(animated: true, completion: nil);
        }else if (action == EKEventEditViewAction.saved){
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    
    func scrollSelectTime(time: TimeInterval) {
        
    }
    
    
    func permissionDenyed(_ msg: String) {
        
    }
    
    
    func pickerVedio(_ url: URL) {
        let image = LiveMovieFrame.assetGetThumbImage(2, frame: 10, url: url)
        image?.savePhotoToAlbum();
    }
    
    
    private func initSubViews(){
        let scrollV = UIScrollView()
        self.view.backgroundColor = UIColor.white;
        self.view.addSubview(scrollV);
        scrollV.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.top.bottom()?.mas_equalTo()(self.view);
        }
        let item = ItemsView()
        item.delegate = self;
        let height = item.initBtns(col: 4, items: actionArr);
        item.frame = CGRect(x: 0, y: 0, width: ScreenSize().width, height: height);
        scrollV.addSubview(item);
        scrollV.contentSize = CGSize(width: 0, height: height);
    }
    
    
}
