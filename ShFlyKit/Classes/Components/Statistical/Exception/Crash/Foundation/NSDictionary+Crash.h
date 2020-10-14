//
//  NSDictionary+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSDictionary (Crash)<CrashProtocol>

@end


/**
 *  Can avoid crash method
 *
 *  1. NSDictionary的快速创建方式 NSDictionary *dict = @{@"frameWork" : @"Crash"}; //这种创建方式其实调用的是2中的方法
 *  2. +(instancetype)dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
 *
 */
