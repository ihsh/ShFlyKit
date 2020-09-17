//
//  SHLabelPath.m
//  SHLabel
//
//  Created by hsh on 19/8/22.
//  Copyright © 2019年 hsh. All rights reserved.
//


#import "SHLabelPath.h"
#import "SHPath.h"


@interface SHLabelPath () {
    SHPath* _pathCpp;
}
@end


@implementation SHLabelPath


-(instancetype)init {
    self = [super init];
    if (self) {
        _pathCpp = new SHPointPath({0.0, 0.0});
    }
    return self;
}


+(instancetype)pathForBeginPoint:(CGPoint)point {
    SHLabelPath *path = [[SHLabelPath alloc] init];
    path->_pathCpp->setEndPoint({point.x, point.y});
    return path;
}


-(void)dealloc {
    if (_pathCpp != nil) {
        delete _pathCpp;
    }
}


-(void)moveBeginPoint:(CGPoint)point {
    _pathCpp->setEndPoint({point.x, point.y});
}


-(void)addLineToPoint:(CGPoint)point {
    _pathCpp->appendPath(new SHLinePath({point.x, point.y}));
}


-(void)addArcWithCentrePoint:(CGPoint)centrePoint angle:(CGFloat)angle {
    _pathCpp->appendPath(new SHRoundPath({centrePoint.x, centrePoint.y}, angle));
}


-(void)addCurveToPoint:(CGPoint)point anchorPoint:(CGPoint)anchorPoint {
    _pathCpp->appendPath(new SHBezierPath({anchorPoint.x, anchorPoint.y}, {point.x, point.y}));
}


-(void)addCustomPoint:(NSArray *)customPoint {
    std::vector<SHPoint> pointVector(customPoint.count);
    for (int i = 0; i < customPoint.count; i++) {
        CGPoint point = ((NSValue *)customPoint[i]).CGPointValue;
        pointVector[i] = {point.x, point.y};
    }
    _pathCpp->appendPath(new SHCustomPath(&pointVector));
}


-(CGFloat)getLength {
    return _pathCpp->getLength();
}


-(NSArray<NSValue*> *)getPosTan:(CGFloat)precision {
    std::vector<SHPoint> *outBuffer = new std::vector<SHPoint>();
    NSMutableArray *array = [NSMutableArray array];
    _pathCpp->getPosTan(precision, outBuffer);
    for (auto it = outBuffer->begin(); it != outBuffer->end(); ++it) {
        CGPoint point = {static_cast<CGFloat>((*it).x), static_cast<CGFloat>((*it).y)};
        [array addObject:[NSValue valueWithCGPoint:point]];
    }
    delete outBuffer;
    return array;
}


-(void)setNeedsUpdate {
    _pathCpp->setNeedsUpdate();
}


-(SHLabelPath *)clone {
    SHLabelPath *clone = [[SHLabelPath alloc] init];
    clone->_pathCpp = _pathCpp->clone();
    return clone;
}


@end
