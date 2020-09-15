//
//  BaidurRoutePlan.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///路径规划类
@objc protocol RoutePlanDelegate:NSObjectProtocol {
    //添加一条路线
    func addMultiTrafficRoute(traffic:BMKTrafficPolyline)
    //每次规划前清空上次结果
    func clearMultiTrafficeLines()
    //添加完所有的路线
    func allLinesHasLoaded()
    //代理返回颜色
    @objc optional func defaultColorForStatus(num:NSNumber)->UIColor?
    //代理返回纹理
    @objc optional func defaultTextureForStatus(num:NSNumber)->UIImage?
}


///路径规划类
class BMKRoutePlan: NSObject,BMKRouteSearchDelegate{
    ///MARK-Variable
    private var routeSeach:BMKRouteSearch!          //路线搜索类
    private var mapView:BMKMapView!                 //百度地图
    private var routes:[BMKTrafficPolyline] = []    //带交通状态的路线
    
    ///UI
    public weak var delegate:RoutePlanDelegate?
    public var drawTexture:Bool = false;            //是否使用纹理
    public var desSelectTexture:UIImage? = UIImage.name("custtexture_gray") //非选中状态下的纹理

    
    
    ///MARK-Interface
    //驾乘路线规划
    public func driveRoutePlan(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D,ways:[CLLocationCoordinate2D]?,
                               policy:BMKDrivingPolicy)->Void{
        self.routeSeach = BMKRouteSearch()
        self.routeSeach.delegate = self;
        //创建路线规划选项
        let option = BMKDrivingRoutePlanOption()
        let from = BMKPlanNode()
        from.pt = start;
        let to = BMKPlanNode()
        to.pt = end;
        //起止点
        option.from = from;
        option.to = to
        //途径点
        if ways != nil {
            var waypoints:[BMKPlanNode] = []
            for coor in ways!{
                let p = BMKPlanNode()
                p.pt = coor;
                waypoints.append(p);
            }
           option.wayPointsArray = waypoints;
        }
        //路线优先级策略
        option.drivingPolicy = policy;
        //这个类型才有路线信息--带道路和路况
        option.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_PATH_AND_TRAFFICE;
        routeSeach.drivingSearch(option);
    }
    
    
    //设置配合的地图
    public func setAdaptMap(_ map:BMKMapView)->Void{
        self.mapView = map;
    }
    
    
    //选中某个路径
    public func selectedOverlayWithRoute(_ routeID:Int)->Void{
        if mapView == nil {
            return;
        }
        //遍历当前所有的overlay类
        for (index,value) in self.mapView.overlays.enumerated() {
            let overlay:BMKOverlay = value as! BMKOverlay;
            //如果是多彩线的
            if overlay.isKind(of: BMKPolyline.self){
                let selectOverlay:BMKPolyline = overlay as! BMKPolyline;
                //获取对应的render
                let renderView:BMKPolylineView = self.mapView.view(for: selectOverlay) as! BMKPolylineView;
                
                //当时是使用颜色绘制还是纹理
                if renderView.colors != nil && renderView.colors.count > 0 {
                    
                    //返回对应颜色
                    func changeColor(select:Bool)->[UIColor]{
                        var strokeColors:[UIColor] = [];
                        for color:UIColor in renderView.colors as! [UIColor]{
                            if select == true {
                                strokeColors.append(color.withAlphaComponent(1));
                            }else{
                                strokeColors.append(color.withAlphaComponent(0.3));
                            }
                        }
                        return strokeColors;
                    }
                    //判断是否是对应的线路
                    if selectOverlay.pointCount == routeID {
                        //修改选中的颜色
                        renderView.colors = changeColor(select: true);
                        //更改层级
                        self.mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(self.mapView.overlays.count-1))
                    }else{
                        renderView.colors = changeColor(select: false);
                    }
                }else{//使用纹理
                    func doNotSelectOverlayShow()->Void{
                        if desSelectTexture != nil{
                            renderView.loadStrokeTextureImages([desSelectTexture!]);
                        }else{
                            renderView.loadStrokeTextureImages([UIImage.init(color: UIColor.gray, rect: CGRect(x: 0, y: 0, width: 64, height: 64))]);
                        }
                    }
                    //选中的路线
                    if selectOverlay.pointCount == routeID {
                        for line in routes{
                            if line.routeID == routeID{
                                renderView.loadStrokeTextureImages(line.polylineTextureImages)
                                self.mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(self.mapView.overlays.count-1))
                            }
                        }
                    }else{
                        doNotSelectOverlayShow();
                    }
                }
            }
        }
    }
    
    
    ///MARK-BMKRouteSearchDelegate
    //返回驾乘路线信息
    func onGetDrivingRouteResult(_ searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
        if result != nil {
            let routes:[BMKDrivingRouteLine] = result?.routes as! [BMKDrivingRouteLine];
            if delegate != nil{
                delegate?.clearMultiTrafficeLines()
            }
            self.routes.removeAll();
            //添加所有路线
            for route in routes{
                self.calculPolylineUseStrokeColorWithRoute(route, texture: drawTexture);
            }
            //添加完所有路线通知
            delegate?.allLinesHasLoaded()
        }
    }
    
    
    ///计算并添加所有路线
    public func calculPolylineUseStrokeColorWithRoute(_ route:BMKDrivingRouteLine,texture:Bool)->Void{
        //所有路段
        let allSteps:[BMKDrivingStep] = route.steps as! [BMKDrivingStep];
        
        //暂存
        var coordIndexes = [NSNumber]()
        var colors:[UIColor] = []
        var textures:[UIImage] = []
        
        //计算出所有的路段点和
        var pointsCount:Int = 0
        for step in allSteps{
            pointsCount += Int(step.pointsCount);
        }
        let bmkPoints:UnsafeMutablePointer<BMKMapPoint> = UnsafeMutablePointer.allocate(capacity: pointsCount + 2);
        bmkPoints[0] = BMKMapPointForCoordinate(route.starting.location);
        coordIndexes.append(NSNumber.init(value: 0));
        
        var index = 1;
        var coorindex = 1;
        
        for step in allSteps {
            //多个点的交通状态-取出对应颜色
            let numbers:[NSNumber] = step.traffics as! [NSNumber]
            //多个坐标点
            let points:UnsafeMutablePointer<BMKMapPoint> = step.points;
            //分段个数
            let count = step.pointsCount;
            //对应的纹理和颜色
            var color:UIColor = self.defaultColorForStatus(num:10)
            var image:UIImage = self.defaultTextureForStatus(num: 10);
            //设置上一个点
            let lastPoint:UnsafeMutablePointer<BMKMapPoint> = UnsafeMutablePointer.allocate(capacity: 1);
            //循环内层
            for j in 0..<count{
                //有交通状况时
                if j < numbers.count{
                    color = self.defaultColorForStatus(num: numbers[Int(j)]);
                    image = self.defaultTextureForStatus(num: numbers[Int(j)]);
                    lastPoint[0] = points[Int(j)];
                }
                //坐标点
                bmkPoints[coorindex] = lastPoint[0];
                //颜色或纹理
                if texture == true{
                    textures.append(image);
                }else{
                    colors.append(color);
                }
                //下标
                coordIndexes.append(NSNumber.init(value: coorindex));
                
                coorindex += 1;
            }
            index += 1;
        }
        bmkPoints[pointsCount+1] = BMKMapPointForCoordinate(route.terminal.location);
        coordIndexes.append(NSNumber.init(value: pointsCount+1));
        
        //创建多彩线条
        let colorfulPolyline = BMKPolyline(points: bmkPoints, count: UInt(pointsCount+2), textureIndex: coordIndexes)
        self.mapView.add(colorfulPolyline);
        //返回给代理的数据
        let mulPolyline = BMKTrafficPolyline()
        mulPolyline.polyline = colorfulPolyline;
        mulPolyline.route = route;
        mulPolyline.polylineStrokeColors = colors;
        mulPolyline.polylineTextureImages = textures;
        mulPolyline.routeID = Int(colorfulPolyline!.pointCount)  //是否有相同数量的pointCount的时候，对应不上?
        mulPolyline.pointNum = UInt(pointsCount) + 2;
        mulPolyline.savePoint = bmkPoints;
        
        //保存数据
        self.routes.append(mulPolyline);
        if delegate != nil {
            delegate?.addMultiTrafficRoute(traffic: mulPolyline);
        }
        
    }
    
    
    //对应颜色
    private func defaultColorForStatus(num:NSNumber)->UIColor{
        let color:UIColor? = delegate?.defaultColorForStatus?(num: num);
        if color != nil {
            return color!
        }
        let status:Int = num.intValue;
        switch status {
        case 1:
            return UIColor.colorRGB(red: 65, green: 223, blue: 16)
        case 2:
            return UIColor.colorRGB(red: 248, green: 207, blue: 95)
        case 3:
            return UIColor.colorRGB(red: 216, green: 60, blue: 50)
        default:
            return UIColor.colorRGB(red: 97, green: 170, blue: 248)
        }
    }
    
    
    //返回对应的纹理
    private func defaultTextureForStatus(num:NSNumber)->UIImage{
        let image:UIImage? = delegate?.defaultTextureForStatus?(num: num);
        if image != nil {
            return image!
        }
        let status:Int = num.intValue;
        var imageName:String!;
        switch status {
        case 1:
            imageName = "custtexture_green"
        case 2:
            imageName = "custtexture_slow"
        case 3:
            imageName = "custtexture_serious"
        default:
            return UIImage.init(color: UIColor.colorRGB(red: 97, green: 170, blue: 248), rect: CGRect(x: 0, y: 0, width: 8, height: 8));
        }
        var finalImage:UIImage? = UIImage.name(imageName);
        if finalImage == nil {
            finalImage = UIImage.init(color: UIColor.colorRGB(red: 97, green: 170, blue: 248), rect: CGRect(x: 0, y: 0, width: 8, height: 8));
        }
        return finalImage!;
    }
    
    
}
