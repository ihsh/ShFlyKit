//
//  QRCodeConfiguration.swift
//  SHKit
//
//  Created by hsh on 2018/11/23.
//  Copyright © 2018 hsh. All rights reserved.
//

import CoreImage


//CGImage扩展
public extension CGImage{
    
    //转CIImage
    func toCIImage()->CIImage{
        return CIImage(cgImage: self);
    }
}


//颜色分解
public struct ColorCompent{
    public var red: UInt8 = 0;
    public var green:UInt8 = 0;
    public var blue:UInt8 = 0;
    public var alpha:UInt8 = 0;
    
    
    init(red:UInt8,green:UInt8,blue:UInt8,alpha:UInt8){
        self.red = red;
        self.green = green;
        self.blue = blue;
        self.alpha = alpha;
    }
    
    
    init?(color:CGColor){
        
    }
    
}
