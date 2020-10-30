//
//  DataSource.swift
//  SHKit
//
//  Created by hsh on 2019/1/29.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import FMDB


//网络模型
public class NetModel:NSObject{
    //(url+body+time)请求的唯一标识码,可通过保存这个反向取出,只有一条
    public var md5:String = ""
    //(url+body)字符串的MD5值，可索引出多个值
    public var urlKey:String = ""
    //网址链接
    public var url:String!
    //body参数
    public var body:String = ""
    //请求方式
    public var method:String!
    //响应的json字符串
    public var responseObj:String = ""
    //响应码
    public var retCode:Int = -1
    //生成时间戳-毫秒
    public var createTime:Int!
    //响应时间-毫秒
    public var responseTime:Int = 0
    //消耗时间-毫秒
    public var elapsedTime:Int = 0
    //1是成功，0是失败
    public var isSuccess:Int = 0
    //重试次数
    public var retryCount:Int = 0
    //对应的VC名称
    public var stackName:String = ""
    //网络状态
    public var netInfo:String!
    //app版本号
    public var version:String!
    //系统版本
    public var systenV:String!
    
    
    ///MARK-Load
    override init() {
        super.init();
        self.version = NetStatus.shareInstance.appInfo.version;
        self.systenV = NetStatus.shareInstance.deviceInfo.iosVersion;
    }
    
    
    //生成标准的保存模型
    class public func convertBaseRequestToNetModel(_ req:BaseRequest)->NetModel{
        let model = NetModel()
        //网址
        model.url = req.url;
        //method
        switch req.method {
        case .GET:
            model.method = "GET";
        case .POST:
            model.method = "POST";
        case .PUT:
            model.method = "PUT";
        case .DELETE:
            model.method = "DELETE";
        }
        //网络状况
        model.netInfo = NetStatus.shareInstance.generateNetInfo()
        model.md5 = req.md5;
        model.urlKey = req.urlKey;
        return model;
    }
    
    
}


///网络请求库的数据
public class NetDataSource: NSObject {
    ///MARK
    private var database:FMDatabase!                                    //数据库
    private var queue:FMDatabaseQueue!                                  //线程
    private var tableName = NetStatus.shareInstance.appInfo.name!     //表名
    private var path:String!                                            //方便打印路径
    
    
    ///MARK-Load
    override init() {
        super.init();
        let directPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                             FileManager.SearchPathDomainMask.userDomainMask, true).last;
        path = directPath?.appending("/netReq.db");//前往该地址可以用数据库软件打开查看
        self.database = FMDatabase.init(path: path);
        self.queue = FMDatabaseQueue.init(path: path);
    }
    
    
    //保存请求的模型
    public func saveRequests(_ reqs:[NetModel])->Void{
        //插入的sql语句
        let sql = "INSERT INTO \(tableName) (md5,urlKey,url,body,method,responseObj,retCode,createTime,responseTime,elapsedTime,isSuccess,retryCount,stackName,netInfo,appVersion,systemVersion) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        //打开表
        database.open()
        //检查表创建
        checkTable(tableName);
        //开始事务
        database.beginTransaction()
        for model in reqs {
            database.executeUpdate(sql, withArgumentsIn: [model.md5,model.urlKey,model.url,model.body,model.method,
                                                                   model.responseObj,model.retCode,model.createTime,model.responseTime,
                                                                   model.elapsedTime,model.isSuccess,model.retryCount,model.stackName,
                                                                   model.netInfo,model.version,model.systenV]);
        }
        database.commit();
        database.close();
    }
    
    
    //更新数据
    public func updateRecord(model:NetModel)->Void{
        let sql = "INSERT OR REPLACE INTO \(tableName) (md5,urlKey,url,body,method,responseObj,retCode,createTime,responseTime,elapsedTime,isSuccess,retryCount,stackName,netInfo,appVersion,systemVersion) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
        model.elapsedTime = model.responseTime - model.createTime
        database.open();
        database.executeUpdate(sql, withArgumentsIn: [model.md5,model.urlKey,model.url,model.body,model.method,
                                                      model.responseObj,model.retCode,model.createTime,model.responseTime,
                                                      model.elapsedTime,model.isSuccess,model.retryCount,model.stackName,
                                                      model.netInfo,model.version,model.systenV]);
        database.close();
    }
    
    
    //查询一个请求
    public func queryForMD5(_ md5:String)->NetModel?{
        database.open();
        //查询sql
        let tableName = NetStatus.shareInstance.appInfo.name!
        let sql = "SELECT * FROM \(tableName) WHERE md5 = \(md5)";
        //结果集
        let result:FMResultSet = database.executeQuery(sql, withArgumentsIn: []) ?? FMResultSet()
        var tmpArray:[NetModel] = [];
        while result.next() {
            let model = modelWithFMResultSet(result);
            tmpArray.append(model);
        }
        database.close();
        return tmpArray.first;
    }
    
    
    
    //返回对应UrlKey的结果
    public func queryForUrlKey(_ urlKey:String)->[NetModel]{
        //清理空间
        clearTable(tableName);
        //再查询数据
        database.open();
        //查询sql
        let sql = "SELECT * FROM \(tableName) WHERE urlKey = \(urlKey) ORDER BY creatTime DESC";
        //结果集
        let result:FMResultSet = database.executeQuery(sql, withArgumentsIn: []) ?? FMResultSet()
        //可能有多条记录
        var tmpArray:[NetModel] = [];
        while result.next() {
            let model = modelWithFMResultSet(result);
            tmpArray.append(model);
        }
        database.close();
        return tmpArray;
    }
    
    
    
    //创建请求报文表
    private func checkTable(_ tableName:String)->Void{
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (md5 text primary key,urlKey text,url text,body text,method text,responseObj text,retCode long,createTime long,responseTime long,elapsedTime long,isSuccess integer,retryCount integer,stackName text,netInfo text,appVersion text,systemVersion text)";
        queue.inDatabase { (db) in
            database.executeUpdate(sql, withArgumentsIn: []);
        };
    }
    
    
    //清除数据
    public func clearTable(_ tableName:String)->Void{
        //保存一个月的报文-毫秒
        var time:Int = Int(Date().timeIntervalSince1970)
        time -= (24*60*60*30);
        time *= 1000;
        //sql语句
        let sql = "DELETE FROM \(tableName) WHERE createTime < \(time) ";
        database.open();
        database.executeUpdate(sql, withArgumentsIn: []);
        database.close();
    }
    
    
    //FMResultSet转NetModel
    private func modelWithFMResultSet(_ result:FMResultSet)->NetModel{
        let model = NetModel()
        model.md5 = result.string(forColumn: "md5")!;
        model.url = result.string(forColumn: "url")!;
        model.method = result.string(forColumn: "method")!;
        model.urlKey = result.string(forColumn: "urlKey") ?? "";
        model.body = result.string(forColumn: "body") ?? "";
        model.responseObj = result.string(forColumn: "responseObj") ?? "";
        model.retCode = Int(result.int(forColumn: "retCode"));
        model.isSuccess = Int(result.int(forColumn: "isSuccess"));
        model.retryCount = Int(result.int(forColumn: "retryCount"))
        model.createTime = result.long(forColumn: "createTime");
        model.responseTime = result.long(forColumn: "responseTime");
        model.elapsedTime = result.long(forColumn: "elapsedTime");
        model.stackName = result.string(forColumn: "stackName") ?? ""
        model.netInfo = result.string(forColumn: "netInfo");
        model.version = result.string(forColumn: "appVersion");
        model.systenV = result.string(forColumn: "systemVersion");
        return model;
    }
    
    
}
