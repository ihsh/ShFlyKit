//
//  QRCodeGenerator.swift
//  SHKit
//
//  Created by hsh on 2018/11/22.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import CoreImage


/*
 基本原则:
 1、三个角上的“回”及“回”字周围的底色不要动
 2、中间部分和不带“回”字的一角是可以填图片的（中间最好）
 3、如果中间有小的“回”字，能不变就不变，能少变就少变
 4、尽可能放大二维码后再添加图片，不要添加图片后放大
 5、生成时尽量选择较高的纠错级别 L-7% M-15% Q-25% H-30%
 */


public class QRCodeGenerator: UIView {
    
    
    //创建二维码通用方法-文字内容越复杂，二维码密度越大
    class private func createQRCodeBase(content:String,size:CGSize)->UIImage?{
        //内容转换
        let stringData = content.data(using: String.Encoding.utf8);
        //创建filter
        let filter = CIFilter.init(name: "CIQRCodeGenerator");
        //讲二维码过滤器设置为默认属性
        filter?.setDefaults();
        //设置文本内容
        filter!.setValue(stringData, forKey: "inputMessage");
        //设置容错率
        filter!.setValue("H", forKey: "inputCorrectionLevel");//设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
        //生成的图片
        let image = UIImage.clarificateImage((filter?.outputImage)!, size: size);
        return image;
    }
    
    
    //创建普通图片
    class public func generateQRCode(content:String,imageV:UIImageView,width:CGFloat)->Void{
        let image = QRCodeGenerator.createQRCodeBase(content: content, size: CGSize(width: width, height: width));
        imageV.image = image;
    }
    
    
    //创建自定义颜色的二维码
    class public func generateColorQRCode(content:String,
                                           imageV:UIImageView,
                                           width:CGFloat,
                                           color:UIColor)->Void{
        let size = CGSize(width: width, height: width);
        let baseImage = QRCodeGenerator.createQRCodeBase(content: content, size:size);
        let image = UIImage.colorQRImage(baseImage, size: size, color: color);
        imageV.image = image;
    }
    
    
    //创建中间带logo的二维码
    class public func generateLogoQRCode(content:String,
                                         imageV:UIImageView,
                                         width:CGFloat,
                                         logo:UIImage,
                                         logoSize:CGSize,
                                         color:UIColor?,
                                         radius:CGFloat)->Void{
        let size = CGSize(width: width, height: width);
        var baseImage = QRCodeGenerator.createQRCodeBase(content: content, size:size);
        if color != nil {
            baseImage = UIImage.colorQRImage(baseImage, size:size, color: color!);
        }
        let resultImage = UIImage.logoQRImage(baseImage, logo: logo, size:size);
        imageV.image = resultImage;
    }
    
    
    //创建条形码
    class public func generateBarCode(content:String,imageV:UIImageView,size:CGSize,
                                      color:UIColor = UIColor.colorHexValue("212121"))->Void{
        let image = UIImage.barcodeImage(withContent: content, codeImageSize: size, color:color);
        imageV.image = image;
    }

}
