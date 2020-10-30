//
//  HeatBeatTimer.swift
//  SHLibrary
//
//  Created by 黄少辉 on 2018/3/22.
//  Copyright © 2018年 黄少辉. All rights reserved.
//


import UIKit

///定时器回调
@objc public protocol HeatBeatTimerDelegate:NSObjectProtocol {
    //定时器调用
    @objc optional func timeTaskCalled(identifier:String)
    //定时器调用含次数
    @objc optional func timeCallTimes(times:Int,identifier:String)
}


///CADisplayLink回调
@objc public protocol DisplayDelegate:NSObjectProtocol {
    func displayCalled()
}


///定时任务信息
public class TimerTask: NSObject {
    public weak var delegate:HeatBeatTimerDelegate?                 //定时回调
    public var taskIdentifier:String!                               //任务识别键
    public var taskBeatSpan:Int!                                    //任务执行间隔
    public var runLimit:Int = 0                                     //0为不限制次数
    public var runCount:Int = 0                                     //任务执行次数
    public var beatCountNumer:Int = 0                               //自增的数字-每秒增加1
    //创建定时任务
    class public func initTimeTask(taskKey:String,span:Int,repeatCount:Int = 0,delegate:HeatBeatTimerDelegate)->TimerTask{
        let task = TimerTask()
        task.delegate = delegate;
        task.taskIdentifier = taskKey;
        task.taskBeatSpan = span;
        task.runLimit = repeatCount;
        return task
    }
}


///display任务信息
public class DisplayTask:NSObject{
    public weak var delegate:DisplayDelegate?
}


///定时器类
public class HeatBeatTimer: NSObject {
    /// MARK: - Variable
    public static let shared = HeatBeatTimer();
    private var heartbeatTimer:Timer!                                                   //心跳定时器
    private var beatTaskSet:[TimerTask] = []                                            //任务信息
    
    //CADisplayLink
    private var displayLink:CADisplayLink?                                              //cadisplaylink
    private var displayTasks:[DisplayTask] = []                                         //display定时器任务
    
    
    //循环任务
    @objc public func distrubuteTask()->Void{
        var clearArr:[Int] = [];
        for (index,task) in self.beatTaskSet.enumerated() {
            if task.delegate != nil{
                task.beatCountNumer += 1;
                //达到时间间隔调用一次
                if (task.beatCountNumer % task.taskBeatSpan == 0){
                    task.delegate?.timeTaskCalled?(identifier: task.taskIdentifier);
                    task.runCount += 1;
                    task.delegate?.timeCallTimes?(times: task.runCount, identifier: task.taskIdentifier);
                    //运行到一定次数移除或者不存在
                    if ((task.runCount >= task.runLimit)&&task.runLimit > 0) {
                        clearArr.append(index);
                    }
                }
            }else{
                clearArr.append(index);
            }
        }
        for index in clearArr.reversed(){
            //防止已经被移除
            if index < beatTaskSet.count{
                beatTaskSet.remove(at: index);
            }
        }
    }
    
    
    //添加任务/覆盖任务
    public func addTimerTask(identifier:String,span:Int,repeatCount:Int,delegate:HeatBeatTimerDelegate,executeRightNow:Bool = true)->Void{
        let task = TimerTask.initTimeTask(taskKey: identifier, span: span, repeatCount: repeatCount, delegate: delegate);
        //加入是否立即执行一次
        if executeRightNow == true {
            task.delegate?.timeTaskCalled?(identifier: identifier);
            task.runCount += 1;
            task.beatCountNumer += 1;
            task.delegate?.timeCallTimes?(times: task.runCount,identifier: task.taskIdentifier);
        }
        //开始启动定时器,保证时间间隔
        if heartbeatTimer == nil {
            heartbeatTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(distrubuteTask), userInfo: nil, repeats: true)
            RunLoop.current.add(heartbeatTimer, forMode: RunLoopMode.commonModes);
        }
        var same = false;
        for task in beatTaskSet {
            if task.taskIdentifier == identifier {
                same = true;
                break;
            }
        }
        if same == false {
            beatTaskSet.append(task);
        }
    }
    
    
    //移除任务
    public func cancelTaskForKey(taskKey:String)->Void{
        var index = -1;
        for (i,item) in beatTaskSet.enumerated() {
            if item.taskIdentifier == taskKey{
                index = i;
                break;
            }
        }
        if index >= 0 && index < beatTaskSet.count{
            beatTaskSet.remove(at: index);
        }
    }
    
    
    //添加CADisplayLink定时器任务
    public func addDisplayTask(_ delegate:DisplayDelegate?)->Void{
        //添加任务
        let task = DisplayTask()
        task.delegate = delegate;
        var same = false;
        for item in displayTasks {
            if item.delegate?.isEqual(delegate) ?? false{
                same = true;
                break;
            }
        }
        if same == false {
            displayTasks.append(task);
        }
        //没有定时器，创建
        if displayLink == nil {
            displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkSelector));
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes);
        }
        //CADisplayLink启动
        displayLink?.isPaused = false;
    }
    
    
    //移除CADisplayLink定时器任务
    public func cancelDisplayTask(_ delegate:DisplayDelegate?)->Void{
        //找到对应的代理
        var clearArr:[Int] = [];
        for (index,task) in displayTasks.enumerated() {
            if (task.delegate?.isEqual(delegate))!{
                clearArr.append(index);
            }
        }
        //清理任务
        for index in clearArr.reversed(){
            if index < displayTasks.count{
                displayTasks.remove(at: index);
            }
        }
    }
    
    
    //display定时器任务调用
    @objc private func displayLinkSelector()->Void{
        //将要被清理的任务记录
        var clearArr:[Int] = [];
        //调用任务
        for (index,task) in displayTasks.enumerated() {
            if task.delegate != nil{
                DispatchQueue.main.async {
                    task.delegate?.displayCalled();
                }
            }else{
                clearArr.append(index);
            }
        }
        //清理无代理的任务
        for index in clearArr.reversed(){
            if index < displayTasks.count{
                displayTasks.remove(at: index);
            }
        }
        //CADisplayLink暂停
        if displayTasks.count == 0 {
            displayLink?.isPaused = true;
        }
    }
    
    
}
