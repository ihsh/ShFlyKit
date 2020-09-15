//
//  UIScreenFit.h
//  SHKit
//
//  Created by hsh on 2019/5/24.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

//屏幕参数信息类
@interface UIScreenFit : UIView
//状态栏高度
CGFloat StatusBarHeight(void);
//底部栏高度
CGFloat TabBarHeight(void);
//导航栏高度
CGFloat NavgationBarHeight(void);
//屏幕显示区域高度
CGFloat ScreenContentHeight(void);
//显示的宽度---横屏/竖屏
CGFloat OrientedScreenWidth(void);
//显示的高度---横屏/竖屏
CGFloat OrientedScreenHeight(void);
//屏幕区域大小
CGSize ScreenSize(void);
//底部间距
CGFloat ScreenBottomInset(void);
//是否是全面屏
bool isFullScreen(void);
//是否水平
bool isLandScape(void);

//创建一个MainView
+(UIView*)createMainView;

@end


