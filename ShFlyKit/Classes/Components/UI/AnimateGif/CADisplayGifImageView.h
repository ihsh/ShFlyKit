//
//  CADisplayGifImageView.h
//  SHKit
//
//  Created by hsh on 2018/10/31.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CADisplayGifImage.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE

//加载gif图片资源的UIImageView
@interface CADisplayGifImageView : UIImageView
@property (nonatomic,strong) CADisplayGifImage *animatedImage;

+(CADisplayGifImageView*)animateGifFullName:(NSString*)fullName;

+(CADisplayGifImageView*)animateGifFullName:(NSString*)fullName bundleName:(NSString*)bundleName;
@end

NS_ASSUME_NONNULL_END
