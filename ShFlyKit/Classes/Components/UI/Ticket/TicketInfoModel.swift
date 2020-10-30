//
//  TicketInfoModel.swift
//  SHKit
//
//  Created by hsh on 2019/11/22.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///座位的信息
public class TicketInfo: NSObject {
    ///最优配置
    public var optimalRow:Int = 4                       //最优行的开始-例从第四行开始最优
    public var optimalCount:Int = 4                     //最优行有几个-例从4-7都是最优行
    public var optimalColumn:Int = 8                    //最优列的个数-例偶数为8，奇数多+1
    //数据
    public private(set) var maxColumn:Int = 0           //所有列数最大值
    public private(set) var maxRow:Int = 0              //所有行数最大值
    public var rows:[TicketRowInfo] = []                //每列的信息
    
    
    //推荐的初始化方法 传入的数据格式 ["1-1-0","1-2-1"] - 其中最后的0/1 代表是否已售,1-1代表一排一座
    class public func initSeatInfos(_ seats:[String])->TicketInfo{
        let info = TicketInfo()
        for it in seats {
            if it.count >= 5 {  //符合格式才解析,字符串长度5
                let arr = it.split(separator: "-"); //取列
                if arr.count > 2 {
                    //取行
                    let rowStr:String = String(arr.first!);
                    let row = Int.init(rowStr)!;
                    //取列
                    let column:String = String(arr[1]);
                    let columnNum = Int.init(column)!;
                    info.maxColumn = max(info.maxColumn,columnNum)
                    info.maxRow = max(info.maxRow,row)
                    //取已售
                    let sold:String = String(arr[2]);
                    info.appendSeat(row:row,column: columnNum, sold: Int.init(sold)! == 1);
                }
            }
        }
        return info;
    }
    
    
    
    //重置已选为可选
    public func resetToAvaiable(){
        //重置所有选择状态
        for row in self.rows {
            for seat in row.seats {
                if seat.status == .select{
                    seat.status = .availble;
                }
            }
        }
    }
    
    
    //是否有空行,把前面的空行累加,空的行一定是在实的行前面，加入的时候限制了
    public func getOffsetRow(_ row:Int)->Int{
        var offsetRow:Int = 0;
        for tmp in self.rows {
            if tmp.seats.count == 0 && tmp.row <= row {
                offsetRow += 1;
            }
        }
        return offsetRow;
    }
    
    
    
    //添加记录-可自行实例化TicketInfo，然后按照自己格式解析，然后使用该方法填充数据
    public func appendSeat(row:Int,column:Int,sold:Bool){
        let seat = TicketSeatInfo()
        seat.row = row;
        seat.column = column;
        seat.status = sold == true ? SeatStatus.solded : SeatStatus.availble;
        //获取或者创建行信息
        func getRowInfo(_ row:Int)->TicketRowInfo{
            //空的数据有多少
            var emptyCount:Int = 0;
            //遍历当前座位
            for it in self.rows {
                //如果找到，并且是有效行
                if it.row == row {
                    if it.seats.count > 0 {
                        return it;
                    }else{
                        emptyCount += 1;
                    }
                }
            }
            //没有新建
            let tmp = TicketRowInfo()
            tmp.row = row;
            //当要插入空行
            if emptyCount == 0 {
                self.rows.append(tmp);
            }else if emptyCount == 1 && column > 0{
            //仅允许插入一次空行
                self.rows.append(tmp);
            }
            return tmp;
        }
        //获取对应的行
        let rowInfo = getRowInfo(row);
        //有效的座位添加，无效的座位不添加
        if seat.column > 0 {
            rowInfo.appendSeat(seat);
        }
    }
    
    

    ///推荐座位->返回推荐的位置-默认是要连续的
    public func recommendSeats(count:NSInteger,maxSelectCount:Int,series:Bool = true)->[TicketSeatInfo]{
        //重置选择状态
        self.resetToAvaiable();
        //找出最优行
        let person = min(count,maxSelectCount);
        //初始位置
        let bestRow:Int = self.optimalRow + getOffsetRow(self.optimalRow);
        let bestColumn:Int = self.maxColumn % 2 == 0 ? self.optimalColumn : self.optimalColumn + 1;
        //遍历查找
        var tmpArr:[TicketSeatInfo] = [];
        var rowStep:Int = 0;         //行步进值
        var stopStatus:Int = 0;      //停止的标志 1为到达最后排 2为到达最前排 3已经够了
        
        //获取对应的位置
        func getSeat(_ rowInfo:TicketRowInfo,column:Int)->TicketSeatInfo?{
            var tmpSeat:TicketSeatInfo?
            for seat in rowInfo.seats {
                if seat.column == (column) && seat.status == .availble {
                    tmpSeat = seat;
                    break;
                }
            }
            return tmpSeat;
        }
        //换行
        func changeRow(){
            if rowStep == 0 {
                rowStep += 1;
            }else if rowStep > 0{
                rowStep = -rowStep;
            }else{
                rowStep -= 1;
                rowStep = -rowStep;
            }
            //找到最后一行
            if (bestRow + rowStep) > self.maxRow {
                if stopStatus == 0 {
                    stopStatus += 1;
                }
            }else if (bestRow + rowStep < 1 ){
                //可以翻转找到第一行
                stopStatus += 1;
            }
        }
        
        //循环条件
        while stopStatus < 2 {
            //查找对应行
            var rowInfo:TicketRowInfo!
            for item in self.rows {
                if item.row == (bestRow+rowStep) && item.seats.count > 0 {
                    rowInfo = item;
                    break;
                }
            }
            //如果找到行
            if rowInfo != nil {
                //需要连续的位置时
                if series == true {
                    tmpArr.removeAll();
                }
                //边界
                var leftForbid:Bool = false;            //禁止往左
                var rightForbid:Bool = false;           //禁止往右
                var curIndex:Int = bestColumn;          //当前下标
                var maxIndex:Int = bestColumn;          //最大下标
                var minIndex:Int = bestColumn;          //最小下标
                
                //更新步进值
                func makeStep(){
                    //边界
                    if minIndex < 1 {leftForbid = true}
                    if maxIndex > self.maxColumn {rightForbid = true}
                    //判断
                    if leftForbid == false && rightForbid == false {
                        let index = maxIndex;
                        if abs(index - bestColumn) == abs(minIndex - bestColumn) {
                            curIndex = maxIndex + 1;
                        }else if (abs(index - bestColumn) > abs(minIndex - bestColumn)){
                            curIndex = minIndex - 1;
                        }else {
                            curIndex = maxIndex + 1;
                        }
                    }else if (leftForbid == true && rightForbid == false){
                        curIndex = maxIndex + 1;
                    }else if (leftForbid == false && rightForbid == true){
                        curIndex = minIndex - 1;
                    }
                    maxIndex = max(maxIndex,curIndex);
                    minIndex = min(minIndex,curIndex);
                }
                //是否先针对优选区域
                func rowSeatsForBestZone(_ chooseZone:Bool){
                    //添加座位
                    while (leftForbid == false || rightForbid == false) && tmpArr.count < person{
                        //获取该位置
                        let seat = getSeat(rowInfo, column: curIndex);
                        if seat != nil {
                            tmpArr.append(seat!);           //加入数组
                            makeStep();                     //更新下一个步进
                            if tmpArr.count >= person{      //终止内循环
                                stopStatus = 3;             //终止外层循环
                            }
                        }else{
                            //找不到的话
                            if series == true {
                                if curIndex < bestColumn {
                                    leftForbid = true;
                                }else if (curIndex > bestColumn){
                                    rightForbid = true;
                                }
                            }
                            makeStep();
                        }
                        //首先选区域
                        if chooseZone == true {
                            if rowInfo.row >= self.optimalRow && rowInfo.row < (self.optimalRow + self.optimalCount) {
                                let count = Int(floor(Double(self.optimalColumn)/2.0));
                                if curIndex - 1 <= bestColumn - count {
                                    leftForbid = true;
                                }else if (curIndex > bestColumn + count){
                                    rightForbid = true;
                                }
                            }
                        }
                    }
                }
                //先针对区域
                rowSeatsForBestZone(true);
                //优选区域找不到
                if tmpArr.count < person {
                    rowSeatsForBestZone(false)
                }
                //当前行已经找不到换行
                changeRow();
            }else{
                //找不到行翻转一次
                changeRow();
            }
        }
        //更改位置状态
        for seat in tmpArr{
            seat.status = .select;
        }
        return tmpArr;
    }
    
    
}




//每行的信息
public class TicketRowInfo:NSObject{
    public var row:Int = 0                  //行数
    public var seats:[TicketSeatInfo] = []  //没有位置，则这是一个空的一行，间隔
    
    
    //添加座位
    public func appendSeat(_ seat:TicketSeatInfo){
        //第一次直接添加
        if seats.count == 0 {
            seats.append(seat);
        }else if seats.count == 1{
            let obj = seats.first;
            //跟唯一的一个比
            if obj!.column < seat.column{
                seats.append(seat);
            }else if obj!.column > seat.column{
                seats.insert(seat, at: 0);
            }
        }else{
            //找到对应的index
            var index:Int = 0;
            var stop:Bool = false;
            //例当最少两个的时候
            while (index <= seats.count - 2 && stop == false) {
                //例 [0] 的元素 和 [1] 的元素
                let obj1 = seats[index];
                let obj2 = seats[index+1];
                //比第一个还小，就往前插入
                if obj1.column > seat.column{
                    seats.insert(seat, at: 0);
                    stop = true;
                }else if (obj2.column < seat.column){
                //比最后一个还大，就在末尾
                    seats.append(seat);
                    stop = true;
                }else if (obj1.column < seat.column && obj2.column > seat.column){
                //在两个元素之间，放到中间,不接受相等的数据
                    seats.insert(seat, at: index+1);
                    stop = true;
                }
                index += 1;
            }
        }
    }
    
    
}



//位置的状态
public enum SeatStatus {
    case availble,solded,select;                //分别是可用，已售，选择(操作的时候才有选择)
}


//单个座位信息
public class TicketSeatInfo:NSObject{
    public var row:Int = 0                      //第一排从1开始       - 为0是无效的
    public var column:Int = 0                   //第一列从1开始       - 为0是无效的
    public var status:SeatStatus = .availble;   //位置的状态          - 默认可用
    public var btn:UIButton!                    //对应的点击按钮       -用于更改按钮状态
}
