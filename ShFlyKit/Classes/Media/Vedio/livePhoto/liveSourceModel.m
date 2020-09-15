//
//  liveSourceModel.m
//  SHKit
//
//  Created by hsh on 2019/10/9.
//  Copyright © 2019 hsh. All rights reserved.
//


#import "liveSourceModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>


NSString *const kFigAppleMakerNote_AssetIdentifier = @"17";


@implementation JPGModel


+(void)writeToFileWithOriginJPGPath:(NSURL *)origin
                    targetWritePath:(NSURL *)finalPath
                    assetIdentifier:(NSString *)identifier{
    
    CGImageDestinationRef dest = CGImageDestinationCreateWithURL((CFURLRef)finalPath, kUTTypeJPEG, 1, nil);
    CGImageSourceRef imageSoureceRef = CGImageSourceCreateWithData((CFDataRef)[NSData dataWithContentsOfFile:origin.path], nil);
    NSMutableDictionary *metaData = [(__bridge_transfer NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageSoureceRef, 0, nil)mutableCopy];
    NSMutableDictionary *makerNote = [NSMutableDictionary dictionary];
    [makerNote setValue:identifier forKey:kFigAppleMakerNote_AssetIdentifier];
    [metaData setValue:makerNote forKey:(__bridge_transfer NSString*)kCGImagePropertyMakerAppleDictionary];
    CGImageDestinationAddImageFromSource(dest, imageSoureceRef, 0, (CFDictionaryRef)metaData);
    CGImageDestinationFinalize(dest);
    CFRelease(dest);
    
}



+(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)bufferRef{
    //为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(bufferRef);
    //锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    //得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    //得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    //得到pixel buffer的宽和高
    size_t with = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用抽样缓存的数据创建一个位图格式的图形上下文(graphics context)对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, with, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    //解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    //释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //用quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    //释放quartz image对象
    CVBufferRelease(imageBuffer);
    CGImageRelease(quartzImage);
    UIGraphicsEndImageContext();
    return image;
}


@end




NSString *const kKeyContentIdentifier = @"com.apple.quicktime.content.identifier";
NSString *const kKeyStillImageTime = @"com.apple.quicktime.still-image-time";
NSString *const kKeySpaceQuickTimeMetadata = @"mdta";



@implementation MovModel


+(void)writeToFileWithOriginMovPath:(NSURL *)origin
                    targetWritePath:(NSURL *)finalPath
                    assetIdentifier:(NSString *)idenrifier{
    //用于从本地或远程URL初始化资源的AVAsset的具体子类
    AVURLAsset *asset = [AVURLAsset assetWithURL:origin];
    //视頻轨-为视频媒体跟踪提供跟踪级检查接口的对象
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    if (videoTrack == nil) {return;}
    //音轨
    AVAssetTrack *audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    //从资源读取器对象中读取单个样本的集合
    AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:@{(__bridge_transfer NSString*)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
    //音频的配置
    NSDictionary *audioDic = @{AVFormatIDKey:@(kAudioFormatLinearPCM),
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMBitDepthKey:@(16)};
    //读取音频数据的对象
    AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:audioDic];
    //读取器对象，可以是基于文件的，也可以基于多个源的媒体数据集合
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
    //添加视频源
    if ([reader canAddOutput:videoOutput]) {
        [reader addOutput:videoOutput];
    }
    //添加音频源
    if ([reader canAddOutput:audioOutput]) {
        [reader addOutput:audioOutput];
    }
    //视频输出配置
    NSDictionary *outputSetting = @{AVVideoCodecKey:AVVideoCodecTypeH264,//视频编码
                                    AVVideoWidthKey:[NSNumber numberWithFloat:videoTrack.naturalSize.width],
                                    AVVideoHeightKey:[NSNumber numberWithFloat:videoTrack.naturalSize.height]};
    //用于将媒体样本附加到资源写入器的单个跟踪写入器
    AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSetting];
    //指示输入是否应调整其对实时源媒体数据的处理
    videoInput.expectsMediaDataInRealTime = true;
    videoInput.transform = videoTrack.preferredTransform;
    //音频的设置
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                                   [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt:128000],AVEncoderBitRateKey, nil];
    //AVAssetWriterInput
    AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[audioTrack mediaType] outputSettings:audioSettings];
    audioInput.expectsMediaDataInRealTime = true;
    audioInput.transform = audioTrack.preferredTransform;
    //一个用于将媒体数据写入指定的容器类型到新文件的对象
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:finalPath fileType:AVFileTypeQuickTimeMovie error:nil];
    writer.metadata = @[[self metaDataSet:idenrifier]];
    [writer addInput:videoInput];
    [writer addInput:audioInput];
    //pixel buffer的配置
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                                           kCVPixelBufferPixelFormatTypeKey, nil];
    //用于将打包为像素缓冲区的视频样本附加到单个资产写入器输入的缓冲区
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    //一个对象，该对象定义了一个借口，用于将打包的元数组写入到单个的AVAssetWriter中
    AVAssetWriterInputMetadataAdaptor *adapter = [self metaDataSetAdapter];
    [writer addInput:adapter.assetWriterInput];
    [writer startWriting];
    [reader startReading];
    [writer startSessionAtSourceTime:kCMTimeZero];
    //时间范围结构体
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(0, 1000), CMTimeMake(200, 3000));
    //可变元数据项
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyStillImageTime;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = [NSNumber numberWithInt:0];
    item.dataType = @"com.apple.metadata.datatype.int8";
    [adapter appendTimedMetadataGroup:[[AVTimedMetadataGroup alloc]initWithItems:[NSArray arrayWithObject:item] timeRange:timeRange]];
    
    dispatch_queue_t createMovQueue = dispatch_queue_create("createMovQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(createMovQueue, ^{
        while (reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef videoBuffer = [videoOutput copyNextSampleBuffer];
            CMSampleBufferRef audioBuffer = [audioOutput copyNextSampleBuffer];
            if (videoBuffer) {
                //标识现在缓冲区中的数据是否已经处理完成
                while (videoInput.isReadyForMoreMediaData == NO || audioInput.isReadyForMoreMediaData == NO) {
                    usleep(1);
                }
                if (audioBuffer) {
                    [audioInput appendSampleBuffer:audioBuffer];
                    CFRelease(audioBuffer);
                }
                //不剪切
                [adaptor.assetWriterInput appendSampleBuffer:videoBuffer];
                CMSampleBufferInvalidate(videoBuffer);
                CFRelease(videoBuffer);
                videoBuffer = nil;
            }else{
                continue;
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [writer finishWritingWithCompletionHandler:^{
            }];
        });
    });
    
    while (writer.status == AVAssetWriterStatusWriting) {
        [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
}





///Private
//AVAssetWriter的配置项
+(AVMetadataItem *)metaDataSet:(NSString*)assetIdentifier{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.key = kKeyContentIdentifier;
    item.keySpace = kKeySpaceQuickTimeMetadata;
    item.value = assetIdentifier;
    item.dataType = @"com.apple.metadata.datatype.UTF-8";
    return item;
}



+(AVAssetWriterInputMetadataAdaptor *)metaDataSetAdapter{
    NSString *identifier = [kKeySpaceQuickTimeMetadata stringByAppendingFormat:@"/%@",kKeyStillImageTime];
    const NSDictionary *spec = @{(__bridge_transfer NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier:identifier,(__bridge_transfer NSString*)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType:@"com.apple.metadata.datatype.int8"};
    
    CMFormatDescriptionRef desc;
    CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)@[spec], &desc);
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:desc];
    CFRelease(desc);
    return [AVAssetWriterInputMetadataAdaptor assetWriterInputMetadataAdaptorWithAssetWriterInput:input];
}


@end
