//
//  UIFont+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (SH)

/**
 系统常规体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kFont(float size);

/**
 系统粗体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kBoldFont(float size);

/**
 常规体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kRegularFont(float size);

/**
 中等体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kMediumFont(float size);

/**
 幼体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kLightFont(float size);

/**
 超幼体
 @param size 尺寸, 示例: 14.0
 */
UIFont* kThinFont(float size);

@end

NS_ASSUME_NONNULL_END
