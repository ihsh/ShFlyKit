//
//  UIButton+SH.m
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UIButton+SH.h"

@implementation UIButton (SH)

+(instancetype)initTitle:(NSString*)title textColor:(UIColor*)textColor backColor:(UIColor*)backColor font:(UIFont*)font super:(UIView*)superView{
    UIButton *btn = [[UIButton alloc]init];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn setBackgroundColor:backColor];
    btn.titleLabel.font = font;
    [superView addSubview:btn];
    return btn;
}


+(instancetype)initImage:(UIImage*)image back:(BOOL)backGround super:(UIView*)superView{
    UIButton *btn = [[UIButton alloc]init];
    if (backGround) {
        [btn setBackgroundImage:image forState:UIControlStateNormal];
    }else{
        [btn setImage:image forState:UIControlStateNormal];
    }
    [superView addSubview:btn];
    return btn;
}

+(instancetype)initImage:(UIImage*)image{
    UIButton *btn = [[UIButton alloc]init];
    [btn setImage:image forState:UIControlStateNormal];
    return btn;
}
@end


@implementation UIButtonLayout

+(UIButtonLayout *)layout:(UIButton *)btn left:(CGFloat)leftMargin right:(CGFloat)rightMargin width:(CGFloat)width height:(CGFloat)height{
    UIButtonLayout *layout = [[UIButtonLayout alloc]init];
    layout.btn = btn;
    layout.leftMargin = leftMargin;
    layout.rightMargin = rightMargin;
    layout.width = width;
    layout.height = height;
    return layout;
}
@end
