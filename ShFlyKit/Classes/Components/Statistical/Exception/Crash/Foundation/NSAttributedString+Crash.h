//
//  NSAttributedString+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSAttributedString (Crash)<CrashProtocol>

@end

/**
 *  Can avoid crash method
 *
 *  1.- (instancetype)initWithString:(NSString *)str
 *  2.- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr
 *  3.- (instancetype)initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs
 *
 */
