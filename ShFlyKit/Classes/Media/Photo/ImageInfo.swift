//
//  ImageInfo.swift
//  SHKit
//
//  Created by hsh on 2019/9/30.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


///照片信息读取
public class ImageInfo: NSObject {
    //Variable
    public var dateTime:String!             //拍摄的日期时间
    public var model:String!                //相机品牌
    public var make:String!                 //相机型号
    public var FNumber:Double!              //光圈值
    public var iso:Double!                  //iSO值
    
    public var ev:Double?                   //步长
    public var artist:String?               //艺术家
    public var copyRight:String?            //版权
    public var exposureBiasValue:String?    //曝光补偿值
    public var userComment:String!
    public var colorModel:String?           //色彩类型
    public var depth:Int?                   //位深
    public var profileName:String?          //颜色配置文件
    public var altitude:Double?             //海拔高度
    public var latitude:Double?             //纬度
    public var longitude:Double?            //经度
    public var focosMode:String?            //画幅类型
    public var quantity:String?             //照片质量
    public var whiteBalanceMode:String?     //白平衡值
    public var shunterCount:Int?            //拍照数
    public var serialNum:String?            //序列号
    public var lenModel:String?             //镜头类型
    
    public var originExif:NSDictionary!     //原样的信息
    
    
    ///使用方法-如下代码
    //let str = Bundle.main.url(forResource: "jinqiancao", withExtension: "JPG");
    //let info1 = UIImage.getExifInfo(withImageData: try Data.init(contentsOf: str!));
    //let imageInfo1 = ImageInfo.initDict(info1);
    class public func initDict(_ dict:NSDictionary)->ImageInfo{
        let info = ImageInfo()
         //保存的全部信息
         info.originExif = dict;
         //Tiff
         let tiff:NSDictionary = dict.value(forKey: "{TIFF}") as! NSDictionary;
         info.artist = tiff.value(forKey: "Artist") as? String;
         info.copyRight = tiff.value(forKey: "Copyright") as? String;
         info.dateTime = tiff.value(forKey: "DateTime") as? String ?? "";
         info.model = tiff.value(forKey: "Model") as? String ?? "";
         info.make = tiff.value(forKey: "Make") as? String ?? "";
         //exif
         let exif:NSDictionary = dict.value(forKey: "{Exif}") as! NSDictionary;
         info.FNumber = exif.value(forKey: "FNumber") as? Double;
         info.ev = exif.value(forKey: "ExposureBiasValue") as? Double;
         let isoEles:[NSNumber] = exif.value(forKey: "ISOSpeedRatings") as! [NSNumber];
         info.iso = isoEles.first?.doubleValue ?? 0;
         
         info.colorModel = dict.value(forKey: "ColorModel") as? String;
         info.depth = dict.value(forKey: "Depth") as? Int;
         info.profileName = dict.value(forKey: "ProfileName") as? String;
         
         let gps:NSDictionary? = dict.value(forKey: "{GPS}") as? NSDictionary;
         if gps != nil {
             info.altitude = gps!.value(forKey: "Altitude") as? Double;
             info.longitude = gps!.value(forKey: "Longitude") as? Double;
             info.latitude = gps!.value(forKey: "Latitude") as? Double;
         }
        
         let makerNikon:NSDictionary? = dict.value(forKey: "{MakerNikon}") as? NSDictionary;
         if makerNikon != nil {
             info.focosMode = makerNikon!.value(forKey: "FocusMode") as? String;
             info.quantity = makerNikon!.value(forKey: "Quality") as? String;
             info.whiteBalanceMode = makerNikon!.value(forKey: "WhiteBalanceMode") as? String;
             info.shunterCount = makerNikon!.value(forKey: "ShutterCount") as? Int;
         }
         let exifAux:NSDictionary? = dict.value(forKey: "{ExifAux}") as? NSDictionary;
         if exifAux != nil {
             info.serialNum = exifAux!.value(forKey: "SerialNumber") as? String;
             info.lenModel = exifAux!.value(forKey: "LensModel") as? String;
         }
        return info;
    }
    
    
}
