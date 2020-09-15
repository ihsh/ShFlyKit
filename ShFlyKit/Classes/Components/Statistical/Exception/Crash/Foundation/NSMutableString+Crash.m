//
//  NSMutableString+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSMutableString+Crash.h"
#import "CrashHandler.h"

@implementation NSMutableString (Crash)

+(void)avoidCrashExchangeMethod{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class stringClass = NSClassFromString(@"__NSCFString");
        
        //replaceCharactersInRange
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(replaceCharactersInRange:withString:) method2Sel:@selector(avoidCrashReplaceCharactersInRange:withString:)];
        //insertString:atIndex:
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(insertString:atIndex:) method2Sel:@selector(avoidCrashInsertString:atIndex:)];
        //deleteCharactersInRange
        [CrashHandler exchangeInstanceMethod:stringClass method1Sel:@selector(deleteCharactersInRange:) method2Sel:@selector(avoidCrashDeleteCharactersInRange:)];
    });
}




#pragma mark - replaceCharactersInRange
- (void)avoidCrashReplaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    
    @try {
        [self avoidCrashReplaceCharactersInRange:range withString:aString];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - insertString:atIndex:
- (void)avoidCrashInsertString:(NSString *)aString atIndex:(NSUInteger)loc {
    
    @try {
        [self avoidCrashInsertString:aString atIndex:loc];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



#pragma mark - deleteCharactersInRange
- (void)avoidCrashDeleteCharactersInRange:(NSRange)range {
    
    @try {
        [self avoidCrashDeleteCharactersInRange:range];
    }@catch (NSException *exception) {
        [CrashHandler noteErrorWithException:exception];
    }@finally {
        
    }
}



@end
