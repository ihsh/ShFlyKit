//
//  LineDotV.swift
//  SHKit
//
//  Created by hsh on 2019/8/23.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit


//数据代理
protocol LineDataSource:NSObjectProtocol {
    //陆续的返回数据
    func returnDataAsync(_ plans:[PlanInfo]);
}


//站点信息处理类
class LineStaionV: UIView {
    //Variable
    static let shared = LineStaionV()              //单例
    public weak var delegate:LineDataSource?       //代理
    public var limit:Int = 5                       //取结果最大限制
    
    private var loadCompleted:Bool = false         //是否加载完全
    private var lines:[LineInfo] = []              //线路信息存储
    private var plans:[PlanInfo] = []              //路线规划信息
    private let group = DispatchGroup()
    
    
    //获取对应站点
    public func getStation(_ pos:CGPoint)->DotInfo?{
        //没有加载完全
        if loadCompleted == false {
            return nil;
        }
        for line in lines {
            //在线路上的所有点查找
            for dot in line.stations + line.subLine1 + line.subLine2 {
                if (fabs(pos.x - dot.point.x) < 5) {
                    if fabs(pos.y - dot.point.y) < 5 {
                        return dot;
                    }
                }
            }
        }
        return nil;
    }
    
    
    //获取路线规划
    public func getLinePlan(_ startName:String,endName:String){
        //相同名称的无效
        if startName == endName {
            return;
        }
        //获取起始站所在的线路数组
        var startLines:[LineInfo] = [];
        var endLines:[LineInfo] = [];
        for line in lines {
            //从所有点中获取,深拷贝
            for station in line.stations + line.subLine1 + line.subLine2 {
                if station.name == startName{
                    let tmp:LineInfo = line.copy() as! LineInfo;
                    tmp.select = startName;
                    startLines.append(tmp);
                }
                if station.name == endName{
                    let tmp:LineInfo = line.copy() as! LineInfo;
                    tmp.select = endName;
                    endLines.append(tmp);
                }
            }
        }
        //获取相交的线路编码
        func interSectionNumForArray(array1:[Int],tmp1:Int?,array2:[Int],tmp2:Int?)->Int{
            var result = -1;
            var new1:[Int] = array1;
            if tmp1 != nil {
                new1 = [Int]();
                new1.append(contentsOf: array1);
                new1.append(tmp1!);
            }
            var new2:[Int] = array2;
            
            if tmp2 != nil {
                new2 = [Int]();
                new2.append(contentsOf: array2);
                new2.append(tmp2!);
            }
            for num in new1{
                for code in new2{
                    if num == code{
                        result = num;
                        break;
                    }
                }
            }
            return result;
        }
        //获取不同时相交的线,同时与起始线和终点线相交只要换两次
        func notBothInterSectionLine(line:LineInfo,end:LineInfo)->[LineInfo]{
            var chooseLines:[LineInfo] = [];
            for it in LineStaionV.shared.lines{
                if it.code != line.code && it.code != end.code {
                    //不能同时跟两条线相交
                    let tmp1 = it.isInterSectionWithLine(line.code);
                    let tmp2 = it.isInterSectionWithLine(end.code);
                    if tmp1 == false || tmp2 == false{
                         chooseLines.append(it);
                    }
                }
            }
            return chooseLines;
        }
        //从不同的层级开始查找-匿名函数
        func searchForLevel(level:Int,it:DotInfo,line:LineInfo){
            if level < 1 {
                //直达的路线-起点和终点有在相同的线路上.直达的只有一种
                for end in endLines{
                    if line.code == end.code {
                        let rootPath = SearchPath();
                        rootPath.addSubPath(start: line.select!, code: line.code, end: end.select!);
                        addPlanWithOutSame(plan: rootPath.commitPath());
                        break;
                    }
                }
            }else if level == 1 {
                //只转乘一次
                for end in endLines {
                    //首先找线路不同;两两条线路相交，相交点不是起点和终点
                    if it.changeLines.count > 0 && line.code != end.code && it.name != startName && it.name != endName{
                        //转乘点有到终点上的线路
                        if it.changeLines.contains(end.code) {
                            let rootPath = SearchPath();
                            rootPath.addSubPath(start: line.select!, code: line.code, end: it.name);        //起点到转乘点
                            rootPath.addSubPath(start: it.name, code: end.code, end: end.select!);          //转乘点到终点/终点-终点，去除
                            self.addPlanWithOutSame(plan: rootPath.commitPath());
                        }
                    }
                }
            }else if level == 2 {
                let queue = DispatchQueue.init(label: String(format: "leveltwo%l",line.code));
                queue.async(group: group, execute: DispatchWorkItem.init(block: {
                //转乘两次
                for end in endLines {
                        //相同线路的排除;起始线上非起点的转乘点；
                        if it.changeLines.count > 0 && line.code != end.code && it.name != startName && it.name != endName {
                            //在终点线上找符合的点
                            for dot in end.stations + end.subLine1 + end.subLine2{
                                //终点线上遍历，非终点，且是转乘点
                                if dot.changeLines.count > 0 && dot.name != endName && dot.name != startName {
                                    //转乘点上包含起始的转乘点相同的线路，可达
                                    let num = interSectionNumForArray(array1: dot.changeLines,tmp1: nil, array2: it.changeLines,tmp2: nil);
                                    if num > 0 {
                                        let rootPath = SearchPath();
                                        rootPath.addSubPath(start: line.select!, code: line.code, end: it.name);    //起点到起始线的转乘点
                                        rootPath.addSubPath(start: it.name, code: num, end: dot.name);              //起始转乘点到终点转乘点
                                        rootPath.addSubPath(start: dot.name, code: end.code, end: end.select!);     //终点转乘点到终点
                                        self.addPlanWithOutSame(plan: rootPath.commitPath());
                                    }
                                }
                            }
                        }
                    }
                }))
            }else if level == 3{
                let queue = DispatchQueue.init(label: String(format: "levelthree%l",line.code));
                queue.async(group: group, execute: DispatchWorkItem.init(block: {
                //需要转乘3次
                for end in endLines {
                        //首先找线路不同;排除起始点本身也是转乘点，其实是直达的线路
                        if it.changeLines.count > 0 && line.code != end.code && it.name != startName && it.name != endName {
                            //可供查找的线路-在这些线路里面找-外层循环最少次,里面的线不可以跟起始点都相交，最多一条
                            let chooseLines = notBothInterSectionLine(line: line, end: end);
                            //终点线上的非终点转乘点
                            for dot in end.stations + end.subLine1 + end.subLine2 {
                                if dot.changeLines.count > 0 && dot.name != endName && dot.name != startName {
                                    //从中间可选的线路中找到点，可以连接起始线上的转乘点
                                    for tmpLine in chooseLines{
                                        for station in tmpLine.stations + tmpLine.subLine1 + tmpLine.subLine2 {
                                            if station.changeLines.count > 0 && station.name != startName && station.name != endName {
                                                let num1 = interSectionNumForArray(array1: it.changeLines,tmp1: nil, array2: station.changeLines,tmp2: tmpLine.code);
                                                //自己本身也是一个连接线
                                                let num2 = interSectionNumForArray(array1: station.changeLines,tmp1: nil, array2: dot.changeLines,tmp2: nil);
                                                //找到连接点
                                                if num1 > 0 && num2 > 0 {
                                                    let rootPath = SearchPath();
                                                    rootPath.addSubPath(start: line.select!, code: line.code, end: it.name);    //起点到起始线的转乘点
                                                    rootPath.addSubPath(start: it.name, code: num1, end: station.name);
                                                    rootPath.addSubPath(start: station.name, code: num2, end: dot.name);
                                                    rootPath.addSubPath(start: dot.name, code: end.code, end: end.select!);
                                                    self.addPlanWithOutSame(plan: rootPath.commitPath());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }))
            }else if level == 4{
                let queue = DispatchQueue.init(label: String(format: "levelfour%l",line.code));
                queue.async(group: group, execute: DispatchWorkItem.init(block: {
                //需要转乘4次
                for end in endLines {
                        //首先找线路不同;排除起始点本身也是转乘点，其实是直达的线路
                        if it.changeLines.count > 0 && line.code != end.code && it.name != startName && it.name != endName {
                            //可供查找的线路-在这些线路里面找-外层循环最少次,里面的线不可以跟起始点都相交，最多一条
                            let chooseLines = notBothInterSectionLine(line: line, end: end);
                            //终点线上的非终点转乘点
                            for dot in end.stations + end.subLine1 + end.subLine2 {
                                if dot.changeLines.count > 0 && dot.name != endName && dot.name != startName {
                                    //从中间可选的线路中找到点，可以连接起始线上的转乘点
                                    for tmpLine1 in chooseLines{
                                        for tmpline2 in chooseLines {
                                            //选出两个不同的线路
                                            if tmpLine1.code != tmpline2.code {
                                                for sta1 in tmpLine1.stations + tmpLine1.subLine1 + tmpLine1.subLine2{
                                                    for sta2 in tmpline2.stations + tmpline2.subLine1 + tmpline2.subLine2{
                                                        
                                                        if sta1.changeLines.count > 0 && sta2.changeLines.count > 0 && sta1.name != sta2.name && sta1.name != startName && sta1.name != endName && sta2.name != startName && sta2.name != endName{

                                                            let tmp1 = interSectionNumForArray(array1: it.changeLines,tmp1: nil, array2: sta1.changeLines,tmp2: tmpLine1.code);
                                                            if tmp1 == -1 {continue};
                                                            let tmp2 = interSectionNumForArray(array1: sta1.changeLines,tmp1: nil, array2: sta2.changeLines,tmp2: tmpline2.code);
                                                            if tmp2 == -1 {continue};
                                                            let tmp3 = interSectionNumForArray(array1: sta2.changeLines,tmp1: nil, array2: dot.changeLines,tmp2: end.code);
                                                            if tmp1 > 0 && tmp2 > 0 && tmp3 > 0 {
                                                                let rootPath = SearchPath();
                                                                rootPath.addSubPath(start: line.select!, code: line.code, end: it.name);
                                                                rootPath.addSubPath(start: it.name, code: tmp1, end: sta1.name);
                                                                rootPath.addSubPath(start: sta1.name, code: tmp2, end: sta2.name);
                                                                rootPath.addSubPath(start: sta2.name, code: tmp3, end: dot.name);
                                                                rootPath.addSubPath(start: dot.name, code: end.code, end: end.select!);
                                                                self.addPlanWithOutSame(plan: rootPath.commitPath());
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }))
            }
        }
        //运行次数
        func runForLevel(level:Int){
            for line in startLines{
                for it in line.stations + line.subLine1 + line.subLine2 {
                    searchForLevel(level: level, it: it,line: line);
                }
            }
        }
        //从直达到多次转乘开始查询
        //多核处理，合并数据
        let start = NSDate().timeIntervalSince1970;
        self.plans.removeAll();
        var step = 0;
        //有直达就只直达
        while (step < 1 || (step >= 1 && plans.count == 0)) {
            runForLevel(level: step);
            step += 1;
        }
        group.notify(queue: DispatchQueue.main) {
            let tmp = self.plans.sorted(by: { (a, b) -> Bool in
                return a.allTime < b.allTime;
            })
            var result:[PlanInfo] = [];
            for (i,obj) in tmp.enumerated(){
                if i < self.limit {
                    result.append(obj);
                }else{break;}
            }
            self.delegate?.returnDataAsync(result);
            let end = NSDate().timeIntervalSince1970;
            print("总耗时",end - start);
        };
    }
    
    
    
    //读取数据
    public func readFromPlist(name:String){
        //已有数据，不需要重复读取
        if self.lines.count > 0 {
            return;
        }
        //处理耗时的代码
        DispatchQueue.global(qos: .default).async {
            let listPath:String = Bundle.main.path(forResource: name, ofType: "plist")!;
            let arr:NSArray = NSArray(contentsOfFile: listPath)!;
            for index in 0...arr.count - 1 {
                //一个字典一个线路
                let dict:NSDictionary = arr[index] as! NSDictionary;
                //线路名称，数字编号，简称
                let name:String = dict.value(forKey: "name") as! String;
                let nick:String = dict.value(forKey: "nickname") as! String;
                let code:NSString = dict.value(forKey: "code") as! NSString;
                let circle:NSNumber = dict.value(forKey: "circle") as! NSNumber
                //初始化线路
                let line = LineInfo()
                line.name = name;
                line.nickName = nick;
                line.isCircle = circle.intValue == 1 ? true : false;
                line.code = code.integerValue;
                //所有的站点
                let stations:NSArray = dict.value(forKey: "stations") as! NSArray;
                //传入字典创建一个站点信息
                func getStationForDict(_ sta:NSDictionary)->DotInfo{
                    let na:String = sta.value(forKey: "name") as! String;
                    let x:NSString = sta.value(forKey: "x") as! NSString;
                    let y:NSString = sta.value(forKey: "y") as! NSString;
                    let time:NSString = sta.value(forKey: "time") as! NSString;
                    let info = DotInfo()
                    info.name = na;
                    info.timeBase = time.integerValue;
                    info.point = CGPoint(x: x.doubleValue, y: y.doubleValue);
                    return info;
                }
                //遍历站点
                for i in 0...stations.count-1{
                    let obj:AnyObject = stations[i] as AnyObject;
                    //普通主线站点
                    if obj.isKind(of: NSDictionary.self){
                        let sta:NSDictionary = obj as! NSDictionary;
                        let info = getStationForDict(sta);
                        line.stations.append(info);
                    }else if obj.isKind(of: NSArray.self){
                        //支线信息
                        let tmpArray:NSArray = obj as! NSArray;
                        for index in 0...tmpArray.count-1{
                            var tmpResult:[DotInfo] = [];
                            let emu:NSArray = tmpArray[index] as! NSArray;
                            //遍历支线的点
                            for j in 0...emu.count-1{
                                let item:NSDictionary = emu[j] as! NSDictionary;
                                tmpResult.append(getStationForDict(item));
                            }
                            //一般只有两条支线
                            if index == 0 {
                                line.subLine1 = tmpResult;
                            }else if index == 1{
                                line.subLine2 = tmpResult;
                            }
                        }
                        if i == 0 {//有支线的时候，前面没有站点，是为始
                            line.subFirst = true;
                        }
                    }
                }
                self.lines.append(line);
            }
            //统计转乘点
            for index in 0...self.lines.count-1{
                //每一条线
                let line = self.lines[index];
                //每一个站点
                for station in line.stations + line.subLine1 + line.subLine2 {
                    for j in 0...self.lines.count - 1{
                        //找不同的线
                        if j != index {
                            let lineTmp = self.lines[j];
                            //找相交的点
                            for tmp in lineTmp.stations + lineTmp.subLine1 + lineTmp.subLine2{
                                if tmp.name == station.name{
                                    //同一个站点只会跟一条线的一个站相交,互为相交
                                    if station.changeLines.contains(lineTmp.code) == false{
                                        station.changeLines.append(lineTmp.code);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.loadCompleted = true;
        }
    }
    
    
    //根据编号获取对应路线
    public func getlineForCode(_ code:Int)->LineInfo?{
        for line in lines{
            if line.code == code{
                return line;
            }
        }
        return nil;
    }
    
    
    //添加不重复的路线
    private func addPlanWithOutSame(plan:PlanInfo){
        var hasSame = false;
        for it in plans{
            //已有的路线是否有重复的
            let same = it.isSameLines(plan);
            if same == true {
                hasSame = true;
                break;
            }
        }
        if hasSame == false {
            objc_sync_enter(self);
            plans.append(plan);
            objc_sync_exit(self);
        }
    }
    
    
}



//线路信息
class LineInfo:NSObject,NSCopying{
    public var code:Int = 1             //线路编号
    public var name:String!             //站点名称
    public var nickName:String?         //昵称
    public var stations:[DotInfo] = []  //主线站点
    public var subLine1:[DotInfo] = []  //支线1
    public var subLine2:[DotInfo] = []  //支线2
    public var subFirst:Bool = false    //分线是否是开始的
    public var isCircle:Bool = false    //是否是环线
    public var select:String?           //选择的点-拷贝值
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let info = LineInfo()
        info.code = self.code;
        info.name = self.name;
        info.nickName = self.nickName;
        info.stations = self.stations;
        info.subLine1 = self.subLine1;
        info.subLine2 = self.subLine2;
        info.isCircle = self.isCircle;
        info.subFirst = self.subFirst;
        return info;
    }
    
    
    //获取一个线路上两个站点之间的所有站-支线和环线的处理
    public func getStationsInLine(start:String,end:String)->[DotInfo]{
        //异常参数
        if start == end {
            return [];
        }
        //变量
        var tmp:[DotInfo] = [];
        var startIndex:Int = -1;
        var endIndex:Int = -1;
        //获取可用的线路数据
        var lineStations:[[DotInfo]] = [];
        //有支线,就同时存在两条
        if self.subLine1.count > 0 {
            //支线生成完整路径-自定义方法
            func generateLine(sub:[DotInfo]){
                var lineTmp:[DotInfo] = [];
                for it in (subFirst == true ? (sub + self.stations) : (self.stations + sub)){
                    lineTmp.append(it);
                }
                lineStations.append(lineTmp);
            }
            //生成主线与支线1的路径
            generateLine(sub: self.subLine1);
            //生成主线与支线2的路径
            generateLine(sub: self.subLine2);
            //两个支线构成一条线
            var center:DotInfo = (subFirst == true ? self.stations.first! : self.stations.last)!;
            //直接构成路径的临时数组
            var lineTmp:[DotInfo] = [];
            var tmpStations:[DotInfo] = [];
            if subFirst == true{
                tmpStations.append(contentsOf: self.subLine1);
                tmpStations.append(center);
                tmpStations.append(contentsOf: self.subLine2.reversed());
            }else{
                tmpStations.append(contentsOf: self.subLine1.reversed());
                tmpStations.append(center);
                tmpStations.append(contentsOf: self.subLine2);
            }
            for it in tmpStations{
                lineTmp.append(it);
            }
            lineStations.append(lineTmp);
        }else{
            //只有主线
            var tmp:[DotInfo] = [];
            for it in self.stations{
                tmp.append(it);
            }
            lineStations.append(tmp);
        }
        
        //选中的站点--在最多三条的路线中查询
        var selectStations:[DotInfo]!           //选中的路径
        for obj in lineStations{
            var tmp1 = -1;
            var tmp2 = -1;
            //找出起止点
            for index in 0...obj.count-1 {
                let dot = obj[index];
                if dot.name == start{
                    tmp1 = index;
                }
                if dot.name == end{
                    tmp2 = index;
                }
                //找到路线了
                if tmp1 != -1 && tmp2 != -1 {
                    selectStations = obj;
                    startIndex = tmp1;
                    endIndex = tmp2;
                    break;
                }
            }
        }
        //下标都找到
        if startIndex >= 0 && endIndex >= 0  {
            var reverse = false;
            //交换顺序
            if startIndex > endIndex {
                let tmpIndex = startIndex;
                startIndex = endIndex;
                endIndex = tmpIndex;
                reverse = true;
            }
            //生成路线--正反方向(环线)
            func generateLineStations(reverse:Bool)->[DotInfo]{
                var result:[DotInfo] = []
                if reverse == true {
                    for (i,dot) in selectStations.enumerated(){
                        if self.isCircle == true{
                            //取头尾
                            if i <= startIndex {    //从0到小的点
                                result.append(dot);
                            }else if i >= endIndex{ //从大的点到结束
                                result.insert(dot, at: i-endIndex);//插到前面去
                            }
                        }else{
                            //在区间内
                            if i <= endIndex && i >= startIndex {
                                result.append(dot);
                            }
                        }
                    }
                    return result.reversed()//反转,最后从小的点往前推
                }else{
                    var result:[DotInfo] = []
                    for i in startIndex...endIndex{
                        let dot = selectStations[i];
                        result.append(dot);
                    }
                    return result;
                }
            }
            //环线的处理
            if self.isCircle == true{
                let result = generateLineStations(reverse: true);
                let normal = generateLineStations(reverse: false);
                //环线取距离最短的
                tmp = result.count < normal.count ? result : normal;
            }else{
                tmp = generateLineStations(reverse: reverse);
            }
        }
        return tmp;
    }

    
    //根据名字获取站点
    public func getStationForName(_ name:String)->DotInfo?{
        for station in self.stations + self.subLine1 + self.subLine2{
            if station.name == name{
                return station;
            }
        }
        return nil;
    }
    
    
    //是否与线路相交
    public func isInterSectionWithLine(_ line:Int)->Bool{
        for sta in self.stations + self.subLine1 + self.subLine2{
            if sta.changeLines.count > 0 && sta.changeLines.contains(line) {
                return true;
            }
        }
        return false;
    }
    
    
}



//站点信息
class DotInfo:NSObject{
    public var point:CGPoint!           //对应图例的位置
    public var name:String!             //站点的名称
    public var timeBase:Int = 0         //相对时间，起始点为0
    public var changeLines:[Int] = []   //可换乘的线路
}



//路径树
class SearchPath:NSObject{
    //variable
    public var rootName:String!                                     //根节点
    public private(set) var subPaths:[ChildStation] = []            //子节点数组
    public private(set) var cache:[(String,Int,String)] = []        //临时数组,commitPath清空并保存路径
    
    
    //子节点
    class ChildStation:NSObject{
        public var code:Int = 0                //当前所在点及其线路
        public var station:String!             //当前节点名称
        public var parent:String!              //父节点
        public var sub:[ChildStation] = []     //子节点数组
    }
    
    
    //添加子路径
    public func addSubPath(start:String,code:Int,end:String){
        //起始点名称
        if cache.count == 0 {
            rootName = start;
        }
        //添加路线缓存，如果出现起点和终点一致的路径无效
        if start != end {
            cache.append((start,code,end));
        }
    }
    
    
    //清空路径
    public func clear(){
        cache.removeAll();
    }
    
    
    //保存缓存的路线到树中
    public func commitPath()->PlanInfo{
        var tmp:ChildStation!
        for (index,it) in cache.enumerated(){
            if index == 0{
                let child = ChildStation()
                child.code = it.1;
                child.parent = rootName;
                child.station = it.2;
                tmp = child;
                subPaths.append(child);
            }else{
                let child = ChildStation()
                child.code = it.1;
                child.parent = tmp.station;
                child.station = it.2;
                tmp.sub.append(child);
                tmp = child;
            }
        }
        //清除缓存
        cache.removeAll();
        //生成路径
        let plan = PlanInfo()
        //刚生成的路径
        let lastPath = subPaths.last;
        plan.start = LineStaionV.shared.getlineForCode(lastPath!.code)?.getStationForName(rootName);
        //递归路径
        func generatePath(child:ChildStation){
            //父节点到这个点之间的路径
            let line:LineInfo = LineStaionV.shared.getlineForCode(child.code)!;
            let sum = PlanInfo.lineSum()
            sum.addSums(line.getStationsInLine(start: child.parent, end: child.station), lineCode:child.code);
            plan.addLineSum(sum: sum ,last: child.sub.count == 0);
            //下一个点
            let first:ChildStation? = child.sub.first;
            if first != nil {
                generatePath(child: first!);
            }else{
                plan.end = LineStaionV.shared.getlineForCode(child.code)?.getStationForName(child.station);
            }
        }
        //生成路径
        generatePath(child: lastPath!);
        return plan;
    }
    
    
}



//规划的路线信息
class PlanInfo:NSObject{
    public var start:DotInfo!                               //起点
    public var end:DotInfo!                                 //终点
    public private(set) var changes:[DotInfo] = []          //转乘点
    public private(set) var roads:[lineSum] = []            //每一段的路线信息
    public private(set) var allTime:Int = 0                 //总耗时
    public private(set) var stations:[String] = []          //所有站点的名字
    
    
    //添加分段路径信息
    public func addLineSum(sum:lineSum,last:Bool){
        //检测闭环
        func checkCloseInRoads()->(Int,String){
            for (j,it) in sum.points.enumerated(){
                if j > 0 {
                    for (i,road) in self.roads.enumerated(){
                        for po in road.points{
                            if po.name == it.name {
                                return(i,po.name);
                            }
                        }
                    }
                }
            }
            return (-1,"");
        }
        let check = checkCloseInRoads();
        let sameIndex = check.0;
        let sameName = check.1;
        //找到了重复的点
        if sameIndex >= 0 {
            var tmp:[lineSum] = [];
            //重复的之后不要，该下标的仍然保留
            for i in 0...sameIndex{
                tmp.append(self.roads[i]);
            }
            //最后一个进行重新编排
            let last = tmp[sameIndex];
            let line1 = LineStaionV.shared.getlineForCode(last.line);
            let cache1 = line1!.getStationsInLine(start: last.first.name, end: sameName);
            last.resetStations(cache1);
            //要加入的数据进行重组
            let line2 = LineStaionV.shared.getlineForCode(sum.line);
            let cache2:[DotInfo] = line2!.getStationsInLine(start: sameName, end: sum.last.name);
            sum.resetStations(cache2);
            //重新设置路径
            self.roads.removeAll();
            self.roads.append(contentsOf: tmp);
            self.roads.append(sum);
        }else{
            //没有形成闭环
            self.roads.append(sum);
        }
        //重置
        allTime = 0;
        self.changes.removeAll();
        self.stations.removeAll();
        //重新计算一遍
        for (i,road) in self.roads.enumerated(){
            allTime += road.time;
            for (j,po) in road.points.enumerated(){
                if i == 0 || ( i > 0 && j > 0){
                    stations.append(po.name);
                }
            }
            //中转站
            if road.last != nil && last == false {
                self.changes.append(road.last);
                allTime += road.last.changeLines.count > 2 ? 6 : 3;
            }
        }
    }
    
    
    //判断是否是相同的路线
    public func isSameLines(_ plan:PlanInfo)->Bool{
        var same = true;
        //站点不同,可能转乘点不同，时间不同，但是实际站点是一样的
        if self.stations.count != plan.stations.count{
            same = false;
        }else{
            if self.stations.count > 1 {
                for i in 0...self.stations.count-1{
                    let tmp1 = self.stations[i];
                    let tmp2 = plan.stations[i];
                    if tmp1 != tmp2{
                        same = false;
                        break;
                    }
                }
            }
        }
        return same;
    }
    
    
    //每一段的路线信息
    class lineSum:NSObject{
        public private(set) var line:Int = 0                         //线路
        public private(set) var time:Int = 0                         //时间间隔
        public private(set) var last:DotInfo!                        //最后的点
        public private(set) var first:DotInfo!                       //第一个的点
        public private(set) var points:[DotInfo] = []                //途径站点
        
        
        //重置
        public func resetStations(_ stations:[DotInfo]){
            self.points.removeAll();
            self.addSums(stations, lineCode: line);
        }
        
        
        //批量添加两点之间的点
        public func addSums(_ stations:[DotInfo],lineCode:Int){
            for i in 0...stations.count{
                if i <= stations.count - 2 { //最少有两个站
                    let dot1 = stations[i];
                    let dot2 = stations[i+1];
                    //最后的点
                    if i == stations.count - 2 {
                        last = dot2;
                    }
                    //起始点,不能else if,当只有两个点的时候
                    if i == 0 {
                        first = dot1;
                    }
                    //获取两点之间的时间间隔
                    var span = abs(dot1.timeBase - dot2.timeBase);
                    //环线的头尾相接，两点估计4分钟
                    if span > 10 {
                        span = 4;
                    }
                    time += span;
                }
            }
            if first != nil && last != nil{
                self.points.append(contentsOf: stations);
                line = lineCode;
            }
        }
    }
    
    
    
    
    

    
}
