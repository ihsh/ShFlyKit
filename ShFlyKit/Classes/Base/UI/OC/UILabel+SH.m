//
//  UILabel+SH.m
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UILabel+SH.h"

@implementation UILabel (SH)


+(instancetype)initText:(nullable NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor alignment:(NSTextAlignment)align super:(nonnull UIView *)superView{
    UILabel *label = [[UILabel alloc]init];
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = align;
    if (superView != nil) {
        [superView addSubview:label];
    }
    return label;
}


-(void)hightMatch:(NSString *)content color:(UIColor *)hightColor{
    if (content.length&&self.text.length) {
        NSString *text = self.text;
        NSString *first = [content substringWithRange:NSMakeRange(0, 1)];
        NSInteger index = 0;
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]init];
        while (index <= text.length-1) {
            NSString *sub = [text substringWithRange:NSMakeRange(index, 1)];
            //找到起点
            if ([sub isEqualToString:first]) {
                if (index + content.length <= text.length - 1) {
                    NSString *tmp = [text substringWithRange:NSMakeRange(index, content.length)];
                    //相同
                    if ([tmp isEqualToString:content]) {
                        NSAttributedString *tmpAttri = [[NSAttributedString alloc]initWithString:tmp attributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:hightColor}];
                        [attri appendAttributedString:tmpAttri];
                        index += content.length;
                    }else{
                        [self attributeStringAppendNormarString:attri norContent:tmp];
                        index += 1;
                    }
                }else{
                    [self attributeStringAppendNormarString:attri norContent:sub];
                    index += 1;
                }
            }else{
                [self attributeStringAppendNormarString:attri norContent:sub];
                index += 1;
            }
        }
        self.attributedText = attri;
    }else{
        self.attributedText = nil;
    }
}


-(void)attributeStringAppendNormarString:(NSMutableAttributedString*)attri norContent:(NSString*)tmp{
    NSAttributedString *tmpAttri = [[NSAttributedString alloc]initWithString:tmp attributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor}];
    [attri appendAttributedString:tmpAttri];
}


@end
