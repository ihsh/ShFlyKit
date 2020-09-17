//
//  SHLabel.h
//  SHLabel
//
//  Created by hsh on 19/8/22.
//  Copyright © 2019年 hsh. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "SHLabelPath.h"


//水平对齐方式
typedef enum : NSUInteger {
    SHLabelHorizontalAlignmentLeft,
    SHLabelHorizontalAlignmentCenter,
    SHLabelHorizontalAlignmentRight,
} SHLabelHorizontalAlignment;


//竖直对齐方式
typedef enum : NSUInteger {
    SHLabelVerticalAlignmentUp,
    SHLabelVerticalAlignmentCenter,
    SHLabelVerticalAlignmentDown,
} SHLabelVerticalAlignment;



///自定义路径的文本显示
@interface SHLabel : UIView
@property(nonatomic,copy)IBInspectable NSString *text;                                //要显示的文本
@property(nonatomic,strong)IBInspectable UIColor *textColor;                          //文本颜色
@property(nonatomic,strong)UIFont *font;                                              //文本字体
@property(nonatomic,copy)NSAttributedString *attributedText;                          //富文本
@property(nonatomic,strong,readonly) NSArray<CATextLayer*>*layerArray;                //字符层数组。可以通过此数组来控制各个字符来实现你想要的效果
@property(nonatomic,assign)CGFloat elementSpacing;                                    //两个字符之间的间距。为0时是正常情况下间距，小于0则间距缩小，大于0间距则增加。
@property(nonatomic,assign)CGFloat rowSpacing;                                        //行之间的间距。为0时是正常情况下间距，小于0则间距缩小，大于0间距则增加



//刷新图层，一般用在设置attributedText后修改属性使用，其他地方不需调用。如果attributedText为nil则该函数没有任何效果
-(void)refreshLayer:(BOOL)animation;
//设置文本水平对齐方向
-(void)setTextHorizontalAlignment:(SHLabelHorizontalAlignment)textHorizontalAlignment animation:(BOOL)animation;
//设置文本垂直对齐方向
-(void)setTextVerticalAlignment:(SHLabelVerticalAlignment)textVerticalAlignment animation:(BOOL)animation;

@end




#pragma mark - 路径分类
@interface SHLabel (Path)
@property(nonatomic) SHLabelPath *path;             //字符路径。路径将无视换行符(\n)

-(void)setPath:(SHLabelPath *)path rotate:(BOOL)rotate animation:(BOOL)animation;
@end


#pragma mark - 手势滑动自定义路径分类
@interface SHLabel (gesturePath)
@property(nonatomic,assign)BOOL gesturePathEnable;
@end


#pragma mark - 文本动画效果
@interface SHLabel (Animation)
/**
 *  @brief  启动跳动动画
 *  @param height   跳动幅度
 *  @param beatTime 跳一次所用时间
 *  @param banTime  两次跳动之间的禁止时间
 *  @param stepTime 两个字符之间跳动的间隔时间
 */
-(void)startBeatAnimationWithBeatHeight:(CGFloat)height beatTime:(NSTimeInterval)beatTime banTime:(NSTimeInterval)banTime stepTime:(NSTimeInterval)stepTime;
//停止跳动动画
-(void)stopBeatAnimation;
//启动抖动动画
-(void)startWiggleAnimation;
//停止抖动动画
-(void)stopWiggleAnimation;
@end


#pragma mark - 文本显示隐藏动画效果
//动画移动方向
typedef enum : NSUInteger {
    SHLabelAnimationDirectionDown,
    SHLabelAnimationDirectionUp,
    SHLabelAnimationDirectionLeft,
    SHLabelAnimationDirectionRight,
} SHLabelAnimationDirection;


@interface SHLabel (ShowAndHide)
//启动显示动画（直线移动
-(void)startShowWithDirection:(SHLabelAnimationDirection)direction duration:(NSTimeInterval)duration bounce:(CGFloat)bounce stepTime:(NSTimeInterval)stepTime;
//停止显示动画（直线移动）
-(void)stopDropShow;
//启动隐藏动画（直线移动）
-(void)startHideWithDirection:(SHLabelAnimationDirection)direction duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
//停止隐藏动画（直线移动）
-(void)stopDropHide;
//启动显示动画（固定位置）
-(void)startFixedShowWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
//停止显示动画（固定位置）
-(void)stopFixedShow;
//启动隐藏动画（固定位置）
-(void)startFixedHideWithTransform:(CATransform3D *)transform duration:(NSTimeInterval)duration stepTime:(NSTimeInterval)stepTime;
//停止隐藏动画（固定位置）
-(void)stopFixedHide;

@end
