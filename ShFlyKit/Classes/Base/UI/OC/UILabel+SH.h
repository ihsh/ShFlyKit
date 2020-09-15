//
//  UILabel+SH.h
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (SH)

//初始化
+(instancetype)initText:(nullable NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor alignment:(NSTextAlignment)align super:(UIView*)superView;

//高亮匹配的部分
-(void)hightMatch:(NSString*)content color:(UIColor*)hightColor;


@end

NS_ASSUME_NONNULL_END
