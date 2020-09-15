//
//  UIImage+Color.m
//  SHKit
//
//  Created by hsh on 2019/5/30.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

//获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)pos rect:(CGRect)showRect{
    //所点的位置在图像中的比例
    CGFloat xRate = pos.x / showRect.size.width;
    CGFloat yRate = pos.y / showRect.size.height;
    //图片的尺寸
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    //在画面中的实际点
    CGPoint point = CGPointMake((width*xRate),(height*yRate));
    //取整
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    
    CGImageRef cgImage = self.CGImage;
    //取当前的色彩空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
