//
//  SHiCouldCoordinater.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/3/29.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import CloudKit
//一是 iCloud documnet storage，利用 iCloud 存储用户文件，比如保存一些用户在使用应用时生成的文件以及数据库文件等。
//二是 iCloud key-value data storage，利用 iCloud 存储键值对，主要是保存一些程序的设置信息，一般只允许存储几十K大小
//要测试iCloud功能，需要一个付费的iOS 开发者账号。 至少要2台iOS设备才可以测试数据同步功能。（iOS Simulator无法做iCloud Storage的测试）

//代理
public protocol SHiCloudDelegate:NSObjectProtocol {
    //h返回数据
    func responseWith(record:CKRecord,error:Error)
    //保存反馈
    func saveResult(_ recordID:String,error:Error?);
}


///iCloud云存储
public class SHiCouldCoordinater: NSObject {
    ///Variable
    public static let shared = SHiCouldCoordinater()
    public weak var deleagete:SHiCloudDelegate?
    
    
    //iCloud功能是否开启
    class func iCloudAccessCheck()->Bool{
        let cloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        return cloudUrl != nil
    }
    
    
    //添加单条记录
    public func addCloudDataWithPublic(isPublic:Bool,recordID:String,dict:NSDictionary,recordType:String = "User")->Bool{
        let container:CKContainer = CKContainer.default()
        //公共数据/私有数据
        let database:CKDatabase = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
        //创建主键ID，查找时有用
        let noteId = CKRecordID.init(recordName: recordID)
        //创建CKRecord
        let noteRecord = CKRecord.init(recordType:recordType, recordID: noteId)
        //设置数据
        for key in dict.allKeys{
            let value:String = dict.value(forKey: key as! String) as! String
            noteRecord .setObject(value as CKRecordValue, forKey: key as! String)
        }
        //保存操作
        database.save(noteRecord) { (record, error) in
            self.deleagete?.saveResult(recordID, error: error ?? nil);
        }
        return false
    }
    
    
    
    //增加带图片的提交 图片的保存,需要用到CKAsset,他的初始化需要一个URL,所以这里,我先把图片数据保存到本地沙盒,生成一个URL,然后再去创建CKAsset:
    public func saveImageData(isPublic:Bool,recordID:String,image:UIImage,recordType:String = "Image")->Void{
        //先保存到本地沙盒，生成一个URL
        var data = UIImagePNGRepresentation(image)
        if data == nil {
            data = UIImageJPEGRepresentation(image, 1.0)
        }
        let home:NSString = NSHomeDirectory() as NSString
        let tempPath = home.appendingPathComponent("Documents/imagesTemp")
        let manager = FileManager.default
        if manager.fileExists(atPath: tempPath) == false{
           try? manager .createDirectory(atPath: tempPath, withIntermediateDirectories: true, attributes: nil)
        }
        let filePath = NSString.init(format: "%@%@", tempPath,image.accessibilityIdentifier!)//获取图片的名字
        let url:URL = NSURL.init(fileURLWithPath: filePath as String) as URL
        if ((try? data?.write(to: url)) != nil){
            //创建CKAsset
            let asset:CKAsset = CKAsset.init(fileURL: url)
            //与iCloud进行交互
            let container = CKContainer.default()
            let database = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
            //创建主键ID，查找时有用
            let noteId = CKRecordID.init(recordName: recordID)
            //创建CKRecord
            let noteRecord = CKRecord.init(recordType:recordType, recordID: noteId)
            noteRecord.setObject(asset, forKey: "image")
            database.save(noteRecord, completionHandler: { (record, error) in
                self.deleagete?.saveResult(recordID, error: error ?? nil);
            })
        }
    }
        
        
    
    //查找单条记录
    public func searchRecord(isPublic:Bool,recordID:String)->Void{
        //获得指定的ID
        let noteID = CKRecordID.init(recordName: recordID)
        //获得容器
        let container = CKContainer.default()
        let database = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
        //查找操作
        database .fetch(withRecordID: noteID) { (record, error) in
            self.deleagete?.saveResult(recordID, error: error ?? nil);
        }
    }
    
    
    //查找多条记录
    public func searchMulRecords(isPublic:Bool,recordType:String = "User")->Void{
        let container = CKContainer.default()
        let database = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
        //谓词
        let predicate:NSPredicate = NSPredicate.init(value: true)
        //查询
        let query:CKQuery = CKQuery.init(recordType: recordType, predicate: predicate)
        database .perform(query, inZoneWith: nil) { (records, error) in
            self.deleagete?.saveResult("searchMulRecords", error: error ?? nil);
        }
    }
    
    
    //更新一条记录，首先找到这一条，再进行修改
    public func updateRecord(isPublic:Bool,recordID:String,recordType:String = "User",newDict:NSDictionary)->Void{
        //获得指定的ID
        let noteID = CKRecordID.init(recordName: recordID)
        let container = CKContainer.default()
        let database = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
        database.fetch(withRecordID: noteID) { (record, error) in
            if error == nil{
                //对原有值进行修改
                for key in newDict.allKeys{
                    let value:String = newDict.value(forKey: key as! String) as! String
                    record?.setObject(value as CKRecordValue, forKey: key as! String)
                }
                database.save(record!, completionHandler: { (newRecord, newError) in
                    self.deleagete?.saveResult(recordID, error: error ?? nil);
                })
            }
        }
    }
    
    
    //删除一条记录
    public func deleteRecord(isPublic:Bool,recordID:String)->Void{
        //获得指定的ID
        let noteID = CKRecordID.init(recordName: recordID)
        let container = CKContainer.default()
        let database = isPublic ? container.publicCloudDatabase : container.privateCloudDatabase
        database .delete(withRecordID: noteID) { (record, error) in
            self.deleagete?.saveResult(recordID, error: error ?? nil);
        }
    }
    
    
}
