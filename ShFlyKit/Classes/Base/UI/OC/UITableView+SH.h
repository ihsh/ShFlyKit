//
//  UITableView+SH.h
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (SH)

+(instancetype)initWithStyle:(UITableViewStyle)style
                  dataSource:(id<UITableViewDataSource>)dataSource
                    delegate:(id<UITableViewDelegate>)delegate
                   rowHeight:(CGFloat)rowHeight
               separateStyle:(UITableViewCellSeparatorStyle)cellStyle
                   superView:(nullable UIView*)superView;
@end

NS_ASSUME_NONNULL_END
