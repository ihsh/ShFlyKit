//
//  CrashMethodSignatureProxy.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashMethodSignatureProxy : NSObject

-(void)proxyMethod;

- (instancetype)initWithSelector:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
