//
//  AMapClusterView.swift
//  SHKit
//
//  Created by hsh on 2019/1/16.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit


///代理方法
protocol AMapClusterDelegate :NSObjectProtocol {
    //点击了标注点
    func didSelectCluster(annoView:MAAnnotationView)
    //返回点的显示
    func viewForAnnotation(_ anno:MAAnnotation)->MAAnnotationView?
}


///点聚合视图
class AMapClusterService: UIView , MAMapViewDelegate {
    ///MARK
    public var mapView:MAMapView!
    public weak var delegate:AMapClusterDelegate?
    
    private var coordinateTree:CoordinateQuadTree!              //四叉树
    private var shouldRegionChangeReCalculate:Bool!             //是否需要更新
    private let myQueue = DispatchQueue(label: "我的线程");       //线程
    
    
    ///MARK-Load
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.coordinateTree = CoordinateQuadTree()
        mapView = AMapUIServise.getInitialMap()
        self.addSubview(mapView);
        mapView.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///MARK-Interface
    public func buildClusterTree(_ res:[AMapClusterModel])->Void{
        objc_sync_enter(self);
        mapView.delegate = self;
        self.shouldRegionChangeReCalculate = false;
        //清理
        let annotations = NSMutableArray.init(array: self.mapView.annotations);
        annotations.remove(self.mapView.userLocation);
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
        let before:[MAAnnotation] = self.mapView?.annotations as? [MAAnnotation] ?? [];
        let after:[MAAnnotation] = annotations as! [MAAnnotation]
       
        var toAdd:[MAAnnotation] = [];
        var toRemove:[MAAnnotation] = [];
        //筛选数据
        var all:[MAAnnotation] = []
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
    private func addAnnotationsToMapView(_ map:MAMapView)->Void{
        objc_sync_enter(self);
        //执行的代码
        if self.coordinateTree.root == nil || self.shouldRegionChangeReCalculate == false {
            return;
        }
        //根据当前的zoomlevel和zoomScale进行annotation聚合
        let visibleRect:MAMapRect = self.mapView.visibleMapRect;
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
    
    
    //MARK-MAMapViewDelegate
    //区域改变重新计算
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        self.addAnnotationsToMapView(self.mapView);
    }
    
    
    //点击事件
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        delegate?.didSelectCluster(annoView: view);
    }
    
    
    //视图代理
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        //由代理设置
        if delegate != nil {
            let annoView:MAAnnotationView? = delegate?.viewForAnnotation(annotation);
            if annoView != nil {
                return annoView;
            }
        }
        if annotation.isKind(of: ClusterAnnotation.self) {
            let reuse = "clusterAnno"
            var annoView:AMapClusterAnnoView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: reuse) as? AMapClusterAnnoView;
            if annoView == nil{
                annoView = AMapClusterAnnoView.init(annotation: annotation, reuseIdentifier: reuse)
            }
            annoView?.annotation = annotation;
            let anno:ClusterAnnotation = annotation as! ClusterAnnotation;
            annoView?.label.text = "\(anno.count)"
            annoView?.canShowCallout = false;
            annoView?.bounds = CGRect(x: 0, y: 0, width: 30, height: 30);
            return annoView;
        }
        return nil;
    }
    
}
