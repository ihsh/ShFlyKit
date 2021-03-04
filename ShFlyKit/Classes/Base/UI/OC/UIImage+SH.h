//
//  UIImage+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/29.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (SH)


#undef  ImageNamed
#define ImageNamed(__named__) [UIImage imageNamed:__named__ class:[self class] filePath:[NSString stringWithFormat:@"%s",__FILE__] language:nil]


///获取不同bundle内的图片
+(UIImage *)name:(NSString *)name cls:(Class)aClass bundleName:(NSString *)bundleName;
+(UIImage *)name:(NSString *)name cls:(Class)aClass bundleName:(NSString *)bundleName language:(NSString *)language;

///主bundle使用传入名称返回图片，可省略jpg
+(UIImage*)name:(NSString*)name;
///图片的宽
-(CGFloat)width;
///图片的高
-(CGFloat)height;
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


