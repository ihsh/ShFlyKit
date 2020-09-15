//
//  NSMutableArray+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSMutableArray+Crash.h"
#import "CrashHandler.h"


@implementation NSMutableArray (Crash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class arrayMClass = NSClassFromString(@"__NSArrayM");
        
        //objectAtIndex:
        [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(objectAtIndex:) method2Sel:@selector(avoidCrashObjectAtIndex:)];
        //objectAtIndexedSubscript
        if (UIDevice.currentDevice.systemVersion.floatValue >= 11.0) {
            [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(objectAtIndexedSubscript:) method2Sel:@selector(avoidCrashObjectAtIndexedSubscript:)];
        }
        //setObject:atIndexedSubscript:
        [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(setObject:atIndexedSubscript:) method2Sel:@selector(avoidCrashSetObject:atIndexedSubscript:)];
        //removeObjectAtIndex:
        [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(removeObjectAtIndex:) method2Sel:@selector(avoidCrashRemoveObjectAtIndex:)];
        //insertObject:atIndex:
        [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(insertObject:atIndex:) method2Sel:@selector(avoidCrashInsertObject:atIndex:)];
        //getObjects:range:
        [CrashHandler exchangeInstanceMethod:arrayMClass method1Sel:@selector(getObjects:range:) method2Sel:@selector(avoidCrashGetObjects:range:)];
    });
}




#pragma mark - get object from array
- (void)avoidCrashSetObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    @try {
        [self avoidCrashSetObject:obj atIndexedSubscript:idx];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}




#pragma mark - removeObjectAtIndex:
- (void)avoidCrashRemoveObjectAtIndex:(NSUInteger)index {
    @try {
        [self avoidCrashRemoveObjectAtIndex:index];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}




#pragma mark - set方法
- (void)avoidCrashInsertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self avoidCrashInsertObject:anObject atIndex:index];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}




#pragma mark - objectAtIndex:
- (id)avoidCrashObjectAtIndex:(NSUInteger)index {
    id object = nil;
    
    @try {
        object = [self avoidCrashObjectAtIndex:index];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return object;
    }
}




#pragma mark - objectAtIndexedSubscript:
- (id)avoidCrashObjectAtIndexedSubscript:(NSUInteger)idx {
    id object = nil;
    
    @try {
        object = [self avoidCrashObjectAtIndexedSubscript:idx];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return object;
    }
}




#pragma mark - getObjects:range:
- (void)avoidCrashGetObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range {
    
    @try {
        [self avoidCrashGetObjects:objects range:range];
    } @catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    } @finally {
        
    }
}

@end
