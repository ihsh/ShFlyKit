//
//  SHBorderView.h
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

//一个边框可设置分割线的UIView

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(unsigned, BorderStyle) {
    Border_None = 0x00, // 0
    Border_Top = 0x01, // 1
    Border_Left = 0x02, // 2
    Border_Right = 0x04, // 4
    Border_Bottom = 0x08, // 8
    
    Border_TopLeft = Border_Top | Border_Left,   // 3
    Border_TopRight = Border_Top | Border_Right,  // 5
    Border_TopBottom = Border_Top | Border_Bottom, // 9
    
    Border_LeftRight = Border_Left | Border_Right,  // 6
    Border_LeftBottom = Border_Left | Border_Bottom, // 10
    
    Border_RightBottom = Border_Right | Border_Bottom, // 12
    
    Border_TopLeftRight = Border_TopLeft | Border_Right,  // 7
    Border_TopLeftBottom = Border_TopLeft | Border_Bottom, // 11
    
    Border_TopRightBottom = Border_TopRight | Border_Bottom, // 13
    
    Border_LeftRightBottom = Border_LeftRight | Border_Bottom, // 14
    
    Border_TopLeftRightBottom = Border_TopLeft | Border_RightBottom, // 15
};


IB_DESIGNABLE //在xcode中的storyboard,xib中能实时看到效果

@interface SHBorderView : UIView
//分割线的样式
@property (nonatomic, assign) IBInspectable unsigned borderStyle;
//分割线颜色
@property (nonatomic, strong) IBInspectable UIColor *borderColor;
//分割线的厚度
@property (nonatomic, assign) CGFloat borderThick;

//分割线的偏移
@property (nonatomic, assign) IBInspectable CGFloat borderTopInset;
@property (nonatomic, assign) IBInspectable CGFloat borderLeftInset;
@property (nonatomic, assign) IBInspectable CGFloat borderRightInset;
@property (nonatomic, assign) IBInspectable CGFloat borderBottomInset;
@end

NS_ASSUME_NONNULL_END
