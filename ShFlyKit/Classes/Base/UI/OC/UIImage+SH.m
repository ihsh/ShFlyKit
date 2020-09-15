//
//  UIImage+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/29.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIImage+SH.h"

@implementation UIImage (SH)

-(CGFloat)width{
    return self.size.width * self.scale;
}

-(CGFloat)height{
    return self.size.height * self.scale;
}

+(UIImage*)name:(NSString*)name{
    UIImage *image = [UIImage imageNamed:name];
    if (image == nil) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",name]];
    }
    return image;
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
