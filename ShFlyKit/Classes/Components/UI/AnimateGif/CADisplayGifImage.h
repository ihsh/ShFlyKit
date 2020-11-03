//
//  CADisplayGifImage.h
//  SHKit
//
//  Created by hsh on 2018/10/31.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//CADisplayGifImageView使用的类，用于显示gif图片
@interface CADisplayGifImage : UIImage

@property(nonatomic,readonly)NSTimeInterval *frameDurations;    //每帧间隔时长
@property(nonatomic,readonly)NSUInteger     loopCount;          //循环次数
@property(nonatomic,readonly)NSTimeInterval totalDuration;

//获取对应下标的帧图片
-(UIImage*)getFrameWithIndex:(NSUInteger)index;
//获取总帧数
-(NSUInteger)getFrameCount;
@end

NS_ASSUME_NONNULL_END
