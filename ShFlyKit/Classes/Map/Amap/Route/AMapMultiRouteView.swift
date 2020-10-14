//
//  MultiRouteView.swift
//  SHKit
//
//  Created by hsh on 2018/12/26.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///多路径视图代理
@objc protocol AMapMultlRouteViewDelegate : NSObjectProtocol {
    //返回所有的路径信息
    func setAllRouteInfoForChoose(allInfos:[RouteInfoModel]);
    //返回选择的路径ID
    func selectRouteID(routeID:NSInteger);
    //选择路径失败
    @objc optional func chooseRouteFailure();
}



///路线信息模型
class RouteInfoModel: NSObject {
    public var routeID:NSInteger = 0           //路线ID
    public var routeTime:NSInteger = 0         //路线时长
    public var routeTag:String?                //路线tag
    public var routeLength:NSInteger = 0       //路线长度
    public var trafficLightCount:NSInteger = 0 //红绿灯个数
}


///多路径展示视图
class AMapMultiRouteView: UIView,MAMapViewDelegate {
    /// MARK: - Variable
    public var mapView:MAMapView!                                           //高德地图
    public weak var delegate:AMapMultlRouteViewDelegate?                    //代理对象
    public weak var colorDelegate:AMapMathServiceDelegate?                  //颜色的代理对象
    
    public var textTureEnable:Bool = false                                  //启用图片纹理
    public var showMulLines:Bool = true                                     //是否显示多条路径
    public var wayPoints:[AMapNaviPoint] = []                               //可选路径规划途经点
    
    public var lineWidth:CGFloat = 10                                       //线段宽度
    public var startImage:UIImage? = UIImage.name("location_start")         //起点的图片
    public var endImage:UIImage? = UIImage.name("location_end")             //终点的图片
    public var deSelectTexture:UIImage? = UIImage.name("custtexture_gray")  //未选中的图片纹理
    
    public var needRoutePlan:Bool = false                                   //是否需要导航-程序使用变量-不要设置

    
    private var startPoint:AMapNaviPoint!                                   //起点
    private var endPoint:AMapNaviPoint!                                     //终点
    
    
    /// MARK: - Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        initMapView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initMapView()
    }
    
    private func initMapView()->Void{
        self.mapView = AMapUIServise.getInitialMap()
        self.addSubview(mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.top.left()?.bottom()?.right()?.mas_equalTo()(self);
        }
        self.mapView.delegate = self;
    }
    
    
    /// MARK: - Interface
    //初始化起点终点，可开始导航
    public func initPoints(start:AMapNaviPoint,end:AMapNaviPoint)->Void{
        self.startPoint = start;
        self.endPoint = end;
        self.needRoutePlan = true;
        if colorDelegate != nil {
            AMapMathService.shareInstance.delegate = colorDelegate
        }
    }
    
    
    //开始导航
    public func startRoutePlan()->Void{
        if self.needRoutePlan {
            self.routePlaceAction()
        }
    }
    
    
    //重新规划路径
    public func recalculateDriveRoute(strategy:AMapNaviDrivingStrategy)->Void{
        AMapNaviDriveManager.sharedInstance().recalculateDriveRoute(with: strategy);
    }
    
   
    //显示多条路径
    public func showMulNavRoutes()->Void{
        //导航路线数量
        if ((AMapNaviDriveManager.sharedInstance().naviRoutes?.count)! <= 0){
            return;
        }
        //移除现有路线
        self.mapView.removeOverlays(self.mapView.overlays);
        //设置为是否多路径模式
        AMapNaviDriveManager.sharedInstance().setMultipleRouteNaviMode(showMulLines);
        //创建路径数据
        var allInfoModels:[RouteInfoModel] = []
        //收集路线标签-例路径最短
        let tags:NSDictionary = createRouteTagsString();
        //遍历
        for aRouteID:NSNumber in (AMapNaviDriveManager.sharedInstance().naviRoutes?.keys)! {
            //路线信息
            let route:AMapNaviRoute = (AMapNaviDriveManager.sharedInstance().naviRoutes?[aRouteID]!)!
            //添加实时路况的polyline
            addRoutePlylineWithRouteID(routeID: aRouteID.intValue)
            //添加模型
            let model = RouteInfoModel()
            model.routeID  = aRouteID.intValue;
            model.routeTag = tags.object(forKey: aRouteID) as? String
            model.routeTime = route.routeTime;
            model.routeLength = route.routeLength;
            model.trafficLightCount = route.routeTrafficLightCount;
            allInfoModels.append(model);
            //只显示一条路线
            if showMulLines == false{
                break;
            }
        }
        //返回所有规划的路径信息
        if delegate != nil {
            delegate!.setAllRouteInfoForChoose(allInfos: allInfoModels);
        }
        //默认选择第一条路线
        let firstID:NSInteger = (allInfoModels.first?.routeID ?? 0);
        self.selectNavRouteID(routeID: firstID)
        //告知外界，选择了某条路径
        delegate?.selectRouteID(routeID: firstID);
    }
    
    
    //地图选中某条路径
    public func selectNavRouteID(routeID:NSInteger)->Void{
        //多路径规划时选择路径.注意:该方法仅限于在开始导航前使用,开始导航后该方法无效
        if (AMapNaviDriveManager.sharedInstance().selectNaviRoute(withRouteID: routeID)) {
            self.selectedOverlayWithRouteID(routeID: routeID);
        }else{//选择失败
            delegate?.chooseRouteFailure?()
        }
    }
    
    
    
    /// MARK: - Private Method
    //开始导航
    private func routePlaceAction()->Void{
        //是否允许后台定位
        AMapNaviDriveManager.sharedInstance().allowsBackgroundLocationUpdates = true;
        //指定定位是否会被系统自动暂停
        AMapNaviDriveManager.sharedInstance().pausesLocationUpdatesAutomatically = false;
        //巡航模式
        AMapNaviDriveManager.sharedInstance().detectedMode = .cameraAndSpecialRoad;
        //带起点的驾车路径规划
        AMapNaviDriveManager.sharedInstance().calculateDriveRoute(withStart: [startPoint], end: [endPoint], wayPoints: wayPoints, drivingStrategy: AMapNaviDrivingStrategy.multipleAvoidHighwayAndCostAndCongestion);
    }
    
    
    //添加路线
    private func addRoutePlylineWithRouteID(routeID:NSInteger)->Void{
        addRoutePolylineUseStrokeColorsWithRouteID(routeID,textureEnable: textTureEnable);
    }

    
    //设置路径遮罩层
    private func selectedOverlayWithRouteID(routeID:NSInteger)->Void{
        //遍历当前地图所有的overlays
        for (index,value) in self.mapView.overlays.enumerated() {
            let overlay:MAOverlay = value as! MAOverlay
            //如果是自定义的SelectableTrafficOverlay类
            if overlay.isKind(of: AMapTrafficOverlay.self) {
                let selectOverLay:AMapTrafficOverlay = overlay as! AMapTrafficOverlay
                //获取overlay对应的renderer
                let polylineRender = self.mapView.renderer(for: selectOverLay);
                //如果是颜色绘制类
                if (polylineRender?.isKind(of: MAMultiColoredPolylineRenderer.self) == true) {
                    let mulRender:MAMultiColoredPolylineRenderer = polylineRender as! MAMultiColoredPolylineRenderer
                    //选中的
                    if (selectOverLay.routeID == routeID) {
                        selectOverLay.selected = true;
                        //修改选中颜色
                        var strokeColors:[UIColor] = []
                        for color:UIColor in selectOverLay.polylineStrokeColors{
                            strokeColors.append(color.withAlphaComponent(1))
                        }
                        selectOverLay.polylineStrokeColors = strokeColors;
                        mulRender.strokeColors = selectOverLay.polylineStrokeColors;
                        //修改overlay覆盖的顺序
                        let count:NSInteger = self.mapView.overlays.count - 1;
                        self.mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(count));
                        //显示遮罩层
                        self.mapView.showOverlays([overlay], animated: true)
                    }else{
                        selectOverLay.selected = false;
                        //修改选中颜色
                        var strokeColors:[UIColor] = []
                        for color:UIColor in selectOverLay.polylineStrokeColors{
                            strokeColors.append(color.withAlphaComponent(0.3))
                        }
                        selectOverLay.polylineStrokeColors = strokeColors;
                        mulRender.strokeColors = selectOverLay.polylineStrokeColors
                    }
                }else if (polylineRender?.isKind(of: MAMultiTexturePolylineRenderer.self) == true) {
                    //图像纹理类
                    let overlayRender:MAMultiTexturePolylineRenderer = polylineRender as! MAMultiTexturePolylineRenderer
                    if (selectOverLay.routeID == routeID) {
                        selectOverLay.selected = true;
                        //修改选中的图片
                        overlayRender.strokeTextureImages = selectOverLay.polylineTextureImages;
                        let count:NSInteger = self.mapView.overlays.count - 1;
                        self.mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(count));
                        self.mapView.showOverlays([overlay], animated: true)
                    }else{
                        selectOverLay.selected = false;
                        //修改不选中的图片
                        if deSelectTexture != nil{
                            overlayRender.strokeTextureImages = [deSelectTexture!]
                        }
                    }
                }
                polylineRender?.glRender()
            }
        }
    }
    
    
    //收集路线标签
    private func createRouteTagsString()->NSDictionary{
        //计算出多条路线的最小值
        var minTime = NSIntegerMax;
        var minLength = NSIntegerMax;
        var minTrafficLightCount = NSIntegerMax;
        var minCost = NSIntegerMax;

        for route:AMapNaviRoute in (AMapNaviDriveManager.sharedInstance().naviRoutes?.values)! {
            minTime = min(minTime,route.routeTime)
            minLength = min(minLength,route.routeLength);
            minTrafficLightCount = min(minTrafficLightCount,route.routeTrafficLightCount);
            minCost = min(minCost,route.routeTollCost)
        }

        let resultDict = NSMutableDictionary()
        var index:NSInteger = 0;
        for route:AMapNaviRoute in (AMapNaviDriveManager.sharedInstance().naviRoutes?.values)! {
            var tagStr = ""
            if route.routeLength <= minLength {
                tagStr = "距离最短"
            }else if route.routeTime <= minTime {
                tagStr = "时间最短"
            }else if (route.routeTrafficLightCount <= minTrafficLightCount) {
                tagStr = "红绿灯少"
            }else if route.routeTollCost <= minCost {
                tagStr = "收费较少"
            }
            resultDict.setObject(tagStr, forKey:NSNumber.init(value: index))
            index += 1;
        }
        return resultDict;
    }
    
    
   
    //创建多彩polyline
    private func addRoutePolylineUseStrokeColorsWithRouteID(_ routeID: Int,textureEnable:Bool) {
        let result = AMapMathService.calculPolylineUseStrokeColorsWithRouteID(routeID, textureEnable: textureEnable);
        //添加Polyline
        var coordinates = Array<CLLocationCoordinate2D>()
        for aCoordinate in result.0 {
            coordinates.append(CLLocationCoordinate2DMake(CLLocationDegrees(aCoordinate.latitude), CLLocationDegrees(aCoordinate.longitude)))
        }
        guard let polyline = AMapTrafficOverlay(coordinates: &coordinates, count: UInt(coordinates.count), drawStyleIndexes: result.1) else {
            return
        }
        polyline.routeID = routeID
        polyline.selected = false           //初始状态为未选中
        if textureEnable {
            polyline.polylineTextureImages = result.3;
            polyline.polylineWidth = 2*lineWidth;
        }else{
            polyline.polylineStrokeColors = result.2
            polyline.polylineWidth = lineWidth
        }
        mapView.add(polyline, level: .aboveRoads)
        //添加起点终点
        addStartEndPoints(coordinates);
    }
 
    
    //添加起点终点
    private func addStartEndPoints(_ coordinates:[CLLocationCoordinate2D])->Void{
        if startImage != nil && coordinates.first != nil {
            let startAnno:MAPointAnnotation = MAPointAnnotation()
            startAnno.coordinate = coordinates.first!;
            startAnno.title = "起点"
            self.mapView.addAnnotation(startAnno);
        }
        if endImage != nil && coordinates.last != nil {
            let endAnno:MAPointAnnotation = MAPointAnnotation()
            endAnno.coordinate = coordinates.last!;
            endAnno.title = "终点"
            self.mapView.addAnnotation(endAnno);
        }
    }
    
    
    //返回Annotation
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation is MAPointAnnotation) {
            let reuseStr = "point";
            var annoView:MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseStr);
            if annoView == nil{
                annoView = MAAnnotationView(annotation: annotation, reuseIdentifier: reuseStr);
                annoView!.canShowCallout = true;
            }
            if annotation.title == "起点" {
                annoView?.image = startImage
                annoView?.centerOffset = CGPoint(x: 0, y:  -(startImage?.height() ?? 0)/4)
            }
            if annotation.title == "终点" {
                annoView?.image = endImage
                annoView?.centerOffset = CGPoint(x: 0, y:  -(endImage?.height() ?? 0)/4)
            }
            return annoView;
        }
        return nil;
    }
    
    
    
    //返回对应的render
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if (overlay.isKind(of: AMapTrafficOverlay.self)) {
            let routeOverlay:AMapTrafficOverlay = overlay as! AMapTrafficOverlay
            
            if ((routeOverlay.polylineStrokeColors != nil) && routeOverlay.polylineStrokeColors.count > 0) {
                let render:MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: routeOverlay)//使用.init仍然可以绘制出来
                render.lineWidth = routeOverlay.polylineWidth;
                render.lineJoinType = kMALineJoinRound;
                render.strokeColors = routeOverlay.polylineStrokeColors
                render.isGradient = false;//颜色是否渐变
                render.fillColor = UIColor.white;
                return render;
            }else if (routeOverlay.polylineTextureImages != nil && routeOverlay.polylineTextureImages.count > 0) {
                let render:MAMultiTexturePolylineRenderer = MAMultiTexturePolylineRenderer(multiPolyline: routeOverlay);//不可使用.init方法，绘制不出来
                render.lineWidth = routeOverlay.polylineWidth;
                render.lineJoinType = kMALineJoinRound;
                render.strokeTextureImages = routeOverlay.polylineTextureImages;
                return render;
            }
        }
        return nil
    }
    
}
