//
//  SearchCore.swift
//  SHKit
//
//  Created by hsh on 2019/9/27.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


///简单搜索查找
public class SearchCore:NSObject{
    //Variable
    private var matchs:[String] = []            //匹配用字符串
    private var indexes:[Int] = []              //下标记录
    private var source:[AnyObject] = []         //源数据
    
    
    //重置
    public func reset(){
        matchs.removeAll();
        indexes.removeAll();
        source.removeAll();
    }
    
    
    //添加索引
    public func addMatch(_ match:String,index:Int){
        matchs.append(match);
        indexes.append(index);
    }
    
    
    //设置数据源
    public func setSource(_ source:[AnyObject]){
        self.source = source;
    }
    
    
    //搜索
    public func searchFor(_ text:String)->[AnyObject]{
        var result:[AnyObject] = [];
        if source.count > 0 {
            for (i,it) in matchs.enumerated() {
                //匹配
                if it.contains(text) {
                    //对应下标
                    let index = indexes[i];
                    let obj = index < source.count ? source[index] : nil;
                    if obj != nil {
                        result.append(obj!);
                    }
                }
            }
        }
        return result;
    }
    
    
}

