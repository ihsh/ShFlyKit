//
//  CrashMethodSignatureProxy.m
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "CrashMethodSignatureProxy.h"
#import <objc/runtime.h>

//定义的空方法
id dynamicIMP(id sender,SEL sel,...){
    return nil;
}



@implementation CrashMethodSignatureProxy


- (void)proxyMethod {
    NSLog(@"运行空方法");
}


- (instancetype)initWithSelector:(SEL)aSelector{
    if (self = [super init]) {
        if(class_addMethod([self class], aSelector, (IMP)dynamicIMP, NULL)) {
        }
    }
    return self;
}

@end
