//
//  SystemControl.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "SystemControl.h"

@implementation SystemControl

#pragma mark - 系统设置的url跳转

+ (void)openUrlString:(NSString *)urlString{
    NSURL* url = [NSURL URLWithString:urlString];
    UIApplication *app = [UIApplication sharedApplication];
    if (![app canOpenURL:url]) return;
    
    if (@available(iOS 10.0,*)) {
        [app openURL:url options:@{} completionHandler:nil];
    }else{
        [app openURL:url];
    }
}


+ (void)openAppSetting{
    [self openUrlString:UIApplicationOpenSettingsURLString];
}



+ (void)openStoreRatingWithItunesId:(NSString *)itunesId{
    NSString * strUrl = @"";
    strUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review&mt=8",itunesId];
    [self openUrlString:strUrl];
}


@end
