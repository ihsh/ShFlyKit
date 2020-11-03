//
//  ScreenSnap.h
//  SHKit
//
//  Created by hsh on 2018/11/6.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <AVKit/AVKit.h>



@interface ScreenSnap : NSObject
//普通截图，针对一般的视图上添加视图的情况，未使用layer和openGL渲染的视图上使用
+(UIImage*)snapNormalView:(UIView*)tagerView;
//针对有用过OpenGL渲染过的视图
+(UIImage*)openGlSnapShot:(UIView*)targetView;
//UIWebView截图
+(UIImage*)webViewSnapShot:(WKWebView*)webView;
//UIScrollView/UITableView截图
+(UIImage*)snapScrollView:(UIScrollView*)scrollView;
//多张照片合成
+(UIImage*)compositeImages:(NSArray*)images size:(CGSize)imageSize bounds:(CGSize)bounds horizontal:(BOOL)horizontal;
//截取视频某帧
+(UIImage*)avAssetFrameFromUrl:(NSURL*)movieUrl sec:(NSUInteger)sec;
@end


