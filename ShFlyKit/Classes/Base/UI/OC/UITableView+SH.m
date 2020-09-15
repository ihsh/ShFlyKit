//
//  UITableView+SH.m
//  SHKit
//
//  Created by hsh on 2018/11/1.
//  Copyright © 2018 hsh. All rights reserved.
//

#import "UITableView+SH.h"

@implementation UITableView (SH)

+(instancetype)initWithStyle:(UITableViewStyle )style
                  dataSource:(id<UITableViewDataSource>)dataSource
                    delegate:(id<UITableViewDelegate>)delegate
                   rowHeight:(CGFloat)rowHeight
               separateStyle:(UITableViewCellSeparatorStyle )cellStyle
                   superView:(UIView *)superView{
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectZero style:style];
    table.delegate = delegate;
    table.dataSource = dataSource;
    table.rowHeight = rowHeight;
    table.separatorStyle = cellStyle;
    if (superView) {
        [superView addSubview:table];
    }
    return table;
}
@end
