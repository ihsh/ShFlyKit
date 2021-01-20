//
//  Localization.m
//  ShFlyKit
//
//  Created by mac on 2021/1/20.
//

#import "Localization.h"

@implementation Localization


+ (NSString *)localLanguage
{
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
    // 去除区域 code
    NSMutableArray *components = [preferredLanguage componentsSeparatedByString:@"-"].mutableCopy;
    if ([components count] >= 2) {
        [components removeLastObject];
        preferredLanguage = [components componentsJoinedByString:@"-"];
    }
    return preferredLanguage;
}


+ (NSString*)localRegion
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}


+ (NSString *)hansLocalLanguage
{
    NSDictionary* languageDic = @{@"zh-Hans-CN":@"简体中文",
                                  @"zh-Hans-HK":@"简体中文",
                                  @"zh-Hans-TW":@"简体中文",
                                  @"zh-Hans-MO":@"简体中文",
                                  @"zh-CN":@"简体中文",
                                  @"zh-HK":@"繁体中文",
                                  @"zh-MO":@"繁体中文",
                                  @"zh-TW":@"繁体中文",
                                  @"en-CN":@"English",
                                  @"en-HK":@"English",
                                  @"en-TW":@"English",
                                  @"en-MO":@"English",
                                  @"en-US":@"English",
                                  @"en-GB":@"English",
                                  @"en-CA":@"English",
                                  @"en-AU":@"English",
                                  @"en-IN":@"English",
                                  @"ko-HK":@"韩语",
                                  @"ja-JP":@"日本语"};
    NSString* enLanguage = [self localLanguage];
    NSString* hansLanguage = languageDic[enLanguage];
    return hansLanguage ? hansLanguage : enLanguage;
}


+ (NSString*)hansLocalRegion
{
    NSDictionary* regionDic = @{@"CN":@"中国",
                                @"HK":@"香港",
                                @"TW":@"台湾",
                                @"MO":@"澳门",
                                @"US":@"U.S.",
                                @"GB":@"U.K.",
                                @"CA":@"Cannada",
                                @"AU":@"Australia",
                                @"IN":@"India",
                                @"KO":@"韩国",
                                @"JP":@"日本"};
    NSString* enRegion = [self localRegion];
    NSString* hansRegion = regionDic[enRegion];
    return hansRegion ? hansRegion : enRegion;
}


@end
