//
//  FileManager.swift
//  SHKit
//
//  Created by hsh on 2019/10/9.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///文件路径管理者
class FilePathManager: NSObject {

    class public func documentPath()->URL?{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last;
    }
    
    
    class public func sizeOfDataFromUrl(_ url:URL){
        do{
            if FileManager.default.fileExists(atPath: url.path) {
                let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attr[FileAttributeKey.size];
                let dict = attr as NSDictionary
                let size = dict.fileSize();
                
            }
        }catch{
            
        }
    }
    
}
