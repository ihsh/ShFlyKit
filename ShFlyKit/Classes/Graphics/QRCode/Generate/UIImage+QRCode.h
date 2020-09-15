//
//  UIImage+QRCode.h
//  SHKit
//
//  Created by hsh on 2018/11/22.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (QRCode)

//输入CIImage返回一张高清的图片
+(UIImage*)clarificateImage:(CIImage*)image size:(CGSize)size;

//改变二维码颜色颜色-非透明部分改为某种颜色
+ (UIImage *)colorQRImage:(UIImage *)image size:(CGSize)size color:(UIColor*)color;

//添加logo的二维码
+(UIImage *)logoQRImage:(UIImage *)qrImage logo:(UIImage *)logo size:(CGSize)size;

//创建条形码
+ (UIImage *)barcodeImageWithContent:(NSString *)content codeImageSize:(CGSize)size color:(UIColor*)color;

@end


