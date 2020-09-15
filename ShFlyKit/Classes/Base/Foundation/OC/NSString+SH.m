//
//  NSString+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "NSString+SH.h"

@implementation NSString (SH)


///是否包含字符串
- (BOOL)containsString:(NSString *)str{
    return (str != nil) && ([str length] > 0) && ([self length] >= [str length]) && ([self rangeOfString:str options:NSCaseInsensitiveSearch].location != NSNotFound);
}


///是否纯数字
- (BOOL)isPureInt {
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


///通用模块
-(BOOL)predicateWithRegex:(NSString*)regex{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}


///是否是电子邮件
- (BOOL)isEmail {
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self predicateWithRegex:regex];
}


///是否是网址
- (BOOL)isUrl {
    NSString *regex = @"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    return [self predicateWithRegex:regex];
}


///是否是IP地址
- (BOOL)isIPAddress {
    NSArray *components = [self componentsSeparatedByString:@"."];
    NSCharacterSet *invalidCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
    if ( [components count] == 4 ){
        NSString *part1 = [components objectAtIndex:0];
        NSString *part2 = [components objectAtIndex:1];
        NSString *part3 = [components objectAtIndex:2];
        NSString *part4 = [components objectAtIndex:3];
        if ( [part1 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part2 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part3 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound &&
            [part4 rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound ){
            if ([part1 intValue] < 255 &&
                [part2 intValue] < 255 &&
                [part3 intValue] < 255 &&
                [part4 intValue] < 255 ){
                return YES;
            }
        }
    }
    return NO;
}


///是否是电话号码
- (BOOL)isTelephone {
    NSString *regex = @"^1(3[0-9]|4[0-9]|5[0-9]|7[0-9]|8[0-9]|9[0-9])\\d{8}$";
    return [self predicateWithRegex:regex];
}


///是否是手机号
- (BOOL)isPhoneNumber{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9]|70|77)\\d{8}$";
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    BOOL res1 = [regextestmobile evaluateWithObject:self];
    BOOL res2 = [regextestcm evaluateWithObject:self];
    BOOL res3 = [regextestcu evaluateWithObject:self];
    BOOL res4 = [regextestct evaluateWithObject:self];
    if (res1 || res2 || res3 || res4 ){
        return YES;
    }
    return NO;
}


///是否是合法的身份证号
- (BOOL)isIdentityCard {
    // 判断位数
    if ([self length] != 15 && [self length] != 18){
        return NO;
    }
    NSString *carid = self;
    long lSumQT  =0;
    // 加权因子
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    // 校验码
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    // 将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:self];
    if ([self length] == 15){
        [mString insertString:@"19" atIndex:6];
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        carid = mString;
    }
    // 判断地区码
    NSString * sProvince = [carid substringToIndex:2];
    if (![self areaCode:sProvince]){
        return NO;
    }
    // 判断年月日是否有效
    // 年份
    int strYear = [[carid substringWithRange:NSMakeRange(6,4)] intValue];
    // 月份
    int strMonth = [[carid substringWithRange:NSMakeRange(10,2)] intValue];
    // 日
    int strDay = [[carid substringWithRange:NSMakeRange(12,2)] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil){
        return NO;
    }
    const char *PaperId  = [carid UTF8String];
    // 检验长度
    if( 18 != strlen(PaperId)) return -1;
    // 校验数字
    for (int i=0; i<18; i++){
        if ( !isdigit(PaperId[i]) && !(('X' == PaperId[i] || 'x' == PaperId[i]) && 17 == i) )
        {
            return NO;
        }
    }
    // 验证最末的校验码
    for (int i=0; i<=16; i++){
        lSumQT += (PaperId[i]-48) * R[i];
    }
    if (sChecker[lSumQT%11] != PaperId[17] ){
        return NO;
    }
    return YES;
}


///PRIVATE
- (BOOL)areaCode:(NSString *)code {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"北京" forKey:@"11"];[dic setObject:@"天津" forKey:@"12"];[dic setObject:@"河北" forKey:@"13"];
    [dic setObject:@"山西" forKey:@"14"];[dic setObject:@"内蒙古" forKey:@"15"];[dic setObject:@"辽宁" forKey:@"21"];
    [dic setObject:@"吉林" forKey:@"22"];[dic setObject:@"黑龙江" forKey:@"23"];[dic setObject:@"上海" forKey:@"31"];
    [dic setObject:@"江苏" forKey:@"32"];[dic setObject:@"浙江" forKey:@"33"];[dic setObject:@"安徽" forKey:@"34"];
    [dic setObject:@"福建" forKey:@"35"];[dic setObject:@"江西" forKey:@"36"];[dic setObject:@"山东" forKey:@"37"];
    [dic setObject:@"河南" forKey:@"41"];[dic setObject:@"湖北" forKey:@"42"];[dic setObject:@"湖南" forKey:@"43"];
    [dic setObject:@"广东" forKey:@"44"];[dic setObject:@"广西" forKey:@"45"];[dic setObject:@"海南" forKey:@"46"];
    [dic setObject:@"重庆" forKey:@"50"];[dic setObject:@"四川" forKey:@"51"];[dic setObject:@"贵州" forKey:@"52"];
    [dic setObject:@"云南" forKey:@"53"];[dic setObject:@"西藏" forKey:@"54"];[dic setObject:@"陕西" forKey:@"61"];
    [dic setObject:@"甘肃" forKey:@"62"];[dic setObject:@"青海" forKey:@"63"];[dic setObject:@"宁夏" forKey:@"64"];
    [dic setObject:@"新疆" forKey:@"65"];[dic setObject:@"台湾" forKey:@"71"];[dic setObject:@"香港" forKey:@"81"];
    [dic setObject:@"澳门" forKey:@"82"];[dic setObject:@"国外" forKey:@"91"];
    if ([dic objectForKey:code] == nil) {
        return NO;
    }
    return YES;
}


//是否是正常字符
- (BOOL)isNormalText{
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    if (isMatch == NO) {//键盘为系统九宫格时有特殊字符
        NSString *other = @"➋➌➍➎➏➐➑➒";
        if ([other containString:self]) {
            isMatch = YES;
        }
    }
    return isMatch;
}


///模糊匹配字符串
- (BOOL)containString:(NSString *)subString{
    BOOL contain = YES;
    NSString* parentCopyString = [self copy];
    
    for (int i = 0; i < subString.length; i++){
        NSString* subOfSubString = [subString substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [parentCopyString rangeOfString:subOfSubString];
        if (range.location == NSNotFound){
            contain = NO;
        }else{
            parentCopyString = [parentCopyString stringByReplacingCharactersInRange:range withString:@""];
        }
    }
    return contain;
}


///是否包含Emoji表情
- (BOOL)containsEmoji{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                  }
                              } else if (substring.length > 1) {
                                  const unichar ls = [substring characterAtIndex:1];
                                  if (ls == 0x20e3) {
                                      returnValue = YES;
                                  }
                              } else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      returnValue = YES;
                                  } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      returnValue = YES;
                                  } else if (0x2934 <= hs && hs <= 0x2935) {
                                      returnValue = YES;
                                  } else if (0x3297 <= hs && hs <= 0x3299) {
                                      returnValue = YES;
                                  } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                      returnValue = YES;
                                  }
                              }
                          }];
    return returnValue;
}


///去除空格
- (NSString *)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


//去除emoji
- (NSString *)trimEmoji
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:self
                                                               options:0
                                                                 range:NSMakeRange(0, [self length])
                                                          withTemplate:@""];
    return modifiedString;
}


///将汉字转换成拼音
+ (NSString *)convertNameToCharactor:(NSString *)name{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:name];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return pinYin;
}


///将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSString *)jsonString{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}


//删除特殊字符
-(NSString*)deleteSpecialCharacters{
    NSString * rexgle = @"[`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:rexgle options:0 error:&error];
    
    NSTextCheckingResult *isMatch = [regex firstMatchInString:self
                                                      options:0
                                                        range:NSMakeRange(0, [self length])];
    if (isMatch) {
        return self;
    }else{
        return @"";
    }
}


///当前字符串逆序
- (NSString*)reverseString{
    NSUInteger  i = 0;
    NSUInteger j = self.length - 1;
    unichar *characters = malloc(sizeof([self characterAtIndex:0]) * self.length);
    while (i < j) {
        characters[j] = [self characterAtIndex:i];
        characters[i] = [self characterAtIndex:j];
        i ++;
        j --;
    }
    if(i == j)
        characters[i] = [self characterAtIndex:i];
    NSString *resultString = [NSString stringWithCharacters:characters length:self.length];
    free(characters);
    return resultString;
}


#pragma mark Size
///指定宽度计算高度
-(CGFloat)heightForWidth:(CGFloat)width font:(UIFont*)font{
    return [self sizeWithMaxSize:CGSizeMake(width, MAXFLOAT) andFont:font].height;
}

///文本的宽度
-(CGFloat)widthWithFont:(UIFont *)font{
    return [self sizeWithMaxSize:CGSizeMake(MAXFLOAT, MAXFLOAT) andFont:font].width;
}

///Private
- (CGSize)sizeWithMaxSize:(CGSize)maxSize andFont:(UIFont *)font{
    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : font}
                              context:nil].size;
}



#pragma mark - encode/decode
///URL编码
-(NSString *)stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}



///URL解码
- (NSString *)stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}


#pragma mark
///正则表达式匹配
- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}


///正则表达式匹配并替换
- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement; {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}



+(NSAttributedString *)attribute:(NSString *)text font:(UIFont *)font color:(UIColor *)color{
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:color}];
    return string;
}


- (NSString*)resourcePathWithBundleName:(NSString *)bundleName{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* mainPath = [mainBundle.bundlePath stringByAppendingFormat:@"/%@.bundle",bundleName];
    NSBundle* topBundle = [NSBundle bundleWithPath:mainPath];
    
    if (!topBundle){ // 兼容use_frameworks!
        topBundle = [NSBundle bundleWithPath:[mainBundle.bundlePath stringByAppendingFormat:@"/Frameworks/%@.framework/%@.bundle",bundleName,bundleName]];
    }
    
    NSString *path = [topBundle pathForResource:self ofType:nil];
    return path;
}
@end
