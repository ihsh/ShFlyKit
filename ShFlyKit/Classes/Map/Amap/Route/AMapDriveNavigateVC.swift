//
//  DriveNavigateVC.swift
//  SHKit
//
//  Created by hsh on 2018/12/17.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit
import Masonry
/*使用方法-当选中好路径，点击开始，在控制器中使用下面代码就可以
     let driveVC = AMapDriveNavigateVC()
     driveVC.delegate = self;
     //将driveView添加为导航数据的Representative，使其可以接收到导航数据
     if driveVC.driveView != nil{
         //增加用于展示导航数据的DataRepresentative.注意:该方法不会增加实例对象的引用计数(Weak Reference)
         AMapNaviDriveManager.sharedInstance().addDataRepresentative(driveVC.driveView!);
     }
     self.navigationController?.pushViewController(driveVC, animated: true);
 */


@objc protocol AMapDriveNavDelegate : NSObjectProtocol {
    //关闭导航
    func driveNavClockBtnClick()
    //点击更多按钮
    @objc optional func driveNavMoreBtnClick()
}

///驾驶控制器界面

class AMapDriveNavigateVC: UIViewController,AMapNaviDriveViewDelegate {
    /// MARK: - Variable
    public weak var delegate:AMapDriveNavDelegate?      //驾驶控制器的代理对象
    public var driveView:AMapNaviDriveView?             //驾车导航界面--有很多默认设置为YES
    
    
    /// MARK: - Load
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        //初始化导航视图
        initDriveView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initDriveView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true;
        self.navigationController?.isToolbarHidden = true;
    }


    /// MARK: - Private
    private func initDriveView()->Void{
        self.driveView = AMapNaviDriveView()
        self.driveView!.trackingMode = .carNorth;       //车头超北
        self.driveView!.delegate = self;
        self.driveView!.autoSwitchDayNightType = true;  //自动切换日夜
        self.driveView!.showGreyAfterPass = true;       //走过的路线变灰色
        
        self.driveView!.showScale = true;               //显示比例尺
        self.driveView!.autoZoomMapLevel = true;        //锁车模式下是否为了预见下一导航动作自动缩放地图,默认为NO
        
        self.view.addSubview(self.driveView!);
        driveView!.mas_makeConstraints { (maker) in
            maker?.left.right()?.top()?.bottom()?.mas_equalTo()(self.view);
        }
    }
   
    
    
    //MARK - Interface
    public func setImages(start:UIImage?,end:UIImage?,car:UIImage?)->Void{
        if start != nil{
            self.driveView!.setStartPointImage(start);
        }
        if end != nil{
            self.driveView!.setEndPointImage(end);
        }
        if car != nil {
            //设置自车图标
            self.driveView!.setCarImage(car);
        }
    }
    
    
    
    
    // MARK: - AMapDriveDelegate
    ///导航界面关闭按钮点击时的回调函数
    func driveViewCloseButtonClicked(_ driveView: AMapNaviDriveView) {
        delegate?.driveNavClockBtnClick()
    }

    
    ///导航界面转向指示View点击时的回调函数
    func driveViewTrunIndicatorViewTapped(_ driveView: AMapNaviDriveView) {
        if self.driveView!.showMode == .carPositionLocked {
            self.driveView!.showMode = .normal;
        }else if (self.driveView!.showMode == .normal) {
            self.driveView!.showMode = .overview;
        }else if (self.driveView!.showMode == .overview){
            self.driveView!.showMode = .carPositionLocked;
        }
    }
    
    
    
    ///导航界面更多按钮点击时的回调函数
    func driveViewMoreButtonClicked(_ driveView: AMapNaviDriveView) {
        delegate?.driveNavMoreBtnClick?()
    }
    
}







enum NaviPointAnnotationType{
    case Start,Way,End
}



//自定义的Annotation
class NaviPointAnnotation: MAPointAnnotation {
    public var navPointType:NaviPointAnnotationType!
}

