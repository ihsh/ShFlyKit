//
//  CalendarEvent.swift
//  SHKit
//
//  Created by 黄少辉 on 2020/6/19.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import EventKitUI
import EventKit


///结果枚举
enum EventResult{
    case Error,NotGranted,SaveEror,Success      //错误，未授权，异常，成功
}


//protocol
protocol CalendarEventDelegate:NSObjectProtocol {
    //回传调用结果
    func handleResult(status:EventResult,error:Error?)
    //回传日历事件
    func handleEkEvents(events:[EKEvent])
}



///处理日历日程
class CalendarEventHandler: UIView {
    //Variable
    public weak var delegate:CalendarEventDelegate?
    //Private
    private var eventStone = EKEventStore()

    
    
    //保存一个日程
    public func saveCalendar(title:String,location:String,note:String,start:Date,durations:TimeInterval,alarmOffset:TimeInterval){

        //请求权限
        eventStone.requestAccess(to: .event) { (granted, error) in
            
            if (error != nil){
                self.delegate?.handleResult(status: .Error, error: error);
            }else if (granted == false){
                self.delegate?.handleResult(status: .NotGranted, error: nil);
            }else{
                DispatchQueue.main.async {
                    let event = EKEvent.init(eventStore: self.eventStone);
                    event.title = title;                    //标题
                    event.location = location;              //位置
                    event.notes = note;                     //备注
                    event.startDate = start;                //开始时间
                    event.endDate = start.addingTimeInterval(durations);//持续时间
                    event.addAlarm(EKAlarm.init(relativeOffset: alarmOffset));//提醒时间偏移，负数为提前，淡味秒
                    event.calendar = self.eventStone.defaultCalendarForNewEvents;
                    if ((try? self.eventStone.save(event, span: EKSpan.thisEvent)) != nil){
                        self.delegate?.handleResult(status: .Success, error: nil);
                    }else{
                        self.delegate?.handleResult(status: .SaveEror, error: nil);
                    }
                }
            }
        }
    }
    
    
    
    //调用系统控制器的添加日历
    public func callEKEventEdit(holdVC:UIViewController){
        
        eventStone.requestAccess(to: .event) { (granted, error) in
            if (error != nil){
                self.delegate?.handleResult(status: .Error, error: error);
            }else if (granted == false){
                self.delegate?.handleResult(status: .NotGranted, error: nil);
            }else{
                DispatchQueue.main.async {
                    //系统添加日历控制器
                    let addController = EKEventEditViewController.init(nibName: nil, bundle: nil);
                    addController.event = EKEvent.init(eventStore: self.eventStone);
                    addController.eventStore = self.eventStone;
                    addController.editViewDelegate = holdVC as? EKEventEditViewDelegate;
                    holdVC.present(addController, animated: true, completion: nil);
                }
            }
        }
        
    }
    
    
    
    //获取时间段内所有日历事件
    public func getCalendarEvents(start:Date?,end:Date?){
        
        //请求权限并获取事件
        eventStone.requestAccess(to: .event) { (granted, error) in
            
            if (error != nil){
                self.delegate?.handleResult(status: .Error, error: error);
            }else if (granted == false){
                self.delegate?.handleResult(status: .NotGranted, error: nil);
            }else{
                var tmpArr:[EKEvent] = [];
                //生成过滤器
                let predicate = self.eventStone.predicateForEvents(withStart: start ?? Date.init(timeIntervalSince1970: 0),
                                                                   end: end ?? Date(),
                                                                   calendars: [self.eventStone.defaultCalendarForNewEvents!]);
                //获取事件
                let events = self.eventStone.events(matching: predicate);
                for ev in events{
                    tmpArr.append(ev);
                }
                self.delegate?.handleEkEvents(events: tmpArr);
            }
        }
    }
                    
    
}
