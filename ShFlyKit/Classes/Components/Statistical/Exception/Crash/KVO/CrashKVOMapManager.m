//
//  CrashKVOMapManager.m
//  SHKit
//
//  Created by hsh on 2018/12/19.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "CrashKVOMapManager.h"


@interface CrashKVOMapManager()
@property (nonatomic, strong) NSMutableDictionary *kvoMap;      //kvo键值对
@property (nonatomic, strong) NSLock *kvoMapLock;               //操作锁
@end


@implementation CrashKVOMapManager


+(CrashKVOMapManager *)shared{
    static dispatch_once_t onceToken;
    static CrashKVOMapManager *shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CrashKVOMapManager alloc] init];
    });
    return shareInstance;
}



- (instancetype)init{
    if (self = [super init]) {
        _kvoMap = [NSMutableDictionary dictionary];
        _kvoMapLock = [[NSLock alloc] init];
    }
    return self;
}



- (BOOL)isMapObserver:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path{
    //被观察的类名+观察者
    NSString *key = [NSString stringWithFormat:@"%@_%p",NSStringFromClass([observer class]),observer];
    //上锁
    [self.kvoMapLock lock];
    //获取对应key的对象，是一个数组
    id obj = [self.kvoMap objectForKey:key];
    if ([obj isKindOfClass:[NSMutableArray class]]) {
        //遍历CrashKVOResource数组
        for (id source in obj) {
            if ([source isKindOfClass:[CrashKVOResource class]]) {
                //如果观察者和键值是一样的就返回YES,表明添加过
                if ([(CrashKVOResource*)source resource] == keySource && [(CrashKVOResource*)source key] == path) {
                    [self.kvoMapLock unlock];
                    return YES;
                }
            }
        }
    }
    //解锁
    [self.kvoMapLock unlock];
    return NO;
}



//移除
- (BOOL)observerRemove:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path{
    NSString *key = [NSString stringWithFormat:@"%@_%p",NSStringFromClass([observer class]),observer];
    [self.kvoMapLock lock];
    id obj = [self.kvoMap objectForKey:key];
    if ([obj isKindOfClass:[NSMutableArray class]]) {
        for (id source in obj) {
            if ([source isKindOfClass:[CrashKVOResource class]]) {
                if ([(CrashKVOResource*)source resource] == keySource && [(CrashKVOResource*)source key] == path) {
                    [obj removeObject:source];
                    [self.kvoMapLock unlock];
                    return YES;
                }
            }
        }
    }
    [self.kvoMapLock unlock];
    return NO;
}



//移除改被观察者的所有的观察者
- (void)removeAllObserver:(id)source{
    [self.kvoMapLock lock];
    [self.kvoMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *obj, BOOL * _Nonnull stop) {
        for (id resource in obj) {
            if ([resource isKindOfClass:[CrashKVOResource class]]) {
                if ([(CrashKVOResource*)resource observer] == source || [(CrashKVOResource*)resource observer] == NULL) {
                    
                    [[(CrashKVOResource*)resource resource] removeObserver:source forKeyPath:[(CrashKVOResource*)resource key]];
                    *stop = YES;
                }
            }
        }
    }];
    [self.kvoMapLock unlock];
}



- (BOOL)observeValueForKeyPath:(id)observer inkeySource:(id)keySource keyPath:(NSString*)path{
    NSString *key = [NSString stringWithFormat:@"%@_%p",NSStringFromClass([observer class]),observer];
    [self.kvoMapLock lock];
    id obj = [self.kvoMap objectForKey:key];
    if ([obj isKindOfClass:[NSMutableArray class]]) {
        for (id source in obj) {
            if ([source isKindOfClass:[CrashKVOResource class]]) {
                if ([(CrashKVOResource*)source resource] == nil && [(CrashKVOResource*)source key] == path) {
                    [obj removeObject:source];
                    [self.kvoMapLock unlock];
                    return YES;
                }
            }
        }
    }
    [self.kvoMapLock unlock];
    return NO;
}



- (void)addObserver:(id)observer source:(CrashKVOResource *)source{
    if (nil == observer || nil == source) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"%@_%p",NSStringFromClass([observer class]),observer];
    [self.kvoMapLock lock];
    //存在对应键值，设置对应为新值
    if ([self.kvoMap objectForKey:key]) {
        id obj = [self.kvoMap objectForKey:key];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:obj];
            if (![array containsObject:source]) {
                [array addObject:source];
                [self.kvoMap setObject:array forKey:key];
            }
        }
    }else{
        //不存在新建
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:source];
        [self.kvoMap setObject:array forKey:key];
    }
    [self.kvoMapLock unlock];
}


@end





@implementation CrashKVOResource

-(id)initWithResource:(id)resource observer:(id)observer key:(NSString *)key{
    self = [super init];
    if (self) {
        self.resource = resource;
        self.observer = observer;
        self.key = key;
    }
    return self;
}

@end
