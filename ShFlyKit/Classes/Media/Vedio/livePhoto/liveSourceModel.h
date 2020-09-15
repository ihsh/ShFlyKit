//
//  liveSourceModel.h
//  SHKit
//
//  Created by hsh on 2019/10/9.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


///LivePhoto的照片模型
@interface JPGModel : NSObject

+(void)writeToFileWithOriginJPGPath:(NSURL*)origin
                    targetWritePath:(NSURL*)finalPath
                    assetIdentifier:(NSString*)identifier;

+(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)bufferRef;

@end




///LivePhoto的视频模型
@interface MovModel : NSObject

+(void)writeToFileWithOriginMovPath:(NSURL*)origin
                    targetWritePath:(NSURL*)finalPath
                    assetIdentifier:(NSString*)idenrifier;

@end

