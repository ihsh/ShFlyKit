//
//  UIImage+Color.h
//  SHKit
//
//  Created by hsh on 2019/5/30.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Color)

-(UIColor*)colorAtPixel:(CGPoint)point rect:(CGRect)showRect;

@end

NS_ASSUME_NONNULL_END
