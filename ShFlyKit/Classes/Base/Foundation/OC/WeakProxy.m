//
//  WeakProxy.m
//
//  Created by 黄少辉 on 2020/9/1.
//

#import "WeakProxy.h"

@implementation WeakProxy

+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target {
    _weakTarget = target;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if ([self.weakTarget respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.weakTarget];
    }
}

//返回方法的签名。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.weakTarget methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.weakTarget respondsToSelector:aSelector];
}


- (BOOL)isEqual:(id)object {
    return [_weakTarget isEqual:object];
}

- (NSUInteger)hash {
    return [_weakTarget hash];
}

- (Class)superclass {
    return [_weakTarget superclass];
}

- (Class)class {
    return [_weakTarget class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_weakTarget isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_weakTarget isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_weakTarget conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_weakTarget description];
}

- (NSString *)debugDescription {
    return [_weakTarget debugDescription];
}

@end
