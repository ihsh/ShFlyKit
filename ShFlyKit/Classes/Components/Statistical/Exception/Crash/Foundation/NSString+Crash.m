//
//  NSString+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSString+Crash.h"
#import "CrashHandler.h"

@implementation NSString (Crash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class stringClass = NSClassFromString(@"__NSCFConstantString");
        
        //characterAtIndex
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(characterAtIndex:) method2Sel:@selector(avoidCrashCharacterAtIndex:)];
        //substringFromIndex
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(substringFromIndex:) method2Sel:@selector(avoidCrashSubstringFromIndex:)];
        //substringToIndex
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(substringToIndex:) method2Sel:@selector(avoidCrashSubstringToIndex:)];
        //substringWithRange:
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(substringWithRange:) method2Sel:@selector(avoidCrashSubstringWithRange:)];
        //stringByReplacingOccurrencesOfString:
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingOccurrencesOfString:withString:) method2Sel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:)];
        //stringByReplacingOccurrencesOfString:withString:options:range:
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:) method2Sel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:options:range:)];
        //stringByReplacingCharactersInRange:withString:
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingCharactersInRange:withString:) method2Sel:@selector(avoidCrashStringByReplacingCharactersInRange:withString:)];
    });
}




#pragma mark - characterAtIndex:
- (unichar)avoidCrashCharacterAtIndex:(NSUInteger)index {
    unichar characteristic;
    
    @try {
        characteristic = [self avoidCrashCharacterAtIndex:index];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        return characteristic;
    }
}


#pragma mark - substringFromIndex:
- (NSString *)avoidCrashSubstringFromIndex:(NSUInteger)from {
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringFromIndex:from];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        subString = nil;
    }@finally {
        return subString;
    }
}


#pragma mark - substringToIndex
- (NSString *)avoidCrashSubstringToIndex:(NSUInteger)to {
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringToIndex:to];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        subString = nil;
    }@finally {
        return subString;
    }
}


#pragma mark - substringWithRange:
- (NSString *)avoidCrashSubstringWithRange:(NSRange)range {
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringWithRange:range];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        subString = nil;
    }@finally {
        return subString;
    }
}



#pragma mark - stringByReplacingOccurrencesOfString:
- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        newStr = nil;
    }@finally {
        return newStr;
    }
}



#pragma mark - stringByReplacingOccurrencesOfString:withString:options:range:
- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement
                                                     options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        newStr = nil;
    }@finally {
        return newStr;
    }
}



#pragma mark - stringByReplacingCharactersInRange:withString:
- (NSString *)avoidCrashStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingCharactersInRange:range withString:replacement];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
        newStr = nil;
    }@finally {
        return newStr;
    }
}


@end
