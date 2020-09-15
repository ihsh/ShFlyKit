//
//  LivePhotoMaker.m
//  SHKit
//
//  Created by hsh on 2019/10/10.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "LivePhotoMaker.h"
#import "liveSourceModel.h"


@import MobileCoreServices;
@import ImageIO;
@import Photos;


//指定的路径名
NSString *const kOriginPath = @"originImage.jpg";
NSString *const kLiveImagePath = @"livePhotoImage.jpg";     //必须jpg结尾
NSString *const kliveMovPath = @"livePhotoVideo.mov";       //必须mov结尾


@implementation LivePhotoMaker


+(void)makeLivePhotoByLibrary:(NSURL *)movURL completed:(void (^)(LiveResult *))didCreateLivePhoto{
    //获取到视频
    AVURLAsset *asset = [AVURLAsset assetWithURL:movURL];
    //用来提供视频的缩略图或预览视频的帧的类
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    ///异步的创建指定时间的CGImage
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:kCMTimeZero]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        //获取到的第一帧的CGImage转UIImage,压缩最少
        NSData *firstFrameData = UIImageJPEGRepresentation([UIImage imageWithCGImage:image], 1);
        //清空再写入保存到该地址
        [NSFileManager.defaultManager removeItemAtPath:[self appendPath:kOriginPath].path error:&error];
        [firstFrameData writeToURL:[self appendPath:kOriginPath] atomically:YES];
        //UUID作为标识符
        NSString *assetIdentifier = [[NSUUID UUID]UUIDString];
        //创建缓存目录
        [NSFileManager.defaultManager createDirectoryAtPath:[self getCachePath].path
                                withIntermediateDirectories:YES attributes:nil error:&error];
        [NSFileManager.defaultManager removeItemAtPath:[self appendPath:kLiveImagePath].path error:&error];
        [NSFileManager.defaultManager removeItemAtPath:[self appendPath:kliveMovPath].path error:&error];
        //写入图片到路径
        [JPGModel writeToFileWithOriginJPGPath:[self appendPath:kOriginPath] targetWritePath:[self appendPath:kLiveImagePath] assetIdentifier:assetIdentifier];
        //写入视频到路径
        [MovModel writeToFileWithOriginMovPath:movURL targetWritePath:[self appendPath:kliveMovPath] assetIdentifier:assetIdentifier];
        //返回路径
        LiveResult *model = [[LiveResult alloc]init];
        model.movPath = [self appendPath:kliveMovPath];
        model.jpgPath = [self appendPath:kLiveImagePath];
        didCreateLivePhoto(model);
    }];
    
    
}



//传入视频的路径和第一帧的路径生产livePhoto
+(void)saveLivePhotoToAlbumWithMovPath:(NSURL *)movPath imagePath:(NSURL *)jpgPath completed:(void (^)(BOOL))didSaveLivePhoto{
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        //PHAssetChangeRequest的子类,该对象用于照片库的增删改操作中
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        //一个选项的集合，这些选项影响这新的asset
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc]init];
        //添加组合的内容
        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:movPath options:options];
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:jpgPath options:options];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            didSaveLivePhoto(YES);
        }else{
            didSaveLivePhoto(NO);
        }
    }];
}


//获取缓存目录
+ (NSURL *)getCachePath {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}


//拼接对应的路径生成URL
+ (NSURL *)appendPath:(NSString*)path{
    NSURL *final = [[self getCachePath]URLByAppendingPathComponent:path];
    return final;
}


@end






@implementation LiveResult
@end
