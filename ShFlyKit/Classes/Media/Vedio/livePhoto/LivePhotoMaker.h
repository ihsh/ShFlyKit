//
//  LivePhotoMaker.h
//  SHKit
//
//  Created by hsh on 2019/10/10.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Photos;
@import PhotosUI;
@class LiveResult;



///创建livePhoto
@interface LivePhotoMaker : NSObject

//传入视频生成图片帧路径和视频的路径
+(void)makeLivePhotoByLibrary:(NSURL*)movURL completed:(void(^)(LiveResult * result))didCreateLivePhoto;
//传入视频的路径和图片帧的路径生产livePhoto
+(void)saveLivePhotoToAlbumWithMovPath:(NSURL*)movPath imagePath:(NSURL*)jpgPath completed:(void(^)(BOOL isSuccess))didSaveLivePhoto;

@end




///通过视频创建视频和图片帧路径结果
@interface LiveResult : NSObject
@property(nonatomic,strong)NSURL *movPath;          //视频路径
@property(nonatomic,strong)NSURL *jpgPath;          //图片帧路径
@end
