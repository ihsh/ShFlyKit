//
//  NSObject+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSObject+Crash.h"
#import "CrashHandler.h"
#import "CrashMethodSignatureProxy.h"
#import "CrashKVOMapManager.h"


@implementation NSObject (Crash)


+(void)avoidCrashExchangeMethod{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //setValue:forKey:
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forKey:) method2Sel:@selector(avoidCrashSetValue:forKey:)];
        //setValue:forKeyPath:
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forKeyPath:) method2Sel:@selector(avoidCrashSetValue:forKeyPath:)];
        //setValue:forUndefinedKey:
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setValue:forUndefinedKey:) method2Sel:@selector(avoidCrashSetValue:forUndefinedKey:)];
        //setValuesForKeysWithDictionary:
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setValuesForKeysWithDictionary:) method2Sel:@selector(avoidCrashSetValuesForKeysWithDictionary:)];
        
        //unrecognized selector sent to instance
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(methodSignatureForSelector:) method2Sel:@selector(avoidCrashMethodSignatureForSelector:)];
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(forwardInvocation:) method2Sel:@selector(avoidCrashForwardInvocation:)];
        
    });
}



//添加观察者的通知
+(void)avoidCrashKVO{
    [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(addObserver:forKeyPath:options:context:) method2Sel:@selector(swizzleAddObserver:keyPath:options:context:)];
    [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(removeObserver:forKeyPath:) method2Sel:@selector(swizzleRemoveObserver:forKeyPath:)];
    [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(observeValueForKeyPath:ofObject:change:context:) method2Sel:@selector(swizzleObserveValueForKeyPath:ofObject:change:context:)];
    [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(removeObserver:forKeyPath:context:) method2Sel:@selector(swizzleRemoveObserver:forKeyPath:context:)];
}

//====================================================================================================================

//一个函数由一个SEL和IML组成，相当于门牌号和住户，门牌号可以随便发，却不一定有住户
//判断对象中有对应的IML(有-执行结束)---->没有-执行对象中的resolveInstanceMethod函数返回BOOL(有-执行结束)----->没有-执行forwardingTargetForSelector函数返回id(返回一个id对象，开始对sel的执行)
//上一步没有---->执行对象中的methodSignaltureForSelector函数返回NSMethodSignature(返回无效执行-doesNotRecognizeSelector抛出异常)----->有效-执行对象中的forwardInvocation函数
//不用forwardingTargetForSelector，因为正常的方法也都会调用它

#pragma mark 消息转发后两步
- (NSMethodSignature *)avoidCrashMethodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *ms = [CrashMethodSignatureProxy instanceMethodSignatureForSelector:@selector(proxyMethod)];
    return ms;
}



- (void)avoidCrashForwardInvocation:(NSInvocation *)anInvocation {
    @try {
        [self avoidCrashForwardInvocation:anInvocation];
    } @catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    } @finally {
        
    }
}



//=====================================================================================================

#pragma mark - setValue:forKey:
- (void)avoidCrashSetValue:(id)value forKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forKey:key];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - setValue:forKeyPath:
- (void)avoidCrashSetValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self avoidCrashSetValue:value forKeyPath:keyPath];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - setValue:forUndefinedKey:
- (void)avoidCrashSetValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self avoidCrashSetValue:value forUndefinedKey:key];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - setValuesForKeysWithDictionary:
- (void)avoidCrashSetValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    @try {
        [self avoidCrashSetValuesForKeysWithDictionary:keyedValues];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}

//====================================================================================================
-(void)swizzleAddObserver:(NSObject*)observer keyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context{
    if ([[CrashKVOMapManager shared]isMapObserver:observer inkeySource:self keyPath:keyPath] == NO) {
        CrashKVOResource *resource = [[CrashKVOResource alloc]initWithResource:self observer:observer key:keyPath];
        [[CrashKVOMapManager shared]addObserver:observer source:resource];
        [self swizzleAddObserver:observer keyPath:keyPath options:options context:context];
    }
}



- (void)swizzleRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if ([[CrashKVOMapManager shared] observerRemove:observer inkeySource:self keyPath:keyPath]) {
        [self swizzleRemoveObserver:observer forKeyPath:keyPath];
    }
}



- (void)swizzleRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    if ([[CrashKVOMapManager shared] observerRemove:observer inkeySource:self keyPath:keyPath]) {
        [self swizzleRemoveObserver:observer forKeyPath:keyPath context:context];
    }
}



//某个属性改变调用时如果不存在就移除观察者
- (void)swizzleObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                              context:(void *)context{
    if ([[CrashKVOMapManager shared] observeValueForKeyPath:object inkeySource:self keyPath:keyPath] == NO) {
        [self swizzleObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
