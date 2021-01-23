//
//  Localization.m
//  ShFlyKit
//
//  Created by mac on 2021/1/20.
//

#import "Localization.h"

@implementation Localization


///当地语言
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


///当地语言的汉字
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


///当前区域
+ (NSString*)localRegion
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}


///当前区域的中文名
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


///语言的英文code列表
+ (NSDictionary *)localesMap {
    return @{
        @"en": @[@"en_AU",@"en_CA",@"en_IN",@"en_IE",
                @"en_MT",@"en_NZ",@"en_PH",@"en_SG",
                @"en_ZA",@"en_GB",@"en_US",@"en_AE",
                @"en-AE",@"en_AS",@"en-AU",@"en_BD",
                @"en-CA",@"en_EG",@"en_ES",@"en_GB",
                @"en-GB",@"en_HK",@"en_ID",@"en-IN",
                @"en_NG",@"en-PH",@"en_PK",@"en-SG",@"en-US"],
        // Simplified Chinese
        @"zh_Hans": @[@"zh_CN", @"zh_SG", @"zh-Hans"],
        // Traditional Chinese
        @"zh_Hant": @[@"zh_HK", @"zh_TW", @"zh-Hant", @"zh-HK", @"zh-TW"]
    };
}


@end
