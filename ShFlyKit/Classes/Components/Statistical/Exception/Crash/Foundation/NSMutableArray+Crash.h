//
//  NSMutableArray+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSMutableArray (Crash)<CrashProtocol>

@end


/**
 *  Can avoid crash method
 *
 *  1. - (id)objectAtIndex:(NSUInteger)index
 *  2. - (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
 *  3. - (void)removeObjectAtIndex:(NSUInteger)index
 *  4. - (void)insertObject:(id)anObject atIndex:(NSUInteger)index
 *  5. - (void)getObjects:(__unsafe_unretained id  _Nonnull *)objects range:(NSRange)range
 */
