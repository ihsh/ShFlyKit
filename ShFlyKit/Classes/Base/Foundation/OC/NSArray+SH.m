//
//  NSArray+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSArray+SH.h"

@implementation NSArray (SH)


//该数组都是同样的字典，拼接成一个字符串
-(NSString*)dictArrayToStringForKey:(NSString*)keywords{
    NSMutableString *tmpstr = [[NSMutableString alloc]init];
    for (NSDictionary *dict in self) {
        NSString *words = [dict valueForKey:keywords];
        [tmpstr appendString:words];
    }
    return tmpstr;
}




@end
