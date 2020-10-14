//
//  BMKCoordinateQuadTree.h
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMKBaseComponent.h"
#import "BMKClusterObject.h"
#import "QuadTree.h"



@interface BMKCoordinateQuadTree : NSObject
@property (nonatomic, assign) QuadTreeNode * root;


/// 这里对poi对象的内存管理被四叉树接管了，当clean的时候会释放，外部有引用poi的地方必须再clean前清理。
- (void)buildTreeWithPOIs:(NSArray *)pois;
- (void)clean;

- (NSArray *)clusteredAnnotationsWithinMapRect:(BMKMapRect)rect withZoomScale:(double)zoomScale andZoomLevel:(double)zoomLevel;
- (NSArray *)clusteredAnnotationsWithinMapRect:(BMKMapRect)rect withDistance:(double)distance;
@end


