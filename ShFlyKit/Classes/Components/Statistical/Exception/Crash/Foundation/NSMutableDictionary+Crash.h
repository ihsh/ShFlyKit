//
//  NSMutableDictionary+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSMutableDictionary (Crash)<CrashProtocol>

@end


/**
 *  Can avoid crash method
 *
 *  1. - (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
 *  2. - (void)removeObjectForKey:(id)aKey
 *
 */

