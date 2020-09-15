//
//  UISpanTextField.h
//  SHKit
//
//  Created by hsh on 2019/5/24.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//设置内边距的边框
@interface UISpanTextField : UITextField
-(instancetype)initWithDx:(CGFloat)dx dy:(CGFloat)dy frame:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END
