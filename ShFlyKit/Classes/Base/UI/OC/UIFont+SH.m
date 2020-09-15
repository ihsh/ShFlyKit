//
//  UIFont+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIFont+SH.h"

@implementation UIFont (SH)

UIFont* kFont(float size){
    return [UIFont systemFontOfSize:size];
}

UIFont* kBoldFont(float size){
    return [UIFont boldSystemFontOfSize:size];
}

UIFont* kLightFont(float size){
    return kFontWithNameAndSize(@"Light", size);
}

UIFont* kThinFont(float size){
    return kFontWithNameAndSize(@"Thin", size);
}

UIFont* kRegularFont(float size){
    return kFontWithNameAndSize(@"Regular", size);
}

UIFont* kMediumFont(float size){
    return kFontWithNameAndSize(@"Medium", size);
}

/**
 根据名称和尺寸返回字体
 @param name 字体名
 @param size 尺寸, 示例: 14.0
 */
UIFont* kFontWithNameAndSize(NSString* name, float size){
    NSString* baseName = @"PingFangSC";
    name = [baseName stringByAppendingFormat:@"-%@",name];
    UIFont* font = [UIFont fontWithName:name size:size];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size];
    }
    return font;
}
@end
