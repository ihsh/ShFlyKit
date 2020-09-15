//
//  Printer.swift
//  SHKit
//
//  Created by hsh on 2019/9/17.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit
import WebKit

///打印机功能--图片,html
class Printer: NSObject {
    
    //介质类型
    enum Medium {
        case paper,     //纸张-通常是A4.A5.A3
             photo      //照片纸--通常是4*6
    }
    //颜色选择
    enum ColorType {
        case colorful,grayScale     //色彩，灰阶(黑白)
    }
    
    
    
    ///打印照片
    class public func printImage(_ images:[UIImage],medium:Printer.Medium = .photo,color:Printer.ColorType = .colorful,rep:@escaping ((_ completed:Bool,_ error:Error?)->Void)){
        //图片数据
        var datas:[Data] = [];
        for image in images {
            guard let data = UIImagePNGRepresentation(image) else {continue}
            datas.append(data);
        }
        //打印的配置
        let info = UIPrintInfo(dictionary: nil);
        //输出类型
        info.outputType = outputType(medium, type: color);
        let shared = UIPrintInteractionController.shared;
        shared.printInfo = info;
        shared.showsPaperSelectionForLoadedPapers = true;
        shared.printingItems = datas;
        shared.present(animated: true) { (pvc, completed, error) in
            rep(completed,error);
        }
    }

    
    //打印网页
    class public func printWeb(_ web:WKWebView,medium:Printer.Medium = .paper,color:Printer.ColorType = .colorful,rep:@escaping ((_ completed:Bool,_ error:Error?)->Void)){
        //不能使用UIPrintInfo()初始化
        let info = UIPrintInfo(dictionary: nil);
        //输出类型
        info.outputType = outputType(medium, type: color);
        let shared = UIPrintInteractionController.shared;
        shared.printInfo = info;
        shared.showsPaperSelectionForLoadedPapers = true;
        //使用webview内置的viewPrintFormatter
        let viewFormat = web.viewPrintFormatter();
        viewFormat.startPage = 0;
        shared.printFormatter = viewFormat;
        shared.present(animated: true) { (pvc, completed, error) in
            rep(completed,error);
        }
    }
    
    
    //决定输出类型
    class private func outputType(_ medium:Printer.Medium,type:Printer.ColorType)->UIPrintInfoOutputType{
        if medium == .photo{
            return (type == .colorful) ? UIPrintInfo.OutputType.photo : UIPrintInfo.OutputType.photoGrayscale;
        }else{
            return (type == .colorful) ? UIPrintInfo.OutputType.general : UIPrintInfo.OutputType.grayscale;
        }
    }
    
    
}
