//
//  UIImage+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/29.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIImage+SH.h"
#import <YYCache/YYCache.h>
#import <ImageIO/ImageIO.h>


@implementation UIImage (SH)


+(UIImage *)name:(NSString *)name cls:(Class)aClass bundleName:(NSString *)bundleName{
    return [self name:name cls:aClass bundleName:bundleName language:nil];
}


//组件化加载图片
+ (UIImage *)name:(NSString *)name cls:(Class)aClass bundleName:(NSString *)bundleName language:(NSString *)language {
    
    //内存缓存
    static YYCache *bundlePathCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!bundlePathCache) {
#ifdef DEBUG
            bundlePathCache = (YYCache *)[YYMemoryCache new];
            ((YYMemoryCache *)bundlePathCache).name = @"SHImageCache";
            ((YYMemoryCache *)bundlePathCache).shouldRemoveAllObjectsWhenEnteringBackground = NO;
#else
            NSString *diskCacheName = [NSString stringWithFormat:@"SHImageCache.%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
            bundlePathCache = [YYCache cacheWithName:diskCacheName];
            bundlePathCache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = NO;
#endif
        }
    });
    
    // 国际化图片
    if (language) {
        // 当前默认为中文图片
        if (![language isEqualToString:@"zh-Hans"]) {
            name = [NSString stringWithFormat:@"%@_%@",name,language];
        }
    }
    
    // 缓存 key
    NSString *cacheKey = NSStringFromClass(aClass);
    // 缓存 key和name
    NSString *cacheKeyWithName = [NSString stringWithFormat:@"%@.%@",cacheKey,name];
    // 获取缓存在内存中的图片
    NSString *cachedBundlePath = (NSString *)([bundlePathCache objectForKey:cacheKeyWithName]?:[bundlePathCache objectForKey:cacheKey]);
    if (cachedBundlePath) {
        NSBundle *imageBundle = [NSBundle bundleWithPath:cachedBundlePath];
        UIImage *image = [UIImage imageNamed:name inBundle:imageBundle compatibleWithTraitCollection:nil];
        if (image) {
            //已经加载过的图片会从这获取
            return image;
        }
    }
    
    //第一次加载
    if (bundleName.length) {
        //例如 /var/containers/Bundle/Application/0D4F88BF-649E-4079-9ADB-E629F1833656/ShFlyKit_Example.app
        NSBundle *currentBundle = [NSBundle bundleForClass:aClass];
        //例如 /var/containers/Bundle/Application/0D4F88BF-649E-4079-9ADB-E629F1833656/ShFlyKit_Example.app/Components.bundle
        NSString *bundlePath = [currentBundle pathForResource:bundleName ofType:@"bundle"];
        //例如 /var/containers/Bundle/Application/0D4F88BF-649E-4079-9ADB-E629F1833656/ShFlyKit_Example.app/Components.bundle
        NSBundle *imageBundle = [NSBundle bundleWithPath:bundlePath];
        
        UIImage *image = [UIImage imageNamed:name inBundle:imageBundle compatibleWithTraitCollection:nil];
        if (image) {
            //缓存在内存中
            [bundlePathCache setObject:bundlePath forKey:cacheKey];
            return image;
        }
    }
    
    //最后没有找到
    UIImage *image = [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:aClass] compatibleWithTraitCollection:nil];
    if (!image) NSLog(@">>>> 请注意，图片名：%@ 文件未找到。",name);
    return image;
    
}



-(CGFloat)width{
    return self.size.width * self.scale;
}


-(CGFloat)height{
    return self.size.height * self.scale;
}


//划定区域截图
-(UIImage*)newImageFromOrigin:(UIImage*)origin rect:(CGRect)rect{
    UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([origin CGImage], rect)];
    return newImage;
}


//简单的保存照片
-(void)savePhotoToAlbum{
    if (self != nil) {
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil);
    }
}


+(UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx,rect);
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, rect.size.width, rect.size.height));
    CGContextClip(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage *)GaussianBlurImage{
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    CIImage *tmpImage = [CIImage imageWithCGImage:self.CGImage];
    
    [filter setValue:tmpImage forKey: kCIInputImageKey];
    [filter setValue:@50 forKeyPath:kCIInputRadiusKey];
    
    CIImage *outputCIImage = [filter outputImage];
    CIContext *ciContext = [CIContext contextWithOptions:nil];
    CGImageRef cgimage = [ciContext createCGImage:outputCIImage fromRect:outputCIImage.extent];
    UIImage *resImage = [UIImage imageWithCGImage:cgimage];
    CGImageRelease(cgimage);
    return resImage;
}


+(NSMutableDictionary *)getExifInfoWithImageData:(NSData *)imageData{
    CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    NSDictionary *dict =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
    NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    return dictInfo;
}


+(NSDictionary*)imageInformation:(NSURL *)imageUrl {
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)imageUrl, NULL);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                             nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    NSDictionary *result = (__bridge NSDictionary*)imageProperties;
    return result;
}


@end
