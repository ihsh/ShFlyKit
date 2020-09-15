//
//  UIScreenFit.m
//  SHKit
//
//  Created by hsh on 2019/5/24.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "UIScreenFit.h"

@implementation UIScreenFit


CGFloat StatusBarHeight(){
    return [[UIApplication sharedApplication]statusBarFrame].size.height;
}


CGFloat TabBarHeight(){
    static CGFloat height = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = isFullScreen() ? 83.0f : 49.0f;
    });
    return height;
}


CGFloat NavgationBarHeight(){
    return 44.0f;
}


CGFloat ScreenContentHeight(){
    return ScreenSize().height - StatusBarHeight() -NavgationBarHeight();
}


CGFloat OrientedScreenWidth(){
    return isLandScape() ? ScreenSize().width : ScreenSize().height;
}


CGFloat OrientedScreenHeight(){
    return isLandScape() ? ScreenSize().height : ScreenSize().width;
}


//固定小的为宽度
CGSize ScreenSize(){
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height < size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}


CGFloat ScreenBottomInset(){
    static CGFloat height;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0,*)) {
            height = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets.bottom;
        }else{
            height = 0;
        }
    });
    return height;
}


bool isFullScreen(){
    static BOOL isFullScreen;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0,*)) {
            UIEdgeInsets safeAreaInsets = [UIApplication sharedApplication].windows.firstObject.safeAreaInsets;
            isFullScreen = (UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets, UIEdgeInsetsZero) == NO && safeAreaInsets.bottom > 0);
        }else{
            isFullScreen = NO;
        }
    });
    return isFullScreen;
}


bool isLandScape(){
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]);
}



+(UIView *)createMainView{
    UIView *mainView = [[UIView alloc]init];
    mainView.frame = CGRectMake(0, StatusBarHeight()+NavgationBarHeight(), ScreenSize().width, ScreenContentHeight());
    mainView.backgroundColor = UIColor.whiteColor;
    return mainView;
}

@end
