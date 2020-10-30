//
//  MultiRoutePlanVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/20.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///多路径规划控制器

class MultiRoutePlanVC: UIViewController,AMapMultlRouteViewDelegate,AMapDriveNavDelegate,BottomInfoViewDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveDataRepresentable,AMapMathServiceDelegate {

    
    // MARK: - Variable
    private var bottomInfoView:BottomInfoView!      //底部选择栏
    private var mulRouteView:AMapMultiRouteView!    //多路径显示的地图
    
    
    // MARK: - Load
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        self.title = "多路径规划"
        //初始化地图
        initMapView()
        //初始化底部栏
        initBottomView()
        //初始化导航管理者
        initNavManager()
    }
    
    
    deinit {
        //释放单例
        mulRouteView.mapView.removeFromSuperview();
        AMapNaviDriveManager.destroyInstance()
    }
    
    
    //初始化地图
    private func initMapView()->Void{
        mulRouteView = AMapMultiRouteView()
        mulRouteView.delegate = self;
        mulRouteView.colorDelegate = self;
        self.view.addSubview(mulRouteView);
        mulRouteView .mas_makeConstraints { (maker) in
            maker?.top.left()?.bottom()?.right()?.mas_equalTo()(self.view);
        }
        AMapUIServise.setCustomMapStyle(pathStr: "style.data", styleID: nil)
    }
    
    
    //初始化底部栏
    private func initBottomView()->Void{
        self.bottomInfoView = BottomInfoView()
        self.bottomInfoView.delegate = self;
        self.view.addSubview(bottomInfoView);
        bottomInfoView.mas_makeConstraints { (maker) in
            maker?.bottom.left()?.right()?.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(200);
        }
        //初始界面
        let model = RouteInfoModel()
        model.routeTag = "请选择路线";
        self.bottomInfoView.setAllRouteInfo(allRouteInfo: [model]);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = false;
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.isToolbarHidden = true;
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        //初始化起终点
        let startPoint = AMapNaviPoint.location(withLatitude: 22.571133, longitude: 114.060750)
        let endPoint = AMapNaviPoint.location(withLatitude: 22.581524, longitude: 113.953821)
        mulRouteView.initPoints(start: startPoint!, end: endPoint!);
        mulRouteView.startRoutePlan()
    }
    
    
    
    private func initNavManager()->Void{
        AMapNaviDriveManager.sharedInstance().delegate = self;
       
        //增加用于展示导航数据的DataRepresentative
//        AMapNaviDriveManager.sharedInstance().addDataRepresentative(self);
        //设置模拟速度
        AMapNaviDriveManager.sharedInstance().setEmulatorNaviSpeed(60);
        //是否使用内置语音播报导航信息
        AMapNaviDriveManager.sharedInstance().isUseInternalTTS = true;
        
        //设置播报模式
        AMapNaviDriveManager.sharedInstance().setBroadcastMode(AMapNaviBroadcastMode.detailed);
    }
    
   
    
   
    
    
    // MARK: - Delegate
    func bottomInfoViewSelectedRouteWithRouteID(routeID: NSInteger) {
        mulRouteView.selectNavRouteID(routeID: routeID);
    }
    
    
    
    func bootomInfoViewStartNavWithRouteID(routeID: NSInteger) {
        let driveVC = AMapDriveNavigateVC()
        driveVC.delegate = self;
        //将driveView添加为导航数据的Representative，使其可以接收到导航数据
        if driveVC.driveView != nil{
             //增加用于展示导航数据的DataRepresentative.注意:该方法不会增加实例对象的引用计数(Weak Reference)
             AMapNaviDriveManager.sharedInstance().addDataRepresentative(driveVC.driveView!);
        }
        self.navigationController?.pushViewController(driveVC, animated: true);
        //开始模拟导航
        AMapNaviDriveManager.sharedInstance().startEmulatorNavi()
        //开始实时导航
//        AMapNaviDriveManager.sharedInstance().startGPSNavi();
    }
    
    
    // MARK: - MultlRouteViewDelegate
    //当前选中了某个路线
    public func selectRouteID(routeID: NSInteger) {
        self.bottomInfoView.selectNavRouteWithRouteID(routeID: routeID);
    }
    

    func setAllRouteInfoForChoose(allInfos: [RouteInfoModel]) {
        self.bottomInfoView.setAllRouteInfo(allRouteInfo: allInfos);
    }
    

    public func chooseRouteFailure() {
        
    }
    
    
    //返回不同状态对应的颜色-自定义
    func colorForStatus(status: AMapNaviRouteStatus) -> UIColor? {
        return nil;
    }
    
    
    //返回不同状态对应的图片纹理-自定义
    func textureForStatus(status: AMapNaviRouteStatus) -> UIImage? {
        return nil;
    }
    
    // MARK: - AMapNaviDriveManagerDelegate
    ///发生错误时,会调用代理的此方法
    func driveManager(_ driveManager: AMapNaviDriveManager, error: Error) {
        
    }
    
    
    ///驾车路径规划成功后的回调函数,请尽量使用 -driveManager:onCalculateRouteSuccessWithType:
    func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteSuccessWith type: AMapNaviRoutePlanType) {
        mulRouteView.needRoutePlan = false;
        mulRouteView.showMulNavRoutes()
    }
    
    
    ///驾车路径规划失败后的回调函数,从5.3.0版本起,算路失败后导航SDK只对外通知算路失败,SDK内部不再执行停止导航的相关逻辑.因此,当算路失败后,不会收到 driveManager:updateNaviMode: 回调; AMapDriveManager.naviMode 不会切换到 AMapNaviModeNone 状态, 而是会保持在 AMapNaviModeGPS or AMapNaviModeEmulator 状态.
    func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error, routePlanType type: AMapNaviRoutePlanType) {
        
    }
    
    
    ///启动导航后回调函数
    func driveManager(_ driveManager: AMapNaviDriveManager, didStartNavi naviMode: AMapNaviMode) {
        
    }
    
    
    ///出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
    func driveManagerNeedRecalculateRoute(forYaw driveManager: AMapNaviDriveManager) {
        
    }
    
    
    
    ///前方遇到拥堵需要重新计算路径时的回调函数.拥堵后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
    func driveManagerNeedRecalculateRoute(forTrafficJam driveManager: AMapNaviDriveManager) {
        mulRouteView.recalculateDriveRoute(strategy: AMapNaviDrivingStrategy.multipleAvoidCongestion)
    }
    
    
    ///导航到达某个途经点的回调函数
    func driveManager(_ driveManager: AMapNaviDriveManager, onArrivedWayPoint wayPointIndex: Int32) {
        
    }
    
    
    ///开发者请根据实际情况返回是否正在播报语音，如果正在播报语音，请返回YES, 如果没有在播报语音，请返回NO
    func driveManagerIsNaviSoundPlaying(_ driveManager: AMapNaviDriveManager) -> Bool {
        return SpeechSynthesizer.shareInstance.isSpeaking()
    }
    
    
    
    ///导航播报信息回调函数,此回调函数需要和driveManagerIsNaviSoundPlaying:配合使用
    func driveManager(_ driveManager: AMapNaviDriveManager, playNaviSound soundString: String, soundStringType: AMapNaviSoundType) {
        SpeechSynthesizer.shareInstance.speakString(words: soundString);
    }
    
    
    
    ///GPS导航到达目的地后的回调函数
    func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
        SpeechSynthesizer.shareInstance.speakString(words: "到达目的地")
    }
    
    
    ///模拟导航到达目的地后的回调函数
    func driveManagerDidEndEmulatorNavi(_ driveManager: AMapNaviDriveManager) {
        SpeechSynthesizer.shareInstance.speakString(words: "到达目的地")
    }
    
    
    //GPS信号强弱回调函数
    func driveManager(_ driveManager: AMapNaviDriveManager, update gpsSignalStrength: AMapNaviGPSSignalStrength) {
       //TODO弱的时候提示信号差
        SpeechSynthesizer.shareInstance.speakString(words: "当前信号差")
    }
    
    
    
    
    
    // MARK: - AMapNaviDriveDataRepresentable
    //导航信息更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviInfo: AMapNaviInfo?) {
        
    }
    
    
    //自车位置更新回调
    func driveManager(_ driveManager: AMapNaviDriveManager, update naviLocation: AMapNaviLocation?) {
        
    }
    
    
    // MARK: - DriveNavDelegate
    func driveNavClockBtnClick() {
        //停止导航,包含实时导航和模拟导航
        AMapNaviDriveManager.sharedInstance().stopNavi();
        SpeechSynthesizer.shareInstance.stopSpeak()
        self.navigationController?.popViewController(animated: true);
    }
    
}
