//
//  AMapPathTrackView.swift
//  SHKit
//
//  Created by hsh on 2018/12/27.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///轨迹类代理
public protocol AMapPathTrackViewDelegate :NSObjectProtocol {
    //路径规划成功后传下标点
    func calculRouteSuccess(coordinates:[CLLocationCoordinate2D])
}


///展示轨迹类--给一个起点和终点/给高德路径ID
public class AMapPathTrackView: UIView,MAMapViewDelegate,AMapNaviDriveManagerDelegate {
    /// MARK: -Variable
    public weak var delegate:AMapPathTrackViewDelegate?                      //代理
    public var lineWidth:CGFloat = 9;                                        //绘制的线宽
    public var grayColor = UIColor.colorRGB(red: 225, green: 225, blue: 225) //走过的路线的颜色
    public var carImage:UIImage? = UIImage.name("car")                       //小车的图片
    public var startImage:UIImage? = UIImage.name("location_start")          //起点的图片
    public var endImage:UIImage? = UIImage.name("location_end")              //终点的图片
    public var zoomLevel:CGFloat = 15                                        //放大level
    public var routeNum:[NSNumber] = []
    
    /// MARK: - Private
    private var mapView:MAMapView!                                           //内置的地图
    private var carAni:MAAnimatedAnnotation!                                 //车动画
    private weak var carView:MAAnnotationView!                               //车图标
    
    private var coordinates:[CLLocationCoordinate2D] = []                    //整个路线的所有点
    private var passedCoordinates:[CLLocationCoordinate2D] = []              //走过的路径
    
    private var passedTraceLine:MAPolyline!                                  //已经走过的路径
    private var passedTraceCoordIndex:Int = 0                                //已经经过的下标点
    private var passedLineAddIndex:Int = 0                                   //走过的路径添加的下标点-防重复
    
    private var curPoint:CLLocationCoordinate2D!                             //当前位置
    private var lastPoint:CLLocationCoordinate2D!                            //上一次的地点
    private var lastTime:TimeInterval = 0                                    //上次的时间
    private var zoomByUser:Bool = false                                      //用户改变了zoomlevel
    private var moveByUser:Bool = false                                      //用户移动了地图
    
    
    /// MARK: - Interface
    //初始化地图或传入地图
    public func initOrExchangeMap(map:MAMapView?)->Void{
        if (map != nil) {//传入要显示的地图
           self.mapView = map;
           self.mapView.delegate = self;
        }else{
            self.mapView = AMapUIServise.getInitialMap()
            self.mapView.delegate = self;
            self.addSubview(self.mapView)
            mapView.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
            }
        }
    }
    
    
    
    //更新当前点
    public func updateCurLocation(_ location:CLLocationCoordinate2D,maxTime:TimeInterval)->Void{
        //上一次的地点
        self.lastPoint = self.curPoint;
        //当前地点
        self.curPoint = location;
        //当前时间
        let curTime = Date().timeIntervalSince1970
        //时间间隔
        var span:TimeInterval = curTime - lastTime;
        //最小动画时长--最大的动画时长
        span = max(span,1);
        span = min(span,maxTime);
        lastTime = curTime;
        //选出目标数组
        var lastDistance:Double = 99999;
        var lastIndex = 0;
        var tmpArray = [CLLocationCoordinate2D]()
        //遍历数组里面的点
        for index in self.passedTraceCoordIndex ..< self.coordinates.count {
            let coordinate:CLLocationCoordinate2D = self.coordinates[index];
            //从之前的点到当前值越来越小，到当前点之后的值会越来越大
            let dis = AMapMathService.calculDistanceBetweenLocations(coordinate, locationB: curPoint);
            if (dis <= lastDistance){
                tmpArray.append(coordinate);
                lastIndex = index;//更新已经经过的点
            }else{
                break;
            }
            lastDistance = dis;
        }
        //之后要做的动画
        let count = tmpArray.count;
        if count < 2 {
            return;
        }
        self.passedTraceCoordIndex = lastIndex;
        self.passedLineAddIndex = 0;
        //做动画
        self.carAni.addMoveAnimation(withKeyCoordinates: &tmpArray, count: UInt(count), withDuration: CGFloat(span), withName: nil, completeCallback: { (isFinished) in
            
        }) { (annotation) in //添加灰色的线
            //当前走过了动画中的第几个点，下标1开始
            let index:Int = (annotation?.passedPointCount())!
            //添加整点
            if index != self.passedLineAddIndex {
                self.passedLineAddIndex = index;
                let coordinate = tmpArray[max(index-1,0)];//与passedPointCount相差一，以0开头
                self.passedCoordinates.append(coordinate);
                self.updatePassedTrace(locations:self.passedCoordinates);
            }else{
                //在两点之间的时候
                if annotation != nil && index <= tmpArray.count{
                    let rate = Double(annotation!.elapsedTime()) / Double(annotation!.duration());
                    let coordinate1 = tmpArray[index-1];
                    let coordinate2 = tmpArray[index];
                    let spanLat = coordinate2.latitude - coordinate1.latitude;
                    let spanLon = coordinate2.longitude - coordinate1.longitude;
                    let coordinate = CLLocationCoordinate2DMake(coordinate1.latitude+spanLat*rate, coordinate1.longitude+spanLon*rate);
                    
                    var final = self.passedCoordinates;
                    if rate > 0.9 {
                        final.append(coordinate2);
                    }
                    final.append(coordinate);
                    self.updatePassedTrace(locations:final);
                }
            }
        }
    
        //判断是否在地图中心，不再自动移动地图
        let centerCoordinate = self.carAni.coordinate;
        let regign:MACoordinateRegion = self.mapView.region;
        let mapCenter = self.mapView.centerCoordinate;
        var isInMapCenter = true;
        if (fabs(centerCoordinate.latitude - mapCenter.latitude) > regign.span.latitudeDelta ||
            fabs(centerCoordinate.longitude - mapCenter.longitude) > regign.span.longitudeDelta) {
            isInMapCenter = false
        }
        //当用户没有移动或者中心点已经不在可视范围内
        if moveByUser == false || isInMapCenter == false {
            self.mapView.setCenter(centerCoordinate, animated: true)
            moveByUser = false;
        }
        //用户移动过放大倍数就不再自动设置
        if zoomByUser == false {
            self.mapView.zoomLevel = self.zoomLevel;
        }
    }
    
    
    //传起始点和当前点，由起点做到当前点的动画
    public func startWithPoint(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D,cur:CLLocationCoordinate2D)->Void{
        self.curPoint = cur;
        //导航规划路径-得到所有的点
        AMapNaviDriveManager.sharedInstance().delegate = self;
        //是否允许后台定位
        AMapNaviDriveManager.sharedInstance().allowsBackgroundLocationUpdates = true;
        //指定定位是否会被系统自动暂停
        AMapNaviDriveManager.sharedInstance().pausesLocationUpdatesAutomatically = false;
        AMapNaviDriveManager.sharedInstance().setMultipleRouteNaviMode(false);
        //带起点的驾车路径规划
        AMapNaviDriveManager.sharedInstance().calculateDriveRoute(withStart: [AMapMathService.convertCllocationToAMapNavPoint(location: start)], end: [AMapMathService.convertCllocationToAMapNavPoint(location: end)], wayPoints: nil, drivingStrategy: AMapNaviDrivingStrategy.multipleAvoidHighwayAndCostAndCongestion);
    }
    
    
    
    //传入路径ID和当前点
    public func startWithRoute(routeID:NSNumber,cur:CLLocationCoordinate2D)->Void{
        self.curPoint = cur;
        selectRoute(routeID);
    }
    
    
    //选中某个路径
    public func selectRoute(_ routeID:NSNumber)->Void{
        //移除现有路线
        self.mapView.removeOverlays(self.mapView.overlays);
        self.addRoutePolylineUseStrokeColorsWithRouteID(routeID.intValue, textureEnable: false);
        if (AMapNaviDriveManager.sharedInstance().selectNaviRoute(withRouteID:routeID.intValue)) {
            self.selectedOverlayWithRouteID(routeID.intValue);
        }
    }
    
    
    /// MARK: - Private
    //更新灰色的轨迹
    private func updatePassedTrace(locations:[CLLocationCoordinate2D])->Void{
        var coordinates = locations;
        if self.carAni.isAnimationFinished() {
            return;
        }
        if self.passedTraceLine != nil {
            self.mapView.remove(self.passedTraceLine)
        }
        self.passedTraceLine = MAPolyline(coordinates: &coordinates, count: UInt(coordinates.count));
        self.mapView.add(passedTraceLine)
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
            polyline.polylineWidth = 20;
        }else{
            polyline.polylineStrokeColors = result.2
            polyline.polylineWidth = lineWidth
        }
        mapView.add(polyline, level: .aboveLabels)
        //初始化路径
        initRoute(AMapMathService.convertAMapNavPointsToCllocations(points: result.0));
        //添加起点终点
        self.addStartEndPoints(coordinates);
        //代理传值
        if delegate != nil {
            delegate?.calculRouteSuccess(coordinates: coordinates);
        }
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
    
    
    //初始化路线
    private func initRoute(_ coordinates:[CLLocationCoordinate2D])->Void{
        self.coordinates = coordinates;
        let count:Int = coordinates.count;
        var sum:Double = 0;
        //遍历每个路线
        for index in 0..<count - 1 {
            let begin = CLLocation(latitude: coordinates[index].latitude, longitude: coordinates[index].longitude);
            let end = CLLocation(latitude: coordinates[index + 1].latitude, longitude: coordinates[index + 1].longitude);
            let distance:CLLocationDistance = end.distance(from: begin);
            sum += distance;
        }
        //添加汽车大头针
        self.carAni = MAAnimatedAnnotation()
        self.carAni.coordinate = coordinates[0];
        self.mapView.addAnnotation(self.carAni);
        //先居中
        self.lastTime = Date().timeIntervalSince1970
        if coordinates.count > 0{
            self.mapView.setCenter(coordinates.first!, animated: true)
            self.mapView.zoomLevel = 17;
        }
    }
    
    
    
    //停止动画
    private func stop()->Void{
        for animation:MAAnnotationMoveAnimation in self.carAni.allMoveAnimations() {
            animation.cancel()
        }
        self.carAni.movingDirection = 0;
        self.carAni.coordinate = coordinates[self.passedTraceCoordIndex]
        self.passedLineAddIndex = 0;
        self.zoomByUser = false;
        if (self.passedTraceLine != nil) {
            self.mapView.remove(self.passedTraceLine)
            self.passedTraceLine = nil
        }
    }
    
    

    //设置路径遮罩层
    private func selectedOverlayWithRouteID(_ routeID:NSInteger)->Void{
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
                }else if (polylineRender?.isKind(of: MAMultiTexturePolylineRenderer.self) == true) {
                    //图像纹理类
                    let overlayRender:MAMultiTexturePolylineRenderer = polylineRender as! MAMultiTexturePolylineRenderer
                    selectOverLay.selected = true;
                    //修改选中的图片
                    overlayRender.strokeTextureImages = selectOverLay.polylineTextureImages;
                    let count:NSInteger = self.mapView.overlays.count - 1;
                    self.mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(count));
                    self.mapView.showOverlays([overlay], animated: true)
                }
                polylineRender?.glRender()
            }
        }
    }
    
    
    
    
    /// MARK: - AMapNaviDriveManagerDelegate
    //导航规划成功回调
    public func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
        //导航路线数量
        if ((AMapNaviDriveManager.sharedInstance().naviRoutes?.count)! <= 0){
            return;
        }
        //获取所有的路线ID
        routeNum.removeAll();
        for num in (AMapNaviDriveManager.sharedInstance().naviRoutes?.keys)! {
            routeNum.append(num);
        }
        if routeNum.count > 0 {
            selectRoute(routeNum.first!);
        }
    }
    
    
    
    /// MARK: - MAMapViewDelegate
    public func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if (annotation.isEqual(self.carAni)) {
            let reuseStr = "car"
            var annoView:MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseStr);
            if (annoView == nil) {
                annoView = MAAnnotationView(annotation: annotation, reuseIdentifier: reuseStr);
                annoView?.canShowCallout = true;
                annoView?.image = carImage;
                self.carView = annoView;
                self.carView.superview?.bringSubview(toFront: self.carView);
            }
            return annoView;
        }else if (annotation is MAPointAnnotation) {
            let reuseStr = "point";
            var annoView:MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseStr);
            if annoView == nil{
                annoView = MAAnnotationView(annotation: annotation, reuseIdentifier: reuseStr);
                annoView!.canShowCallout = true;
            }
            if annotation.title == "起点" {
                annoView?.image = startImage
                annoView?.centerOffset = CGPoint(x: 0, y:  -(startImage?.height())!/4)
            }
            if annotation.title == "终点" {
                annoView?.image = endImage
                annoView?.centerOffset = CGPoint(x: 0, y:  -(startImage?.height())!/4)
            }
            return annoView;
        }
        return nil;
    }
    
    
    //返回渲染器
    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if ((overlay as! MAPolyline) == self.passedTraceLine) {
            let render = MAPolylineRenderer(polyline: (overlay as! MAPolyline));
            render?.lineWidth = lineWidth+1;
            render?.strokeColor = self.grayColor;
            return render;
        }else if (overlay.isKind(of: AMapTrafficOverlay.self)) {
            let routeOverlay:AMapTrafficOverlay = overlay as! AMapTrafficOverlay
            
            if ((routeOverlay.polylineStrokeColors != nil) && routeOverlay.polylineStrokeColors.count > 0) {
                //使用.init仍然可以绘制出来
                let render:MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: routeOverlay)
                render.lineWidth = routeOverlay.polylineWidth;
                render.lineJoinType = kMALineJoinRound;
                render.strokeColors = routeOverlay.polylineStrokeColors
                render.isGradient = false;//颜色是否渐变
                render.fillColor = UIColor.white;
                return render;
            }else if (routeOverlay.polylineTextureImages != nil && routeOverlay.polylineTextureImages.count > 0) {
                //不可使用.init方法，绘制不出来
                let render:MAMultiTexturePolylineRenderer = MAMultiTexturePolylineRenderer(multiPolyline: routeOverlay);
                render.lineWidth = routeOverlay.polylineWidth;
                render.lineJoinType = kMALineJoinRound;
                render.strokeTextureImages = routeOverlay.polylineTextureImages;
                return render;
            }
        }
        return nil;
    }
    
    
    
    //用户改变zoomlevel，不再自动定位中心点
    public func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        if wasUserAction == true {
             zoomByUser = true
        }
    }
    
    
    //用户移动地图
    public func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if wasUserAction == true {
            moveByUser = true
        }
    }
    
    
}
