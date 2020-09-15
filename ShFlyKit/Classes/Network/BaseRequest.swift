//
//  SHBaseRequest.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/2/26.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import YYModel


///请求回调
typealias ResponseBlock = (_ ret:Int,_ msg:String,_ resp:NSDictionary)->()


///请求方法
public enum Method {
    case GET,POST,PUT,DELETE
}


///请求类
class BaseRequest: NSObject ,SHNetManagerDelegate{
    //必选
    public var method = Method.GET                                                   //请求方法
    public var url:String!                                                           //请求地址
    public var body = NSMutableDictionary()                                          //请求数据体
    public var response:ResponseBlock!                                               //请求的回调
    //可选属性
    public var urlKey:String!                                                        //url的索引键-自动设置
    public var md5:String!                                                           //MD5字符串
    public var retryCount:Int = 0                                                    //重试次数
    public var requestSenderView:UIView?                                             //哪个UI界面触发的请求，暂停它的响应
    public var showProgress = true                                                   //是否显示进度
    public var needLog:Bool = true                                                   //打印报文
    public var loadLast:Bool = true                                                  //是否先加载以前的结果，有新的再刷新
    private var match:BaseMatch!                                                     //用来解析的数据模型
    
    
    //Design initialler
    class func initWithMethod(method:Method,key:String?,pairClass:AnyClass?,url:String,block:@escaping ResponseBlock)->BaseRequest{
        let request:BaseRequest = BaseRequest()
        request.method = method;
        request.url = url;
        request.response = block;
        request.match = BaseMatch.inits(key: key, pairClass: pairClass)
        return request;
    }
    
    
    class func initWithMethod(method:Method,match:BaseMatch,url:String,block:@escaping ResponseBlock)->BaseRequest{
        let request:BaseRequest = BaseRequest()
        request.method = method;
        request.url = url;
        request.response = block;
        request.match = match;
        return request;
    }
    
    
    //配置其他属性
    public func configOption(log:Bool,sendView:UIView?,process:Bool,loadLast:Bool){
        self.needLog = log
        self.requestSenderView = sendView;
        self.showProgress = process;
        self.loadLast = loadLast;
    }
    
    
    //字典转字符串
    private func dictToJsonString(dict:NSDictionary)->String{
        let data:Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
        var param:String = "";
        if data != nil {
            param = String.init(data: data! , encoding: String.Encoding.utf8)!
        }
        return param
    }
    
    
    
    ///MARK-SHNetManagerDelegate
    func responseWithResult(_ result: Any?) {
        //根据字典还是数组组装数据,是否指定特殊解析的key
        func pairGenenate(_ data:Any,pairKey:String?)->Any{
            var matchClass:AnyClass?
            if pairKey != nil {
                let index:Int = match.pairKeys.index(of: pairKey!)!;
                //找出对应的class,如果没有就用默认的class，再没有就没有
                matchClass = index < match.pairClasses.count ? match.pairClasses[index] : (match.pairClass ?? nil);
            }else{
                //找不到唯一对应的class,就从对应的数组第一个找，没有为空
                matchClass = match.pairClass ?? (match.pairClasses.first ?? nil);
            }
            if matchClass != nil{
                //data是字典-对应一种模型
                if data is Dictionary<String, Any>{
                    let obj:NSDictionary = data as! NSDictionary;
                    let model = matchClass!.yy_model(withJSON: obj);
                    //解析成功
                    if model != nil{
                        return model!
                    }else{
                        return obj;
                    }
                }else if (data is Array<NSDictionary>){
                    //data是数组--全数组且都是一种模型
                    let array:Array<NSDictionary> = data as! Array;
                    var tmpArray:[AnyObject] = [];
                    for obj in array{
                        let model = matchClass!.yy_model(withJSON: obj);
                        if model != nil{
                            tmpArray.append(model! as AnyObject);
                        }else{
                            tmpArray.append(obj);
                        }
                    }
                    return tmpArray;
                }
            }
            //其他数据类型直接返回
            return data;
        }
        
        
        //数据变量
        var resultMap:NSMutableDictionary = NSMutableDictionary()
        var retCode:Int = 404;
        var msgStr:String = "暂无数据"
        var json:String = "";
        
        //解析数据
        if let dict:NSDictionary = result! as? NSDictionary {
            //字典转json,后面保存
            json = dictToJsonString(dict: dict);
            //消息
            msgStr = dict.value(forKey: match.msg) as! String;
            //状态码
            let ret = dict.value(forKey: match.ret);
            retCode = (ret is String) ? (Int(ret as! String)!) : (ret as! Int);
            //data
            let data:Any! = dict.value(forKey: match.data) ?? "";
            //data是字典
            if data is Dictionary<String, Any>{
                let objDic:NSDictionary = data as! NSDictionary;
                //没有指定模型类,没有指定解析键，直接返回元数据
                if match.pairClass == nil && match.pairClasses.count == 0 || (match.pairKey == nil && match.pairKeys.count == 0){
                    resultMap = NSMutableDictionary.init(dictionary: objDic);
                }else{
                    //解析多个key的
                    if (match.pairKeys.count > 0 && match.pairClasses.count > 0) || (match.pairKeys.count > 0 && match.pairClass != nil){
                        for obj in objDic.allKeys {
                            let key:String = obj as! String
                            var matchKey:String?
                            //找到这个键值
                            for tmp in match.pairKeys{
                                if key == tmp {
                                    matchKey = key;
                                    break;
                                }
                            }
                            //匹配到键
                            if matchKey != nil {
                                let pairData:Any = objDic.value(forKey:key) ?? "";
                                let pairResult = pairGenenate(pairData,pairKey: matchKey!);
                                resultMap.setValue(pairResult, forKey: key);
                            }else{
                                let value = objDic.value(forKey: key)
                                resultMap.setValue(value, forKey: key);
                            }
                        }
                    }else if match.pairKey != nil{
                        //只有一个配对的key,也只用一个class
                        for obj in objDic.allKeys{
                            let key:String = obj as! String
                            if key == match.pairKey {
                                let pairData:Any = objDic.value(forKey:key) ?? "";
                                let pairResult = pairGenenate(pairData,pairKey: nil);
                                resultMap.setValue(pairResult, forKey: key);
                            }else{
                                //除了指定的key其他key也能返回
                                let value = objDic.value(forKey: key)
                                resultMap.setValue(value, forKey: key);
                            }
                        }
                    }else{
                        //只有class,没有配对的key
                        resultMap.setValue(pairGenenate(data,pairKey: nil), forKey: "model");
                    }
                }
            }else if (data is Array<Any>){
                //data是数组--全数组都是一种模型
                resultMap.setValue(pairGenenate(data,pairKey: nil), forKey: "array")
            }else if (data is String){
                //data是一个字符串，比如订单号-原样返回
                resultMap.setValue(data, forKey: match.data);
            }
        }
        //请求响应
        self.response(retCode,msgStr,resultMap);
        
        
        //保存原有的模型
        var saveModel:NetModel?
        for it in NetManager.shareInstance.saveArray {
            let item:NetModel = it as! NetModel
            if item.md5 == self.md5{
                saveModel = item;
                break;
            }
        }
        if saveModel != nil {
            let time:Int = Int(Date().timeIntervalSince1970*1000);
            saveModel?.responseObj = json;
            saveModel?.responseTime = time;
            saveModel?.retCode = retCode;
            saveModel?.retryCount = self.retryCount;
            saveModel?.isSuccess = 1;
            saveModel?.stackName = NetStatus.nameOfWindowViewController()
            NetManager.shareInstance.dataSource.updateRecord(model: saveModel!);
            NetManager.shareInstance.saveArray.remove(saveModel!);
        }
    }
}



///创建数据匹配项
class BaseMatch:NSObject{
    //ret
    public var ret:String = "ret"
    //msg
    public var msg:String = "msg"
    //data
    public var data:String = "data"
    
    //匹配对应模型的键值  datas对应的是：1.一个数组，不需要key，直接传模型即可，2：字典，需要用key来指定对应的数组
    public private (set) var pairKey:String?
    //转换的目标模板类
    public private (set) var pairClass:AnyClass?
    
    //多对解析key
    public private (set) var pairKeys:[String] = []
    //多对模板类-相同的话就用pairClass
    public private (set) var pairClasses:[AnyClass] = []
    
    
    //初始化方法
    class func inits(key:String?,pairClass:AnyClass?)->BaseMatch{
        let match = BaseMatch();
        match.pairKey = key;
        match.pairClass = pairClass;
        return match;
    }
    
    
    //初始化多对解析模板方法
    class func inits(keys:[String],pairClasses:[AnyClass])->BaseMatch{
        let match = BaseMatch();
        if pairClasses.count == 1 {
            match.pairClass = pairClasses.first;
        }
        match.pairKeys = keys;
        return match;
    }
    
    
    
}
