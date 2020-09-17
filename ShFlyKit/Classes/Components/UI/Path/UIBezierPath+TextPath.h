//
//  UIBezierPath+TextPath.h
//  SHKit
//
//  Created by hsh on 2019/8/22.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIBezierPath (TextPath)

+ (UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;

@end


