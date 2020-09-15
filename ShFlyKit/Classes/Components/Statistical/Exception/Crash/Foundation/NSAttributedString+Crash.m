//
//  NSAttributedString+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSAttributedString+Crash.h"
#import "CrashHandler.h"

@implementation NSAttributedString (Crash)


+(void)avoidCrashExchangeMethod{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class NSConcreteAttributedString = NSClassFromString(@"NSConcreteAttributedString");
        
        //initWithString:
        [CrashHandler exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithString:) method2Sel:@selector(avoidCrashInitWithString:)];
        //initWithAttributedString
        [CrashHandler exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithAttributedString:) method2Sel:@selector(avoidCrashInitWithAttributedString:)];
        //initWithString:attributes:
        [CrashHandler exchangeInstanceMethod:NSConcreteAttributedString method1Sel:@selector(initWithString:attributes:) method2Sel:@selector(avoidCrashInitWithString:attributes:)];
    });
}





#pragma mark - initWithString:
- (instancetype)avoidCrashInitWithString:(NSString *)str {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return object;
    }
}



#pragma mark - initWithAttributedString
- (instancetype)avoidCrashInitWithAttributedString:(NSAttributedString *)attrStr {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithAttributedString:attrStr];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return object;
    }
}


#pragma mark - initWithString:attributes:
- (instancetype)avoidCrashInitWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    id object = nil;
    
    @try {
        object = [self avoidCrashInitWithString:str attributes:attrs];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return object;
    }
}

@end
