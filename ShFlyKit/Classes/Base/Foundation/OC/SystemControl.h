//
//  SystemControl.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SystemControl : NSObject
#pragma mark - 系统设置的url跳转
/// 是否能打开指定 URL Scheme
+ (BOOL)canOpenURLString:(NSString *)urlString;

///打开路径
+ (void)openUrlString:(NSString*)urlString;

/// 打开系统设置 - 当前app
+ (void)openAppSetting;

///打开App Store评分
+ (void)openStoreRatingWithItunesId:(NSString *)itunesId;


@end

