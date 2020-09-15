//
//  CrashKVOMapManager.h
//  SHKit
//
//  Created by hsh on 2018/12/19.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>




@class CrashKVOResource;

@interface CrashKVOMapManager : NSObject

+(CrashKVOMapManager *)shared;
//判断是否已存在
- (BOOL)isMapObserver:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path;
//移除
- (BOOL)observerRemove:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path;
//添加
- (void)addObserver:(id)observer source:(CrashKVOResource *)source;
//获取
- (BOOL)observeValueForKeyPath:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path;
//移除全部
- (void)removeAllObserver:(id)source;

@end








//数据模型
@interface CrashKVOResource:NSObject
@property(nonatomic,strong)id resource;
@property(nonatomic,strong)NSString *key;
@property(nonatomic,weak)id observer;

-(id)initWithResource:(id)resource observer:(id)observer key:(NSString*)key;

@end

