//
//  NSArray+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SH)

//该数组都是同样的字典，拼接成一个字符串
-(NSString*)dictArrayToStringForKey:(NSString*)keywords;


@end

NS_ASSUME_NONNULL_END
