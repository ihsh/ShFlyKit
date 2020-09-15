//
//  UIImage+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/29.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SH)

///图片的宽
-(CGFloat)width;
///图片的高
-(CGFloat)height;
//传入名称返回图片，可省略jpg
+(UIImage*)name:(NSString*)name;
//划定区域截图
-(UIImage*)newImageFromOrigin:(UIImage*)origin rect:(CGRect)rect;
//简单的保存照片
-(void)savePhotoToAlbum;
//创建纯色的UIImage
+(UIImage*)imageWithColor:(UIColor*)color rect:(CGRect)rect;
//返回高斯模糊的UIImage
-(UIImage*)GaussianBlurImage;
//获取EXIF信息
+(NSMutableDictionary *)getExifInfoWithImageData:(NSData *)imageData;
//获取照片的信息
+(NSDictionary*)imageInformation:(NSURL *)imageUrl;
@end

NS_ASSUME_NONNULL_END
