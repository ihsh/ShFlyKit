//
//  NSArray+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSArray (Crash)<CrashProtocol>

@end

/**
 *  Can avoid crash method
 *
 *  1. NSArray的快速创建方式 NSArray *array = @[@"", @""];  //这种创建方式其实调用的是2中的方法
 *  2. +(instancetype)arrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt
 *  3. - (id)objectAtIndex:(NSUInteger)index
 *  4. - (void)getObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range
 */
