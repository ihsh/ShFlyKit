//
//  SHBorderView.m
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "SHBorderView.h"

@implementation SHBorderView
{
    CALayer *_leftLineLayer;
    CALayer *_topLineLayer;
    CALayer *_rightLineLayer;
    CALayer *_bottomLineLayer;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateBorder];
}


- (void)updateBorder {
    if (_borderThick == 0) {
        _borderThick = 0.5;
    }
    
    if (_borderStyle & Border_Top) {
        if (!_topLineLayer) {
            _topLineLayer = [self createLineLayer];
            [self.layer addSublayer:_topLineLayer];
        }
        CGRect frame = CGRectMake(_borderLeftInset,
                                  0.f,
                                  self.frame.size.width - _borderLeftInset - _borderRightInset,
                                  _borderThick / [UIScreen mainScreen].scale);
        _topLineLayer.frame = frame;
    }
    
    if (_borderStyle & Border_Left) {
        if (!_leftLineLayer) {
            _leftLineLayer = [self createLineLayer];
            [self.layer addSublayer:_leftLineLayer];
        }
        CGRect frame = CGRectMake(0.f,
                                  _borderTopInset,
                                  _borderThick / [UIScreen mainScreen].scale,
                                  self.frame.size.height - _borderTopInset - _borderBottomInset);
        _leftLineLayer.frame = frame;
    }
    
    if (_borderStyle & Border_Right) {
        if (!_rightLineLayer) {
            _rightLineLayer = [self createLineLayer];
            [self.layer addSublayer:_rightLineLayer];
        }
        CGRect frame = CGRectMake(self.frame.size.width - 1.f / [UIScreen mainScreen].scale,
                                  _borderTopInset,
                                  _borderThick / [UIScreen mainScreen].scale,
                                  self.frame.size.height - _borderTopInset - _borderBottomInset);
        _rightLineLayer.frame = frame;
    }
    
    if (_borderStyle & Border_Bottom) {
        if (!_bottomLineLayer) {
            _bottomLineLayer = [self createLineLayer];
            [self.layer addSublayer:_bottomLineLayer];
        }
        CGRect frame = CGRectMake(_borderLeftInset,
                                  self.frame.size.height - 1.f / [UIScreen mainScreen].scale,
                                  self.frame.size.width - _borderLeftInset - _borderRightInset,
                                  _borderThick / [UIScreen mainScreen].scale);
        _bottomLineLayer.frame = frame;
    }
}



- (CALayer *)createLineLayer
{
    CALayer *lineLayer = [CALayer layer];
    UIColor *lineColor = _borderColor ? _borderColor : [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12];
    lineLayer.backgroundColor = lineColor.CGColor;
    return lineLayer;
}

@end
