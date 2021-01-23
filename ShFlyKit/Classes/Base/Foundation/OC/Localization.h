//
//  Localization.h
//  ShFlyKit
//
//  Created by mac on 2021/1/20.
//

#import <Foundation/Foundation.h>


///国际化
@interface Localization : NSObject


/// 当前系统语言 - 英文字符串
+ (NSString*)localLanguage;

/// 当前系统语言 - 中文字符串
+ (NSString*)hansLocalLanguage;

/// 当前系统语言 - 英文字符串
+ (NSString*)localLanguage;

/// 当前区域
+ (NSString*)localRegion;

/// 当前系统地区 - 中文字符串
+ (NSString*)hansLocalRegion;

/// 当地语言的code字典
+ (NSDictionary *)localesMap;

@end


