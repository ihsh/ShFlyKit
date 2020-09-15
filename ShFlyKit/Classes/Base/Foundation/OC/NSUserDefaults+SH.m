//
//  NSUserDefaults+SH.m
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSUserDefaults+SH.h"

@implementation NSUserDefaults (SH)


+(NSArray *)arrayForKeys{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *sandBoxDict = [userDefault dictionaryRepresentation];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in sandBoxDict) {
        [array addObject:[NSString stringWithFormat:@"%@---%@",key,[userDefault valueForKey:key]]];
    }
    return array;
}


//Private - 是否存在该key的设置
+(BOOL)containsKey:(NSString*)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *sandBoxDict = [userDefault dictionaryRepresentation];
    BOOL contains = NO;
    for (NSString *sandKey in sandBoxDict) {
        if ([sandKey isEqualToString:key]) {
            contains = YES;
        }
    }
    return contains;
}


//get
+(NSInteger)interForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]integerForKey:key];
}


+(BOOL)boolForKey:(NSString *)key default:(BOOL)value{
    if ([NSUserDefaults containsKey:key]) {
        return [[NSUserDefaults standardUserDefaults]boolForKey:key];
    }else{
        return value;
    }
}


+(NSString *)stringForKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults]stringForKey:key];
}







//set
+(void)setInteger:(NSInteger)interger key:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setInteger:interger forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


+(void)setBool:(BOOL)bol key:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setBool:bol forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


+(void)setString:(NSString *)str key:(NSString *)key{
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//warning
+(void)clearAllPersistent{
    NSString *appDomin = [[NSBundle mainBundle]bundleIdentifier];
    [[NSUserDefaults standardUserDefaults]removePersistentDomainForName:appDomin];
}

@end
