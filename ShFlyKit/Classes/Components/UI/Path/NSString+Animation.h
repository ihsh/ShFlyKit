//
//  NSString+Animation.h
//  SHKit
//
//  Created by hsh on 2019/8/22.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

///文字路径绘制
@interface NSString (Animation)

- (void)animateOnView:(UIView *)aView lineWidth:(CGFloat)width rect:(CGRect)aRect font:(UIFont *)aFont color:(UIColor *)aColor duration:(CGFloat)aDuration;

@end


