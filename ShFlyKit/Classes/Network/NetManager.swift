//
//  SHNetManager.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/2/26.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

import UIKit
import AFNetworking



///网络代理类
protocol SHNetManagerDelegate:NSObjectProtocol {
    //返回响应报文
    func responseWithResult(_ result:Any?);
}


///应用环境
public enum Environment {
    case Debug,PreRelease,Release
}


///请求类
class NetManager: NSObject , HeatBeatTimerDelegate{
    //MARK
    static  let shareInstance = NetManager.init()                                     //单例
    private var netStatus = NetStatus.shareInstance                                   //状况信息
    public  var dataSource = NetDataSource()                                               //请求的数据库
    private var manager:AFHTTPSessionManager!                                           //AFN
    //配置项
    public  var environment = Environment.Debug                                         //当前环境
    public  var timeOutInterval:TimeInterval = 20.0                                     //超时时间
    //Storage
    private var taskArray = NSMutableArray()                                            //任务数组-正常一次成功的流程
    private var retryArray = NSMutableArray()                                           //失败后的处理数组
    public  var saveArray = NSMutableArray()                                            //将要保存的模型
    public  var memoryCacheMap = NSMutableDictionary()                                  //保存到内存中的数据--例如给外界使用
    
    
    ///MARK-load
    override init() {
        super.init();
        //初始化
        manager = AFHTTPSessionManager(sessionConfiguration: URLSessionConfiguration.default)
        //支持text/html,application/json
        var set:Set<String> = Set()
        set.insert("text/html");
        set.insert("application/json");
        manager.responseSerializer.acceptableContentTypes = set;
        manager.requestSerializer.timeoutInterval = timeOutInterval;
        NetStatus.shareInstance.startMonitor();
        HeatBeatTimer.shared.addTimerTask(identifier: "retryRequest", span: 2, repeatCount: 0, delegate: self);
    }
    
    
    
    //定时器回调-重试失败的情况
    func timeTaskCalled(identifier: String) {
        let req:BaseRequest? = retryArray.firstObject as? BaseRequest;
        if req != nil {
            //确认是否继续
            func checkRetry(_ req:BaseRequest, count:Int)->Bool{
                if req.retryCount >= count {
                    if req.requestSenderView != nil{
                        req.requestSenderView?.isUserInteractionEnabled = true
                    }
                    let dict = NSMutableDictionary()
                    dict.setValue(-1, forKey: "ret");
                    dict.setValue("请求失败", forKey: "msg")
                    req.responseWithResult(dict)
                    return false;
                }
                return true;
            }
            //网络环境会变化
            switch netStatus.pingInfo.quality{
            case .best://网络很好的情况下
                if (checkRetry(req!, count: 1) == false){saveArray.remove(req!);return};
            case .good://网络还不错
                if (checkRetry(req!, count: 2) == false){saveArray.remove(req!);return};
            case .poor://网络差，但是有可能联通 - 重试一次，然后丢回不管,等待网络变好
                if (req!.retryCount >= 1){
                    req?.retryCount = -1;
                }
                if req!.retryCount == -1 {
                     return;
                }
            case .unavailable://网络不可达时停止
                return;
            }
            req?.retryCount += 1;
            request(req!);
        }
    }
    

    
    //开始请求
    func request(_ request:BaseRequest)->Void{
        //字典转字符串
        func dictToJsonString(dict:NSDictionary)->String{
            let data:Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
            var param:String = "";
            if data != nil {
                param = String.init(data: data! , encoding: String.Encoding.utf8)!
            }
            return param
        }
        ///清空给定的任务数组回调
        func completeTask(task:BaseRequest)->Void{
            objc_sync_enter(self);
            if taskArray.contains(task) {
                 taskArray.remove(task);
            }else{
                 retryArray.remove(task);
            }
            objc_sync_exit(self);
        }
        ///判断是否有重复请求
        func checkRepeat(urlKey:String)->Bool{
            var isRepeat = false;
            for item in taskArray {
                let task:BaseRequest = item as! BaseRequest
                let taskParam = dictToJsonString(dict: task.body);
                if ((task.url + taskParam).md5 == urlKey){
                    isRepeat = true
                    break;
                }
            }
            return isRepeat;
        }
        ///处理成功返回的请求
        func responseSucHandler(resObj:Any?,req:BaseRequest)->Void{
            //触发的控件恢复可点击
            if req.requestSenderView != nil{
                req.requestSenderView?.isUserInteractionEnabled = true
            }
            //响应及清理任务
            req.responseWithResult(resObj);
            completeTask(task:req)
        }
        ///请求失败处理
        func responseFailHandler(error:Error,req:BaseRequest)->Void{
            //加入重试数组
            retryArray.add(req);
        }
        //不存在网址
        if request.url.count == 0{
            return
        }
        //body字典转换成字符串保存
        let param = dictToJsonString(dict: request.body)
        //创建唯一的url标识
        let urlKey:String = (request.url + param).md5;
        if  checkRepeat(urlKey: urlKey) {//判断当前是否有重复的请求，有的话，拒绝后面发起的请求
            return
        }
        //毫秒
        let time = Int(Date().timeIntervalSince1970*1000);
        //根据URL,请求参数，请求时间算出一个唯一的MD5
        let md5Key:String = (request.url + param + "\(time)").md5
        request.md5 = md5Key;
        request.urlKey = urlKey;
        //先加载之前最近的一条结果
        if request.loadLast {
            let net:NetModel? = dataSource.queryForUrlKey(request.urlKey).first;
            if net != nil && (net!.isSuccess == 1){
                responseSucHandler(resObj: net?.responseObj, req: request);
            }
        }
        //创建要保存的模型
        let netModel = NetModel.convertBaseRequestToNetModel(request);
        netModel.createTime = time;
        netModel.body = param;
        dataSource.saveRequests([netModel]);
        //创建请求任务
        var dataTask:URLSessionDataTask!
        switch request.method {
        case Method.GET:
            dataTask = manager.get(request.url, parameters: param, headers: [ : ], progress: { (progress) in
            }, success: { (task, resObj) in
                responseSucHandler(resObj: resObj ,req: request)
            }, failure: { (task, error) in
                responseFailHandler(error: error ,req: request)
            })
            break
        case Method.POST:
            dataTask = manager.post(request.url, parameters: param, headers: [ : ], progress: { (progress) in
            }, success: { (task, resObj) in
                responseSucHandler(resObj: resObj ,req: request)
            }, failure: { (task, error) in
                responseFailHandler(error: error ,req: request)
            })
            break
        case Method.DELETE:
            dataTask = manager.delete(request.url, parameters: param, headers: [ : ], success: { (task, resObj) in
                responseSucHandler(resObj: resObj ,req: request)
            }, failure: { (task, error) in
                responseFailHandler(error: error ,req: request)
            })
            break
        case Method.PUT:
            dataTask = manager.put(request.url, parameters: param, headers: [ : ], success: { (task, resObj) in
                responseSucHandler(resObj: resObj ,req: request)
            }, failure: { (task, error) in
                responseFailHandler(error: error ,req: request)
            })
            break
        }
        //任务开始前禁用控件
        if request.requestSenderView != nil{
           request.requestSenderView?.isUserInteractionEnabled = false
        }
        //添加请求到数组
        taskArray.add(request);
        saveArray.add(netModel);
        //任务开始
        dataTask.resume()
        //显示loading
        if request.showProgress {
            
        }
        //显示log
        if request.needLog {
            print(request.url!);
        }
    }
    
    
}
