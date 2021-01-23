//
//  UITextField+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UITextField+SH.h"
#import <objc/runtime.h>
#import "Localization.h"

static NSString *kLimitTextFieldLengthKey = @"kLimitTextFieldLengthKey";

@implementation UITextField (SH)


+(instancetype)initPlaceHolder:(NSString *)placeHolder superView:(UIView *)superView{
    UITextField *textField = [[UITextField alloc]init];
    textField.placeholder = placeHolder;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.minimumFontSize = 12;
    if (superView) {
        [superView addSubview:textField];
    }
    return textField;
}


- (void)limitTextLength:(int)length
{
    //设置关联引用
    objc_setAssociatedObject(self, (__bridge const void *)(kLimitTextFieldLengthKey), [NSNumber numberWithInt:length], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //注册监听器
    [self addTarget:self action:@selector(textFieldTextLengthLimit:) forControlEvents:UIControlEventEditingChanged];
}


- (void)textFieldTextLengthLimit:(id)sender
{
    //获取关联应用的值
    NSNumber *lengthNumber = objc_getAssociatedObject(self, (__bridge const void *)(kLimitTextFieldLengthKey));
    
    int length = [lengthNumber intValue];
    //下面是修改部分
    bool isChinese;//判断当前输入法是否是中文
    NSArray *localesSimplifiedCn = ([[Localization localesMap] objectForKey: @"zh_Hans"]);
    NSArray *localesTraditionalCn = ([[Localization localesMap] objectForKey: @"zh_Hant"]);

    if ([localesSimplifiedCn containsObject: self.textInputMode.primaryLanguage] ||
        [localesTraditionalCn containsObject: self.textInputMode.primaryLanguage]) {
        isChinese = true;
    } else {
        isChinese = false;
    }
    if(sender == self) {
        // length是自己设置的位数
        NSString *str = [self text];
        if (isChinese) { //中文输入法下
            UITextRange *selectedRange = [self markedTextRange];
            //获取高亮部分
            UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position) {
                if ( str.length>=length) {
                    NSString *strNew = [NSString stringWithString:str];
                    [self setText:[strNew substringToIndex:length]];
                }
                //禁止表情
                [self banEmoji];
            }
        }else{
            if ([str length]>=length) {
                NSString *strNew = [NSString stringWithString:str];
                [self setText:[strNew substringToIndex:length]];
            }
            //禁止表情
            [self banEmoji];
        }
    }
}


///禁止输入emoji
- (void)banEmoji
{
    [self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *newSubString = [regex stringByReplacingMatchesInString:substring
                                                                   options:0
                                                                     range:NSMakeRange(0, [substring length])
                                                              withTemplate:@""];
        if (![substring isEqualToString:newSubString]) {
            self.text = [self.text stringByReplacingOccurrencesOfString:substring withString:newSubString];
        }
    }];
}


///禁止输入汉字
- (void)banChinese{
    NSString *regex =  @"[\u4e00-\u9fa5]";
    NSError *error;
    NSRegularExpression *regexps = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
    NSRange range = NSMakeRange(0, self.text.length);
    if (regexps!=nil && !error) {
        NSString *str =  [regexps stringByReplacingMatchesInString:self.text options:0 range:range withTemplate:@""];
        self.text = str;
    }
}




@end
