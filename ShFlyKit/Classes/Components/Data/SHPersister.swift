//
//  SHlocalPersister.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/3/28.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import FMDB
import YYModel

///数据持久化方式
public enum SaveType{
    case UserDefault,   //保存配置
         SQlite,        //保存普通数据,自定义模型
         WriteToFile    //保存文件,二进制数据
}


///UserDefaults存储选项
public enum UserDefaultsDataType{
    case URL,Int,String,Bool,Double,Float,AnyType
}


///数据持久化类
class SHPersister: NSObject {
    ///MARK-Variable
    static let shareInstance = SHPersister.init();
    private var database:FMDatabase!            //数据库
    private var queue:FMDatabaseQueue!          //线程
    
    
    ///MARK-Load
    override init() {
        super.init();
        let directPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last;
        let path = directPath?.appending("/dataBase.db");//前往该地址可以用数据库软件打开查看
        self.database = FMDatabase.init(path: path);
        self.queue = FMDatabaseQueue.init(path: path);
    }
    
    
    //创建表
    private func createTable(_ tableName:String)->Void{
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (id integer primary key,creatTime long,json text,identifier string)";
        queue.inDatabase { (db) in
           database.executeUpdate(sql, withArgumentsIn: []);
        };
    }
    
    
    
    ///MARK-Interface
    //保存数据--不支持数组嵌套，只能保存一个数组，数组里面可以是不同类对象
    public func saveData(objs:[AnyObject],identifier:String = "",clear:Bool = false)->Void{
        //多个类分组
        var classes:[String] = [];          //类名数组
        var arrayes:[NSMutableArray] = [];  //数据分组
        //获取对象的类名
        func getClassName(_ obj:AnyObject)->String{
            var className = type(of: obj).description()
            if(className.contains(".")){//swift的类带点，工程名.类名
                className = className.components(separatedBy: ".")[1];
            }
            if className.contains("NSDictionary") {
                className = "NSDictionary";
            }
            return className;
        }
        
        //遍历所有对象
        for obj in objs{
            //获取类名
            let className = getClassName(obj);
            if clear == true && objs.count > 0 {
                deleteTableBeforeTime(type(of: obj), time: Int(Date().timeIntervalSince1970),identifier: identifier);
            }
            database.open();
            //不存在该类名，创建新数组
            if classes.contains(className) == false {
                //判断是否已经存在表
                let saved:Bool = database.tableExists(className);
                //不存在建表
                if saved == false {
                    createTable(className);
                }
                //保存表名
                classes.append(className);
                //创建新数组
                let array:NSMutableArray = NSMutableArray();
                array.add(obj);
                arrayes.append(array);
            }else{
                //添加到已有的数组
                for mulArray in arrayes{
                    let first:AnyObject? = mulArray.firstObject as AnyObject;
                    if first != nil{
                        let typeName = getClassName(first!);
                        if typeName == className{
                            mulArray.add(obj);
                            break;
                        }
                    }
                }
            }
        }
        
        //遍历多个数组
        //生成一个时间戳
        let timeInterval:TimeInterval = Date().timeIntervalSince1970;
        for array in arrayes {
            //一个个数组的保存
            database.beginTransaction();
            for p in array{
                let obj:AnyObject = p as AnyObject
                let className = getClassName(obj);
                //sql语句
                let sql = "INSERT INTO \(className) (creatTime,json,identifier) VALUES (?,?,?)"
                //模型转json字符串
                let json:String = obj.yy_modelToJSONString() ?? "";
                database.executeUpdate(sql, withArgumentsIn: [Int(timeInterval),json,identifier]);
            }
            //提交-对应beginTransaction
            database.commit();
        }
        database.close();
    }
    
    
    
    //查询接口
    //OC模型类实现嵌套需要实现YYModel的方法
        /*  + (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
         return @{@"items":@"Item"};
         }    */
    //swift类没有实现嵌套的方式，不带嵌套的可以直接使用 ,不需要加东西
   
    //当SQLiteQueryType==Last,clear == true,获取并会清理之前的数据
    public func queryForClass(_ cls:AnyClass,clear:Bool = false,identifier:String = "")->[AnyObject]{
        //获取类名
        let className = getClassName(cls: cls);
        //时间戳数组
        var timeArray:[Int] = [];
        //倒序获取最新的数据
        var tmpArray:[AnyObject] = [];

        database.open();
        //sql
        let sql = String(format: "SELECT * FROM %@ WHERE identifier = '%@' ORDER BY creatTime DESC", className,identifier);
        //结果集
        let result:FMResultSet = database.executeQuery(sql, withArgumentsIn: []) ?? FMResultSet();
        while (result.next()) {
            //获取对应json字符串
            let json = result.string(forColumn: "json");
            //获取对应时间戳
            let time:Int = Int(result.int(forColumn: "creatTime"));
            timeArray.append(time);
            //json转模型--不支持UIImage类型
            if className == "NSDictionary" {
                let data = json?.data(using: String.Encoding.utf8);
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                    let tmpDict:NSDictionary = dict! as NSDictionary;
                    tmpArray.append(tmpDict);
                }
            }else{
                let model = cls.yy_model(withJSON: json ?? "");
                //变量会导致多执行一次
                if model != nil {
                    tmpArray.append(model!);
                }
            }
        }
        database.close();
        //清理数据库
        if clear == true {
            deleteTableBeforeTime(cls, time: timeArray.first ?? 0);
        }
        return tmpArray;
    }
    
    
    
    //清理在这个时间之前的数据
    public func deleteTableBeforeTime(_ cls:AnyClass,time:Int,identifier:String = "")->Void{
        let className = getClassName(cls: cls);
        database.open();
        let sql = String(format: "DELETE FROM %@ WHERE creatTime < '%ld' And identifier = '%@'", className,time,identifier);
        database.executeUpdate(sql, withArgumentsIn: []);
        database.close();
    }
    
    
    //获取类的类名
    private func getClassName(cls:AnyClass)->String{
        //获取类名
        var className:String = cls.self.description()
        if(className.contains(".")){//swift的类带点，工程名.类名
            className = className.components(separatedBy: ".")[1];
        }
        if className.contains("NSDictionary") {
            className = "NSDictionary";
        }
        return className;
    }
    
    
    ///MARK - UserDefault
    //保存到配置中
    class func defaultSave(key:String,value:Any,type:UserDefaultsDataType){
        let uDefault = UserDefaults.standard
        switch type {
            case .Int:
                let data = value as! Int
                uDefault .set(data, forKey: key)
            case .Bool:
                let data = value as! Bool
                uDefault .set(data, forKey: key)
            case .Double:
                let data = value as! Double
                uDefault .set(data, forKey: key)
            case .Float:
                let data = value as! Float
                uDefault .set(data, forKey: key)
            case .String:
                let data = value as! String
                uDefault .set(data, forKey: key)
            case .URL:
                let data = value as! URL
                uDefault .set(data, forKey: key)
            case .AnyType:
                uDefault .set(value, forKey: key)
        }
        uDefault.synchronize()
    }
    
    
    //获取值
    class func defaultValueFor(key:String)->Any?{
        let uDefault = UserDefaults.standard
        let value = uDefault.value(forKey: key)
        return value
    }
    
    
    //清空UserDefaults或指定值
    class func clearNSUserDefault(targetKey:String?)->Void{
        if targetKey != nil {
            UserDefaults.standard.removeObject(forKey: targetKey!);
        }else{
            let appDomain = Bundle.main.bundleIdentifier;
            if appDomain != nil {
                UserDefaults.standard.removePersistentDomain(forName: appDomain!);
            }
        }
    }
    
    
   
}



