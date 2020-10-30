//
//  StringExtension.swift
//  SHKit
//
//  Created by hsh on 2019/9/26.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

///字符串拓展
public extension String {
    
    //转拼音--转的可能不对，比如厦门-shamen
    func transformToPinYin()->String{
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "");
    }
    
    
    //去除空白字符
    func trimWhiteSpace()->String{
        return self.components(separatedBy: .whitespaces).joined(separator: "");
    }
    
}
