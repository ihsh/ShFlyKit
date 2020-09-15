//
//  UITextField+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UITextField+SH.h"

@implementation UITextField (SH)

+(instancetype)initPlaceHolder:(NSString *)placeHolder super:(nullable UIView *)superView{
    UITextField *textField = [[UITextField alloc]init];
    textField.placeholder = placeHolder;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [superView addSubview:textField];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.minimumFontSize = 12;
    return textField;
}
@end
