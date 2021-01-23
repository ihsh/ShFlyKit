//
//  UITextField+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITextField (SH)

+(instancetype)initPlaceHolder:(NSString*)placeHolder superView:(UIView*)superView;


///限制输入长度
- (void)limitTextLength:(int)length;

///禁止输入emoji
- (void)banEmoji;

///禁止输入汉字
- (void)banChinese;


@end


