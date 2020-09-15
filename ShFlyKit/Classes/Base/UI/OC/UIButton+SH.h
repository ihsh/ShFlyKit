//
//  UIButton+SH.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SH)

+(instancetype)initTitle:(NSString*)title
               textColor:(UIColor*)textColor
               backColor:(UIColor*)backColor
                    font:(UIFont*)font
                   super:(nullable UIView*)superView;


+(instancetype)initImage:(UIImage*)image back:(BOOL)backGround super:(nullable UIView*)superView;

+(instancetype)initImage:(UIImage*)image;

@end


@interface UIButtonLayout:NSObject
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,assign)CGFloat leftMargin;
@property(nonatomic,assign)CGFloat rightMargin;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat height;


+(UIButtonLayout*)layout:(UIButton*)btn
                    left:(CGFloat)leftMargin
                   right:(CGFloat)rightMargin
                   width:(CGFloat)width
                  height:(CGFloat)height;
@end
NS_ASSUME_NONNULL_END
