//
//  AMapMathService.swift
//  SHKit
//
//  Created by hsh on 2018/12/28.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AMapNaviKit
import UIKit


///代理返回路况颜色，纹理
@objc public protocol AMapMathServiceDelegate : NSObjectProtocol {
    //由代理返回颜色
    @objc optional func colorForStatus(status:AMapNaviRouteStatus)->UIColor?
    //由代理返回图片纹理
    @objc optional func textureForStatus(status:AMapNaviRouteStatus)->UIImage?
}


///高德计算服务类
public class AMapMathService: NSObject {
    /// MARK: - Variable
    static let shareInstance = AMapMathService.init()       //服务类单例
    public weak var delegate:AMapMathServiceDelegate?       //服务类的代理对象
    
    
   /// MARK: - Interface
   //根据高德的路线ID生成路径
   class public func calculPolylineUseStrokeColorsWithRouteID(_ routeID:Int,
                                                              textureEnable:Bool)->([AMapNaviPoint],[NSNumber],[UIColor],[UIImage]){
        //必须选中路线后，才可以通过driveManager获取实时交通路况
        if !AMapNaviDriveManager.sharedInstance().selectNaviRoute(withRouteID: routeID) {
            return ([],[],[],[])
        }
        //获取路线
        guard let aRoute = AMapNaviDriveManager.sharedInstance().naviRoute else {
            return ([],[],[],[])
        }
        //获取路线坐标串
        guard let oriCoordinateArray = aRoute.routeCoordinates else {
            return ([],[],[],[])
        }
        //获取路径的交通状况信息
        guard let trafficStatus = AMapNaviDriveManager.sharedInstance().getTrafficStatuses(withStartPosition: 0, distance: Int32(aRoute.routeLength)) else {
            return ([],[],[],[])
        }
    
        //结果集
        var resultCoords = Array<AMapNaviPoint>()
        var coordIndexes = Array<NSNumber>()
        var strokeColors = Array<UIColor>()
        var textureImages = Array<UIImage>()
    
        resultCoords.append(oriCoordinateArray[0])
        //依次计算每个路况的长度对应的polyline点的index
        var i = 0
        var sumLength = 0
        var statusesIndex = 0
        var curTrafficLength = (trafficStatus.first?.length)!
        
        for index in 1..<(oriCoordinateArray.count-1) {
            i = index
            let segDis = Int(calcDistanceBetweenPoint(pointA: oriCoordinateArray[i-1], pointB: oriCoordinateArray[i]))
            
            //两点间插入路况改变的点
            if sumLength + segDis >= curTrafficLength {
                if sumLength + segDis == curTrafficLength {
                    resultCoords.append(oriCoordinateArray[i])
                    coordIndexes.append(NSNumber(integerLiteral:(Int(resultCoords.count) - 1)))
                }else {
                    let rate = segDis == 0 ? 0 : (curTrafficLength - sumLength) / segDis
                    let extrnPoint = calcPointWithPoint(startPoint: oriCoordinateArray[i-1], endPoint: oriCoordinateArray[i], rate: Double(rate))
                    
                    if extrnPoint != nil {
                        resultCoords.append(extrnPoint!)
                        coordIndexes.append(NSNumber(integerLiteral:(Int(resultCoords.count) - 1)))
                        resultCoords.append(oriCoordinateArray[i])
                    }else {
                        resultCoords.append(oriCoordinateArray[i])
                        coordIndexes.append(NSNumber(integerLiteral:(Int(resultCoords.count) - 1)))
                    }
                }
                if textureEnable {
                    //添加对应的纹理照片
                    textureImages.append(defaultTextureImageForStatus(status: trafficStatus[statusesIndex].status));
                }else{
                    //添加对应的strokeColors
                    strokeColors.append(defaultColorForStatus(status: trafficStatus[statusesIndex].status))
                }
                
                sumLength = sumLength + segDis - curTrafficLength
                
                statusesIndex += 1
                if statusesIndex >= trafficStatus.count {
                    break
                }
                curTrafficLength = trafficStatus[statusesIndex].length
            }else {
                resultCoords.append(oriCoordinateArray[i])
                sumLength += segDis
            }
        }
        i += 1
        
        //将最后一个点对齐到路径终点
        if i < oriCoordinateArray.count {
            while i < oriCoordinateArray.count {
                resultCoords.append(oriCoordinateArray[i])
                i += 1
            }
            coordIndexes.removeLast()
            coordIndexes.append(NSNumber(integerLiteral:(Int(resultCoords.count) - 1)))
        }else {
            while Int(coordIndexes.count)-1 >= Int(trafficStatus.count) {
                coordIndexes.removeLast()
                if textureEnable {
                    textureImages.removeLast()
                }else{
                    strokeColors.removeLast()
                }
            }
            coordIndexes.append(NSNumber(integerLiteral:(Int(resultCoords.count) - 1)))
            //需要修改XXX的最后一个与trafficStatus最后一个一致
            if textureEnable {
                textureImages.append(defaultTextureImageForStatus(status: trafficStatus.last!.status))
            }else{
                strokeColors.append(defaultColorForStatus(status: trafficStatus.last!.status))
            }
        }
        return (resultCoords,coordIndexes,strokeColors,textureImages)
    }
    
    
   //返回对应状态的纹理图片
   class private func defaultTextureImageForStatus(status:AMapNaviRouteStatus)->UIImage{
        if (AMapMathService.shareInstance.delegate != nil) {
            let image:UIImage? = (AMapMathService.shareInstance.delegate?.textureForStatus?(status: status));
            if image != nil{
                return image!;
            }
        }
        var imageName:String!;
        if (status == AMapNaviRouteStatus.smooth){
            imageName = "custtexture_green"
        }else if (status == AMapNaviRouteStatus.slow) {
            imageName = "custtexture_slow"
        }else if (status == AMapNaviRouteStatus.jam) {
            imageName = "custtexture_bad"
        }else if (status == AMapNaviRouteStatus.seriousJam) {
            imageName = "custtexture_serious"
        }else{
            imageName = "custtexture_no"
        }
        var image:UIImage? = UIImage.name(imageName);
        if image == nil {
            image = UIImage.init(color: UIColor.colorRGB(red: 97, green: 170, blue: 248), rect: CGRect(x: 0, y: 0, width: 8, height: 8));
        }
        return image!;
    }
    
    
    //返回对应状态的颜色
    class private func defaultColorForStatus(status:AMapNaviRouteStatus)->UIColor{
        if (AMapMathService.shareInstance.delegate != nil) {
            let color:UIColor? = (AMapMathService.shareInstance.delegate?.colorForStatus?(status: status));
            if color != nil{
                return color!;
            }
        }
        switch status {
        case .smooth:
            return UIColor.colorRGB(red: 65, green: 223, blue: 16)
        case .slow:
            return UIColor.colorRGB(red: 248, green: 207, blue: 95)
        case .jam:
            return UIColor.colorRGB(red: 227, green: 118, blue: 55)
        case .seriousJam:
            return UIColor.colorRGB(red: 216, green: 60, blue: 50)
        default:
            return UIColor.colorRGB(red: 97, green: 170, blue: 248)
        }
    }
    
    
    //计算两个CLLocationCoordinate2D之间的距离
    class public func calculDistanceBetweenLocations(_ locationA:CLLocationCoordinate2D,locationB:CLLocationCoordinate2D)->Double{
        return AMapMathService.calcDistanceBetweenPoint(pointA: AMapMathService.convertCllocationToAMapNavPoint(location: locationA),
                                                 pointB: AMapMathService.convertCllocationToAMapNavPoint(location: locationB));
    }
    
    
    //计算两个AMapNaviPoint之间的距离
    class public func calcDistanceBetweenPoint(pointA:AMapNaviPoint,pointB:AMapNaviPoint)->Double{
        let mapPointA = MAMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(pointA.latitude), CLLocationDegrees(pointA.longitude)));
        let mapPointB = MAMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(pointB.latitude), CLLocationDegrees(pointB.longitude)));
        return MAMetersBetweenMapPoints(mapPointA, mapPointB);
    }
    
    
    //计算两点之间距离，带rate
    class public func calcPointWithPoint(startPoint:AMapNaviPoint,endPoint:AMapNaviPoint,rate:Double)->AMapNaviPoint?{
        if (rate > 1.0 || rate < 0) {
            return nil;
        }
        let from:MAMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(startPoint.latitude), CLLocationDegrees(startPoint.longitude)));
        let to:MAMapPoint = MAMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(endPoint.latitude), CLLocationDegrees(endPoint.longitude)));
        
        let latitudeDelta = (to.y - from.y) * rate;
        let longitudeDelta = (to.x - from.x) * rate;
        let coordinate:CLLocationCoordinate2D = MACoordinateForMapPoint(MAMapPoint(x: from.x + longitudeDelta, y: from.y + latitudeDelta));
        
        return AMapNaviPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude));
    }
    
    
    //将CLLocation转换成AMapPoint
    class public func convertCllocationToAMapNavPoint(location:CLLocationCoordinate2D)->AMapNaviPoint{
        let point = AMapNaviPoint()
        point.latitude = CGFloat(location.latitude);
        point.longitude = CGFloat(location.longitude);
        return point;
    }
    
    
    //转换Cllocation数组给AMapPoint数组
    class public func convertCllocationsToAMapNavPoints(locations:[CLLocationCoordinate2D])->[AMapNaviPoint]{
        var tmpArray = [AMapNaviPoint]()
        for location in locations {
            let point = AMapMathService.convertCllocationToAMapNavPoint(location: location);
            tmpArray.append(point);
        }
        return tmpArray;
    }
    
    
    //将AMapPoint转换成CLLocation
    class public func convertAMapNavPointToCllocation(point:AMapNaviPoint)->CLLocationCoordinate2D{
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(point.latitude), longitude: CLLocationDegrees(point.longitude));
        return location;
    }
    
    
    //转换AMapNaviPoint数组为CLLocation数组
    class public func convertAMapNavPointsToCllocations(points:[AMapNaviPoint])->[CLLocationCoordinate2D]{
        var tmpArray = [CLLocationCoordinate2D]()
        for point in points {
            let location = AMapMathService.convertAMapNavPointToCllocation(point: point);
            tmpArray.append(location);
        }
        return tmpArray;
    }
    
    
    //时间转特定字符
    class public func normalizedRemainTime(time:NSInteger)->String{
        if time <= 0 {
            return ""
        }else if (time < 60) {
            return "< 1分钟"
        }else if (time < 60*60){
            return "\(time/60)分钟"
        }else{
            let hours = time/3600
            let minute = (time/60)%60
            if (minute == 0){
                return "\(hours)小时"
            }else{
                return "\(hours)小时\(minute)分"
            }
        }
    }
    
    
    //距离转特定字符
    class public func normalizedRemainDistance(distance:NSInteger)->String{
        if distance <= 0 {
            return ""
        }else if (distance >= 1000){
            let kilometer = Double(distance) / 1000.0
            let final:String = String(format: "%.1f", kilometer);
            return "\(final)公里"
        }else{
            return "\(distance)米"
        }
    }
    
    
}
