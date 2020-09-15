//
//  WeakProxy.h
//  HLLDriver-LTLOrder
//
//  Created by 黄少辉 on 2020/9/1.
//

#import <Foundation/Foundation.h>


@interface WeakProxy : NSProxy
@property (nonatomic, weak, readonly) id weakTarget;

+ (instancetype)proxyWithTarget:(id)target;
- (instancetype)initWithTarget:(id)target;
@end


