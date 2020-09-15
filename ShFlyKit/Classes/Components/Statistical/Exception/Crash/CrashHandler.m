//
//  CrashHandler.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "CrashHandler.h"
#import <UIKit/UIKit.h>

static NSString *const key_errorName = @"errorName";
static NSString *const key_errorReason = @"errorReason";
static NSString *const key_callStackSymbols = @"callStackSymbols";
static NSString *const key_exception = @"exception";


@implementation CrashHandler


+(void)makeEffective{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //NSObject - unrecognized selector sendto instance等
        [NSObject avoidCrashExchangeMethod];
        //Foundation框架
        [NSArray avoidCrashExchangeMethod];
        [NSMutableArray avoidCrashExchangeMethod];
        [NSDictionary avoidCrashExchangeMethod];
        [NSMutableDictionary avoidCrashExchangeMethod];
        [NSString avoidCrashExchangeMethod];
        [NSMutableString avoidCrashExchangeMethod];
        [NSAttributedString avoidCrashExchangeMethod];
        [NSMutableAttributedString avoidCrashExchangeMethod];
        
        //UI 非主线程的崩溃
        [UIView avoidCrashExchangeMethod];
        //KVO
        [NSObject avoidCrashKVO];
    });
}





/**
 *  类方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1
 *  @param method2Sel 方法2
 */
+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    Method method1 = class_getClassMethod(anClass, method1Sel);
    Method method2 = class_getClassMethod(anClass, method2Sel);
    method_exchangeImplementations(method1, method2);
}



/**
 *  对象方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1(原本的方法)
 *  @param method2Sel 方法2(要替换成的方法)
 */
+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {

    Method originalMethod = class_getInstanceMethod(anClass, method1Sel);
    Method swizzledMethod = class_getInstanceMethod(anClass, method2Sel);
    
    BOOL didAddMethod = class_addMethod(anClass,method1Sel,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(anClass,method2Sel,method_getImplementation(originalMethod),method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



/**
 *  提示崩溃的信息(控制台输出、通知)
 *
 *  @param exception   捕获到的异常
 */
+ (void)noteErrorWithException:(NSException *)exception {
    
    //堆栈数据
    NSArray *callStackSymbols = [NSThread callStackSymbols];
    
    //异常信息
    NSString *errorName = exception.name;
    NSString *errorReason = exception.reason;
    
    NSDictionary *errorInfoDic = @{key_errorName        : errorName ? errorName : @"",
                                   key_errorReason      : errorReason ? errorReason : @"",
                                   key_exception        : exception,
                                   key_callStackSymbols : callStackSymbols
                                   };
    NSException *reportException = [[NSException alloc]initWithName:exception.name reason:exception.reason userInfo:errorInfoDic];
    [Bugly reportException:reportException];
    NSLog(@"%@",errorInfoDic);
}


@end
