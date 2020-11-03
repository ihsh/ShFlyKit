//
//  CADisplayGifImage.m
//  SHKit
//
//  Created by hsh on 2018/10/31.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "CADisplayGifImage.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


static inline NSTimeInterval CGImageSourceGetGifFrameDelay(CGImageSourceRef imageSource,NSUInteger index)
{
    NSTimeInterval frameDuration = 0;
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
#ifndef OLExactGIFRepresentation
    if (frameDuration < 0.02 - FLT_EPSILON) {
        frameDuration = 0.1;
    }
#endif
    return frameDuration;
}


//判断是否是gif
inline static BOOL CGImageSourceContainsAnimatedGif(CGImageSourceRef imageSource){
    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
}


//判断是否是双倍图
inline static BOOL isRetinaFilePath(NSString *path){
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@2x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}



@interface CADisplayGifImage ()
{
    CGImageSourceRef _imageSourceRef;
    CGFloat _scale;
    dispatch_queue_t readFrameQueue;
}
@property (nonatomic,readwrite) NSTimeInterval   *frameDurations;
@property (nonatomic,readwrite) NSUInteger       loopCount;
@property (nonatomic,readwrite) NSMutableArray   *images;
@property (nonatomic,readwrite) NSTimeInterval   totalDuratoin;
@end


static int _prefetchedNum = 10;


@implementation CADisplayGifImage
@synthesize images;


#pragma mark 重写UIImage的创建方法
-(instancetype)initWithContentsOfFile:(NSString *)path{
    return [self initWithData:[NSData dataWithContentsOfFile:path] scale:isRetinaFilePath(path) ? 2.0f:1.0f];
}


-(instancetype)initWithData:(NSData *)data{
    return [self initWithData:data scale:1.0f];
}


-(instancetype)initWithData:(NSData *)data scale:(CGFloat)scale{
    if (data == nil) {
        return nil;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    //如果是gif图，就用这种方式创建
    if (CGImageSourceContainsAnimatedGif(imageSource)) {
        self = [self initWithCGImageSource:imageSource scale:scale];
    }else{
        if (scale == 1.0f) {
            self = [super initWithData:data];
        }else{
            self = [super initWithData:data scale:scale];
        }
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return self;
}



-(instancetype)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale{
    self = [super init];
    if (imageSource == nil || self == nil) {
        return nil;
    }
    CFRetain(imageSource);
    //帧数
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
    NSDictionary *gifProperties = [imageProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary];
    //开辟空间
    self.frameDurations = (NSTimeInterval*)malloc(numberOfFrames *sizeof(NSTimeInterval));
    //读取循环次数
    self.loopCount = [gifProperties[(NSString*)kCGImagePropertyGIFLoopCount]unsignedIntegerValue];
    //创建所有图片的数值
    self.images = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    NSNull *aNull = [NSNull null];
    for (NSUInteger i=0; i<numberOfFrames; ++i) {
        //读取每张图片的显示时间，添加到数组中，并计算总h时间
        [self.images addObject:aNull];
        NSTimeInterval frameDuration = CGImageSourceGetGifFrameDelay(imageSource, i);
        self.frameDurations[i] = frameDuration;
        self.totalDuratoin += frameDuration;
    }
    NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
    for (int i=0; i<num; i++) {
        //替换读取到的每一张图片
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        [self.images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:scale orientation:UIImageOrientationUp]];
        CFRelease(image);
    }
    //释放资源，创建子队列
    _imageSourceRef = imageSource;
    CFRetain(_imageSourceRef);
    CFRelease(imageSource);
    _scale = scale;
    readFrameQueue = dispatch_queue_create("gif.load", DISPATCH_QUEUE_SERIAL);
    return self;
}



#pragma mark - Class Methods
+(UIImage*)imageNamed:(NSString *)name{
    NSString *path = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:name];
    return ([[NSFileManager defaultManager]fileExistsAtPath:path] ? [self imageWithContentsOfFile:path] : nil);
}


+(UIImage *)imageWithContentsOfFile:(NSString *)path{
    return [self imageWithData:[NSData dataWithContentsOfFile:path] scale:isRetinaFilePath(path) ? 2.0 : 1.0];
}


+(UIImage *)imageWithData:(NSData *)data{
    return [self imageWithData:data scale:1.0f];
}


+(UIImage*)imageWithData:(NSData *)data scale:(CGFloat)scale{
    if (data == nil) {
        return nil;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    UIImage *image;
    if (CGImageSourceContainsAnimatedGif(imageSource)) {
        image = [[self alloc]initWithCGImageSource:imageSource scale:scale];
    }else{
        image = [super imageWithData:data scale:scale];
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return image;
}



#pragma mark Custom Method
//根据当前index来获取gif图片的第几个图片
-(UIImage *)getFrameWithIndex:(NSUInteger)index{
    UIImage *frame = nil;
    if (index > self.images.count - 1) {
        return nil;
    }
    @synchronized (self.images) {
        frame = self.images[index];
    }
    //返回对应的index的图片
    if (frame != nil) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imageSourceRef, index, NULL);
        frame =  [UIImage imageWithCGImage:imageRef scale:_scale orientation:UIImageOrientationUp];
        CFRelease(imageRef);
    }
    /**
     *  如果图片张数大于10，进行如下操作的目的是
     由于该方法会频繁调用，为加快速度和节省内存，对取值所在的数组进行了替换，只保留10个内容
     并随着的不断增大，对原来被替换的内容进行还原，但是被还原的个数和保留的个数总共为10个，这个是最开始进行的设置的大小
     */
    
    if (self.images.count > _prefetchedNum) {
        if (index != 0) {
            [self.images replaceObjectAtIndex:index withObject: [NSNull null]];
        }
        NSUInteger nextReadIndex = index + _prefetchedNum;
        for (NSUInteger i = index + 1; i < nextReadIndex; i ++) {
            //保证每次的index都小于数组个数，从而使最大值的下一个是最小值
            NSUInteger _idx = i % self.images.count;
            if ([self.images[_idx] isKindOfClass:[NSNull class]]) {
                
                dispatch_async(readFrameQueue, ^{
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(self->_imageSourceRef, _idx, NULL);
                    @synchronized (self.images) {
                        [self.images replaceObjectAtIndex:_idx withObject:[UIImage imageWithCGImage:imageRef scale:self->_scale orientation:UIImageOrientationUp]];
                    }
                    CFRelease(imageRef);
                });
            }
        }
    }
    return frame;
}


-(NSUInteger)getFrameCount{
    return self.images.count;
}


-(CGSize)size{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] size];
    }
    return [super size];
}


-(CGImageRef)CGImage{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] CGImage];
    }
    return [super CGImage];
}



-(UIImageOrientation)imageOrientation{
    if (self.images.count) {
        return [[self.images objectAtIndex:0] imageOrientation];
    }
    return [super imageOrientation];
}



-(CGFloat)scale{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] scale];
    }
    return [super scale];
}



-(NSTimeInterval)duration{
    return self.images ? self.totalDuratoin : [super duration];
}



-(void)dealloc{
    if (_imageSourceRef) {
        CFRelease(_imageSourceRef);
    }
    free(_frameDurations);
}
@end
