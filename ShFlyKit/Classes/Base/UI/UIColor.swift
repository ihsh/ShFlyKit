//
//  JHColor.swift
//  SHLibrary
//
//  Created by hsh on 2018/7/13.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit

extension UIColor {

    /// 生成RGB颜色
    ///
    /// - Parameters:
    ///   - r: 红色值
    ///   - g: 绿色值
    ///   - b: 蓝色值
    ///   - alpha: 透明度
    /// - Returns: 返回的颜色值
   @objc public static func colorRGB(red:Int,green:Int,blue:Int,alpha:CGFloat = 1)->UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha);
    }
    
    
    /// 根据十六进制字符串生成颜色值
    ///
    /// - Parameters:
    ///   - rgbValue: 十六进制字符串 带#
    ///   - alpha: 透明度
    /// - Returns: 返回的颜色值
   @objc public static func colorHexValue(_ hexStr:String,alpha:CGFloat = 1)->UIColor{
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var hex:   String = hexStr
        hex = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()//去除空格
        if hex.hasPrefix("#") {
            let index = hex.index(hex.startIndex, offsetBy: 1)
            hex = String(hex[index...])
        }
        if hex.contains("0x") || hex.contains("0X"){
            let index = hex.index(hex.startIndex, offsetBy: 2);
            hex = String(hex[index...])
        }
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
            default:
                print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
            }
        }
        return UIColor(red:red, green: green, blue: blue, alpha: alpha);
    }

    
    //颜色中的红色值
    @objc public func redCompont()->CGFloat{
        let components = self.cgColor.components;
        return components?[0] ?? 0;
    }
    
    
    //颜色中的绿色值
    @objc public func greenCompont()->CGFloat{
        let components = self.cgColor.components;
        return components?[1] ?? 0;
    }
    
    
    //颜色中的蓝色值
    @objc public func blueCompont()->CGFloat{
        let components = self.cgColor.components;
        return components?[2] ?? 0;
    }
    
    
    //生成随机色
    @objc public static func randomColor(alpha:CGFloat = 1)->UIColor{
        let red = CGFloat(arc4random()%256)/255.0;
        let grren = CGFloat(arc4random()%256)/255.0;
        let blue = CGFloat(arc4random()%256)/255.0;
        return UIColor(red: red, green: grren, blue: blue, alpha: alpha);
    }
    
    
    //背景色
    @objc public static func background()->UIColor{
        return UIColor.colorRGB(red: 237, green: 237, blue: 237);
    }
    
    
    //彩虹色
    @objc public static func rainbowColor(_ i:Int)->UIColor{
        switch i {
        case 0:
            return UIColor.colorRGB(red: 255, green: 0, blue: 0);
        case 1:
            return UIColor.colorRGB(red: 255, green: 165, blue: 0);
        case 2:
            return UIColor.colorRGB(red: 255, green: 255, blue: 0);
        case 3:
            return UIColor.colorRGB(red: 0, green: 255, blue: 0);
        case 4:
            return UIColor.colorRGB(red: 0, green: 127, blue: 255);
        case 5:
            return UIColor.colorRGB(red: 0, green: 0, blue: 255);
        case 6:
            return UIColor.colorRGB(red: 139, green: 0, blue: 255);
        default:
            return UIColor.randomColor();
        }
    }
    
    
    //随机颜色
    @objc public static func randomForColors(_ colors:[UIColor])->UIColor{
        let index:Int = Int(arc4random()) % colors.count;
        return colors[index];
    }
    
    
}
