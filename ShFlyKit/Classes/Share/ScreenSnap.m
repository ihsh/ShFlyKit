//
//  ScreenSnap.m
//  SHKit
//
//  Created by hsh on 2018/11/6.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "ScreenSnap.h"

@implementation ScreenSnap

//普通视图截图
+(UIImage *)snapNormalView:(UIView *)targerView{
    UIGraphicsBeginImageContextWithOptions(targerView.frame.size, NO, [UIScreen mainScreen].scale);
    [targerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapImage;
}


+(UIImage*)openGlSnapShot:(UIView*)targetView{
    CGSize size = targetView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGRect rect = targetView.frame;
    [targetView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapImage;
}


//webView截图
+(UIImage*)webViewSnapShot:(WKWebView*)webView{
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize boundsSize = webView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1000);
    CGFloat contentHeight = contentSize.height;
    CGPoint offset = webView.scrollView.contentOffset;
    
    [webView.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, YES, scale);
        [webView.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = webView.scrollView.contentOffset.y;
        [webView.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    [webView.scrollView setContentOffset:offset];
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;

}




//给出多张图片合成
+(UIImage*)compositeImages:(NSArray*)images size:(CGSize)imageSize bounds:(CGSize)bounds horizontal:(BOOL)horizontal{
    UIGraphicsBeginImageContext(imageSize);
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat height = bounds.height;
    CGFloat width = bounds.width;
    //拼接图片
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        if (horizontal) {
            [image drawInRect:CGRectMake(scale*width*idx,0, scale*width, scale*height)];
        }else{
            [image drawInRect:CGRectMake(0,scale*height*idx , scale*width, scale*height)];
        }
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}



+(UIImage*)snapScrollView:(UIScrollView*)scrollView{
    //第一个参数表示区域大小，第二个参数表示是否是非透明，需要半透明为YES，第三个参数是屏幕密度，调整清晰度
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, YES, [UIScreen mainScreen].scale);
    //原始偏移量
    CGPoint originOffset= scrollView.contentOffset;
    CGRect originFrame = scrollView.frame;
    //设置成起点
    [scrollView setContentOffset:CGPointZero];
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    //绘制
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //恢复成原始
    scrollView.contentOffset = originOffset;
    scrollView.frame = originFrame;
    UIGraphicsEndImageContext();
    return image;
}



//截图视频帧数
+(UIImage*)avAssetFrameFromUrl:(NSURL*)movieUrl sec:(NSUInteger)sec{
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:movieUrl options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailRef = NULL;
    NSError *error = nil;
    thumbnailRef = [generator copyCGImageAtTime:CMTimeMake(sec*15, 15) actualTime:NULL error:&error];
    if (thumbnailRef == nil) {
        
    }
    UIImage *image = thumbnailRef ? [[UIImage alloc]initWithCGImage:thumbnailRef] : nil;
    return image;
}


@end
