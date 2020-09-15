//
//  NSMutableDictionary+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSMutableDictionary+Crash.h"
#import "CrashHandler.h"


@implementation NSMutableDictionary (Crash)


+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dictionaryM = NSClassFromString(@"__NSDictionaryM");
        
        //setObject:forKey:
        [CrashHandler exchangeInstanceMethod:dictionaryM method1Sel:@selector(setObject:forKey:) method2Sel:@selector(avoidCrashSetObject:forKey:)];
        //setObject:forKeyedSubscript:
        if (UIDevice.currentDevice.systemVersion.floatValue >= 11.0) {
            [CrashHandler exchangeInstanceMethod:dictionaryM method1Sel:@selector(setObject:forKeyedSubscript:) method2Sel:@selector(avoidCrashSetObject:forKeyedSubscript:)];
        }
        //removeObjectForKey:
        [CrashHandler exchangeInstanceMethod:dictionaryM method1Sel:@selector(removeObjectForKey:) method2Sel:@selector(avoidCrashRemoveObjectForKey:)];
    });
}




#pragma mark - setObject:forKey:
- (void)avoidCrashSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    @try {
        [self avoidCrashSetObject:anObject forKey:aKey];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - setObject:forKeyedSubscript:
- (void)avoidCrashSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    @try {
        [self avoidCrashSetObject:obj forKeyedSubscript:key];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - removeObjectForKey:
- (void)avoidCrashRemoveObjectForKey:(id)aKey {
    @try {
        [self avoidCrashRemoveObjectForKey:aKey];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}

@end
