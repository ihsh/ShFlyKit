//
//  UISpanTextField.m
//  SHKit
//
//  Created by hsh on 2019/5/24.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "UISpanTextField.h"

@interface UISpanTextField ()
@property(nonatomic,assign)CGFloat dx;
@property(nonatomic,assign)CGFloat dy;
@end

@implementation UISpanTextField

-(instancetype)initWithDx:(CGFloat)dx dy:(CGFloat)dy frame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.dx = dx;
        self.dy = dy;
    }
    return self;
}


-(CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, _dx, _dy);
}


-(CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, _dx, _dy);
}


@end
