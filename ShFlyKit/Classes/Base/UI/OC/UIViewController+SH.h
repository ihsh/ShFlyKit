//
//  UIViewController+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SH)

+(UIViewController*)topViewController;
//获取当前window显示的控制器
+(UIViewController *)getCurrentVC;
//让导航栏透明
-(void)makeNavTranslucent;
//恢复导航栏透明
-(void)restoreNavTranslucent;

@end

NS_ASSUME_NONNULL_END
