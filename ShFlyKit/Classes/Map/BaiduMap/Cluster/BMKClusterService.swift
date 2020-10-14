//
//  BMKClusterService.swift
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///代理方法
protocol BMKClusterDelegate :NSObjectProtocol {
    //点击了点
    func didSelectCluster(annoView:BMKAnnotationView)
    //返回点的显示
    func viewForAnnotation(_ anno:BMKAnnotation)->BMKAnnotationView?
}


///点聚合控制类
class BMKClusterService: UIView,BMKMapViewDelegate {
    ///MARK
    public var mapView:BMKMapView!
    public weak var delegate:BMKClusterDelegate?
    
    private var coordinateTree:BMKCoordinateQuadTree!           //四叉树
    private var shouldRegionChangeReCalculate:Bool!             //是否需要更新
    private let myQueue = DispatchQueue(label: "我的线程");       //线程
    
    
    ///Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.coordinateTree = BMKCoordinateQuadTree()
        mapView = BMKMapUIService.getInitialMap()
        self.addSubview(mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        mapView.delegate = self;
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    ///MARK-Interface
    public func buildClusterTree(_ res:[BMKClusterModel])->Void{
        objc_sync_enter(self);
        self.shouldRegionChangeReCalculate = false;
        //清理
        let annotations = NSMutableArray.init(array: self.mapView.annotations);
        annotations.remove(self.mapView);
        self.mapView.removeAnnotations(annotations as? [Any]);
        
        myQueue.async {
            //初始化数据
            self.coordinateTree.build(withPOIs: res);
            self.shouldRegionChangeReCalculate = true;
            DispatchQueue.main.async {
                //更新
                self.addAnnotationsToMapView(self.mapView);
            }
        }
        objc_sync_exit(self);
    }
    
    
    
    ///MARK--Private
    //更新标注
    private func updateMapAnnotations(_ annotations:NSArray)->Void{
        //用户滑动时保留仍然可用的标注，移除屏幕外标注，添加新增u区域的标注
        let before:[BMKAnnotation] = self.mapView?.annotations as? [BMKAnnotation] ?? [];
        let after:[BMKAnnotation] = annotations as! [BMKAnnotation]
        
        var toAdd:[BMKAnnotation] = [];
        var toRemove:[BMKAnnotation] = [];
        //筛选数据
        var all:[BMKAnnotation] = []
        all.append(contentsOf: before);
        all.append(contentsOf: after);
        
        for anno in all {
            var beforeHas:Bool = false;
            var afterHas:Bool = false;
            for be in before{
                if anno.isEqual(be){
                    beforeHas = true;
                    break;
                }
            }
            for af in after{
                if anno.isEqual(af){
                    afterHas = true;
                    break;
                }
            }
            //最后决定是否添加
            if beforeHas == true && afterHas == false{
                toRemove.append(anno);//需要移除的
            }else if (beforeHas == false && afterHas == true){
                toAdd.append(anno);   //需要添加的
            }
        }
        //更新
        DispatchQueue.main.async {
            self.mapView.addAnnotations(toAdd);
            self.mapView.removeAnnotations(toRemove)
        }
    }
    
    
    
    //找出需要更新的标注
    private func addAnnotationsToMapView(_ map:BMKMapView)->Void{
        objc_sync_enter(self);
        //执行的代码
        if self.coordinateTree.root == nil || self.shouldRegionChangeReCalculate == false {
            return;
        }
        //根据当前的zoomlevel和zoomScale进行annotation聚合
        let visibleRect:BMKMapRect = self.mapView.visibleMapRect;
        let zoomScale:Double = Double(self.mapView.bounds.size.width) / visibleRect.size.width;
        let zoomLevel:Double = Double(self.mapView?.zoomLevel ?? 17);
        
        let group = DispatchGroup()
        myQueue.async(group: group, qos: .default, flags: []) {
            let annotations = self.coordinateTree.clusteredAnnotations(within: visibleRect, withZoomScale: zoomScale, andZoomLevel: zoomLevel);
            DispatchQueue.main.async {
                //更新
                self.updateMapAnnotations(annotations! as NSArray);
            }
        }
        objc_sync_exit(self);
    }
    
    
    //地区区域改变
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        self.addAnnotationsToMapView(self.mapView);
    }
    
    
    //地图选中某个标注
    func mapView(_ mapView: BMKMapView!, didSelect view: BMKAnnotationView!) {
        delegate?.didSelectCluster(annoView: view);
    }
    
    
    //返回标注点
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        //给代理一次机会返回标注点
        if delegate != nil {
            let annoView:BMKAnnotationView? = delegate?.viewForAnnotation(annotation);
            if annoView != nil {
                return annoView;
            }
        }
        if annotation.isKind(of: BMKClusterAnno.self) {
            let reuse = "clusterAnno"
            var annoView:BMKClusterAnnoView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: reuse) as? BMKClusterAnnoView;
            if annoView == nil{
                annoView = BMKClusterAnnoView.init(annotation: annotation, reuseIdentifier: reuse)
            }
            annoView?.annotation = annotation;
            let anno:BMKClusterAnno = annotation as! BMKClusterAnno;
            annoView?.label.text = "\(anno.count)"
            annoView?.canShowCallout = false;
            annoView?.bounds = CGRect(x: 0, y: 0, width: 30, height: 30);
            return annoView;
        }
        return nil;
    }
    
}
