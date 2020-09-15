//
//  UIView+Crash.m
//  SHKit
//
//  Created by hsh on 2018/12/19.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIView+Crash.h"
#import "CrashHandler.h"


@implementation UIView (Crash)

+(void)avoidCrashExchangeMethod{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setNeedsLayout) method2Sel:@selector(swizzleSetNeedsLayout)];
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(layoutIfNeeded) method2Sel:@selector(swizzleLayoutIfNeeded)];
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(layoutSubviews) method2Sel:@selector(swizzleLayoutSubviews)];
        [CrashHandler exchangeInstanceMethod:[self class] method1Sel:@selector(setNeedsUpdateConstraints) method2Sel:@selector(swizzelSetNeedsUpdateConstraints)];
    });
}



- (void)swizzleSetNeedsLayout{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        [self swizzleSetNeedsLayout];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzleSetNeedsLayout];
        });
    }
}



- (void)swizzleLayoutIfNeeded{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        [self swizzleLayoutIfNeeded];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzleLayoutIfNeeded];
        });
    }
}




- (void)swizzleLayoutSubviews{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        [self swizzleLayoutSubviews];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzleLayoutSubviews];
        });
    }
}




- (void)swizzelSetNeedsUpdateConstraints{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        [self swizzelSetNeedsUpdateConstraints];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self swizzelSetNeedsUpdateConstraints];
        });
    }
}


@end
