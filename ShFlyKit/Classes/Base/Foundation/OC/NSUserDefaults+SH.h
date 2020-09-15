//
//  NSUserDefaults+SH.h
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSUserDefaults (SH)

+(NSArray*)arrayForKeys;

//get
+(NSInteger)interForKey:(NSString*)key;
+(BOOL)boolForKey:(NSString*)key default:(BOOL)value;
+(NSString*)stringForKey:(NSString*)key;

//set
+(void)setInteger:(NSInteger)interger key:(NSString*)key;
+(void)setBool:(BOOL)bol key:(NSString*)key;
+(void)setString:(NSString*)str key:(NSString*)key;

//waring
+(void)clearAllPersistent;
@end

NS_ASSUME_NONNULL_END
