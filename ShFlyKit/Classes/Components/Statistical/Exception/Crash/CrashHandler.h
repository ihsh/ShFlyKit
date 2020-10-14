//
//  CrashHandler.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//


///宏定义区
#define CrashNotification @"CrashNotification"


#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//catrgory
#import "NSObject+Crash.h"
#import "NSString+Crash.h"
#import "NSArray+Crash.h"
#import "NSDictionary+Crash.h"
#import "NSAttributedString+Crash.h"
#import "NSMutableAttributedString+Crash.h"
#import "NSMutableString+Crash.h"
#import "NSMutableDictionary+Crash.h"
#import "NSMutableArray+Crash.h"


#import <Bugly/Bugly.h>


@interface CrashHandler : NSObject

+(void)makeEffective;


//内部使用方法
+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;
+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;
+ (void)noteErrorWithException:(NSException *)exception;
@end


