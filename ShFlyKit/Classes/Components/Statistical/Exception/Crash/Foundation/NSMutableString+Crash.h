//
//  NSMutableString+Crash.h
//  SHKit
//
//  Created by hsh on 2018/12/18.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrashProtocol.h"


@interface NSMutableString (Crash)<CrashProtocol>

@end


/**
 *  Can avoid crash method
 *
 *  1. 由于NSMutableString是继承于NSString,所以这里和NSString有些同样的方法就不重复写了
 *  2. - (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString
 *  3. - (void)insertString:(NSString *)aString atIndex:(NSUInteger)loc
 *  4. - (void)deleteCharactersInRange:(NSRange)range
 *
 */
