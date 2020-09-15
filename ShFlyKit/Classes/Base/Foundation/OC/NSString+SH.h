//
//  NSString+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SH)


///指定宽度计算高度
-(CGFloat)heightForWidth:(CGFloat)width font:(UIFont*)font;
///文本的宽度
-(CGFloat)widthWithFont:(UIFont *)font;


///包含给定的字符串, 忽略大小写
- (BOOL)containsString:(NSString *)str;
/// 是否纯数字
- (BOOL)isPureInt;
//通用正则执行
-(BOOL)predicateWithRegex:(NSString*)regex;
///正则判断
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options;
///是否电话号码
- (BOOL)isTelephone;
///是否是手机号
- (BOOL)isPhoneNumber;
/// 是否email
- (BOOL)isEmail;
/// 是否url
- (BOOL)isUrl;
/// 是否IP地址
- (BOOL)isIPAddress;
/// 是否合法身份证号
- (BOOL)isIdentityCard;
/// 中文、英文、数字
- (BOOL)isNormalText;
/// 模糊匹配字符串
- (BOOL)containString:(NSString *)subString;
/// 检查是否输入表情
- (BOOL)containsEmoji;



/// 当前字符串的倒序字符串
- (NSString*)reverseString;
/// 匹配删除特殊字符
- (NSString*)deleteSpecialCharacters;
/// 将Emoji表情置空
- (NSString *)trimEmoji;
///去除字符串前后的空白,不包含换行符
- (NSString *)trim;
///字符串转字母
+ (NSString *)convertNameToCharactor:(NSString *)name;
///字符串转数组或字典
+ (id)toArrayOrNSDictionary:(NSString *)jsonString;
///正则表达式替换
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;
//创建一个属性字符串
+ (NSAttributedString *)attribute:(NSString *)text font:(UIFont *)font color:(UIColor *)color;


/**
 资源文件的路径
 
 @param bundleName bundle名
 @return 路径
 */
- (NSString*)resourcePathWithBundleName:(NSString*)bundleName;


@end

NS_ASSUME_NONNULL_END
