//
//  BaiduMapView.swift
//  SHKit
//
//  Created by hsh on 2019/1/3.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///多路径多彩的路线显示
class BMKMulRouteView: UIView,BMKMapViewDelegate,RoutePlanDelegate {
    ///MARK-Variable
    public var mapView:BMKMapView!                  //百度地图
    public var routes:[BMKTrafficPolyline] = []     //带交通状态的路线
    public var lineWidth:CGFloat = 4                //线宽
    public weak var carAnimate:BMKCarAnimate?       //小车运动管理类-不设置就不会小车动画
    
    //图标
    public var startImage:UIImage? = UIImage.name("location_start")
    public var endImage:UIImage? = UIImage.name("location_end")
    public var carImage:UIImage? = UIImage.name("car")
    
    
    
    ///MARK-Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        //创建地图
        mapView = BMKMapUIService.getInitialMap();
        self.addSubview(mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        mapView.delegate = self;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///MARK-BMKMapViewDelegate
    //地图overlay绘制
    func mapView(_ mapView: BMKMapView!, viewFor overlay: BMKOverlay!) -> BMKOverlayView! {
        if (overlay.isKind(of: BMKPolyline.self)) {
            let polylineView = BMKPolylineView.init(overlay:overlay);
            
            let match:BMKTrafficPolyline? = self.matchingOvlay(overlay as! BMKPolyline)
            if match != nil{
                if (match!.polylineStrokeColors.count) > 0 {
                    polylineView?.colors = match?.polylineStrokeColors;
                }else{
                    polylineView?.loadStrokeTextureImages(match?.polylineTextureImages);
                }
            }
            polylineView?.lineWidth = lineWidth
            return polylineView;
        }
        return nil;
    }
    
    
    //对应的标记
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        if (annotation.isKind(of: BMKPointAnnotation.self)) {
            let reuse = "identifier";
            let anno:BMKPointAnnotation = annotation as! BMKPointAnnotation;
            var annoView:BMKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuse);
            if annoView == nil{
                annoView = BMKAnnotationView.init(annotation: anno, reuseIdentifier: reuse);
            }
            if anno.title == "起点" {
                annoView?.image = startImage;
                annoView?.centerOffset = CGPoint(x: 0, y:  -(startImage?.height() ?? 0)/4)
            }else if anno.title == "终点"{
                annoView?.image = endImage;
                annoView?.centerOffset = CGPoint(x: 0, y:  -(endImage?.height() ?? 0)/4)
            }else if anno.title == "car" {
                annoView?.image = carImage;
                //设置小车的动画标注
                carAnimate?.setCarAnnoView(annoView, mapView: self.mapView);
            }
            return annoView;
        }
        return nil;
    }
    
    
    //MARK-RoutePlanDelegate
    func addMultiTrafficRoute(traffic: BMKTrafficPolyline) {
        routes.append(traffic);
    }
    
    
    //清除上一次的路线结果
    func clearMultiTrafficeLines() {
        routes.removeAll();
    }
    
    
    //所有路线添加完毕
    func allLinesHasLoaded() {
        let firsetLine:BMKTrafficPolyline? = routes.first;
        if firsetLine != nil {
            //添加起点
            let startAnno = BMKPointAnnotation();
            startAnno.coordinate = firsetLine!.route.starting.location;
            startAnno.title = "起点"
            self.mapView.addAnnotation(startAnno);
            //终点
            let endAnno = BMKPointAnnotation()
            endAnno.coordinate = firsetLine!.route.terminal.location;
            endAnno.title = "终点"
            self.mapView.addAnnotation(endAnno);
            if carAnimate != nil{
                //添加车的位置
                let carAnno = BMKPointAnnotation()
                carAnno.title = "car";
                carAnno.coordinate = firsetLine!.route.starting.location;
                self.mapView.addAnnotation(carAnno);
            }
        }
    }
   
    
    ///MARK-Private
    //匹配对应的交通状态
    private func matchingOvlay(_ overlay:BMKPolyline)->BMKTrafficPolyline?{
        var result:BMKTrafficPolyline? = nil;
        for route in routes {
            if route.routeID == overlay.pointCount{
                result = route;
                break;
            }
        }
        return result;
    }
    
    
}
