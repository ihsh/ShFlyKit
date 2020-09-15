//
//  BMKCoordinateQuadTree.m
//  SHKit
//
//  Created by hsh on 2019/1/17.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "BMKCoordinateQuadTree.h"
#import "SHKit-Swift.h"


QuadTreeNodeData BMKQuadTreeNodeDataForAMapPOI(BMKClusterModel* poi){
    return QuadTreeNodeDataMake(poi.location.latitude, poi.location.longitude, (__bridge_retained void *)(poi));
}


BoundingBox BMKBoundingBoxForMapRect(BMKMapRect mapRect){
    CLLocationCoordinate2D topLeft = BMKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = BMKCoordinateForMapPoint(BMKMapPointMake(BMKMapRectGetMaxX(mapRect), BMKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return BoundingBoxMake(minLat, minLon, maxLat, maxLon);
}


float BMKCellSizeForZoomLevel(double zoomLevel){
    /*zoomLevel越大，cellSize越小. */
    if (zoomLevel < 13.0){
        return 128;
    }else if (zoomLevel <15.0){
        return 64;
    }else if (zoomLevel <18.0){
        return 32;
    }else if (zoomLevel < 20.0){
        return 16;
    }
    return 64;
}


BoundingBox BMKQuadTreeNodeDataArrayForPOIs(QuadTreeNodeData *dataArray, NSArray * pois){
    CLLocationDegrees minX = ((BMKClusterModel *)pois[0]).location.latitude;
    CLLocationDegrees maxX = ((BMKClusterModel *)pois[0]).location.latitude;
    
    CLLocationDegrees minY = ((BMKClusterModel *)pois[0]).location.longitude;
    CLLocationDegrees maxY = ((BMKClusterModel *)pois[0]).location.longitude;
    
    for (NSInteger i = 0; i < [pois count]; i++){
        dataArray[i] = BMKQuadTreeNodeDataForAMapPOI(pois[i]);
        if (dataArray[i].x < minX){
            minX = dataArray[i].x;
        }
        if (dataArray[i].x > maxX){
            maxX = dataArray[i].x;
        }
        if (dataArray[i].y < minY){
            minY = dataArray[i].y;
        }
        if (dataArray[i].y > maxY){
            maxY = dataArray[i].y;
        }
    }
    return BoundingBoxMake(minX, minY, maxX, maxY);
}




@implementation BMKCoordinateQuadTree


#pragma mark Utility
- (NSArray *)getAnnotationsWithoutClusteredInMapRect:(BMKMapRect)rect{
    __block NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    QuadTreeGatherDataInRange(self.root, BMKBoundingBoxForMapRect(rect), ^(QuadTreeNodeData data) {
        BMKClusterModel *aPoi = (__bridge BMKClusterModel *)data.data;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(aPoi.location.latitude, aPoi.location.longitude);
        BMKClusterAnno *annotation = [[BMKClusterAnno alloc] initWithCoordinate:coordinate count:1];
        annotation.pois = @[aPoi].mutableCopy;
        
        [clusteredAnnotations addObject:annotation];
    });
    return clusteredAnnotations;
}


- (NSArray *)clusteredAnnotationsWithinMapRect:(BMKMapRect)rect withZoomScale:(double)zoomScale andZoomLevel:(double)zoomLevel{
    //满足特定zoomLevel时不产生聚合效果(这里取地图的最大zoomLevel，效果为地图达到最大zoomLevel时，annotation全部展开，无聚合效果)
    if (zoomLevel >= 19.0){
        return [self getAnnotationsWithoutClusteredInMapRect:rect];
    }
    
    double CellSize = BMKCellSizeForZoomLevel(zoomLevel);
    double scaleFactor = zoomScale / CellSize;
    
    NSInteger minX = floor(BMKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(BMKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(BMKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(BMKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++){
        for (NSInteger y = minY; y <= maxY; y++){
            BMKMapRect mapRect = BMKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            __block double totalX = 0;
            __block double totalY = 0;
            __block int     count = 0;
            NSMutableArray *pois = [[NSMutableArray alloc] init];
            /* 查询区域内数据的个数. */
            QuadTreeGatherDataInRange(self.root, BMKBoundingBoxForMapRect(mapRect), ^(QuadTreeNodeData data)
                                      {
                                          totalX += data.x;
                                          totalY += data.y;
                                          count++;
                                          [pois addObject:(__bridge BMKClusterModel *)data.data];
                                      });
            /* 若区域内仅有一个数据. */
            if (count == 1){
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                BMKClusterAnno *annotation = [[BMKClusterAnno alloc] initWithCoordinate:coordinate count:count];
                annotation.pois = pois;
                [clusteredAnnotations addObject:annotation];
            }
            /* 若区域内有多个数据 按数据的中心位置画点. */
            if (count > 1){
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                BMKClusterAnno *annotation = [[BMKClusterAnno alloc] initWithCoordinate:coordinate count:count];
                annotation.pois  = pois;
                [clusteredAnnotations addObject:annotation];
            }
        }
    }
    return [NSArray arrayWithArray:clusteredAnnotations];
}



#pragma mark - cluster by distance
///按照annotation.coordinate之间的距离进行聚合
- (NSArray<BMKClusterAnno *> *)clusteredAnnotationsWithinMapRect:(BMKMapRect)rect
                                                       withDistance:(double)distance {
    __block NSMutableArray<BMKClusterModel *> *allAnnotations = [[NSMutableArray alloc] init];
    QuadTreeGatherDataInRange(self.root, BMKBoundingBoxForMapRect(rect), ^(QuadTreeNodeData data) {
        [allAnnotations addObject:(__bridge BMKClusterModel *)data.data];
    });
    
    NSMutableArray<BMKClusterAnno *> *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (BMKClusterModel *aAnnotation in allAnnotations) {
        CLLocationCoordinate2D resultCoor = CLLocationCoordinate2DMake(aAnnotation.location.latitude, aAnnotation.location.longitude);
        
        BMKClusterAnno *cluster = [self getClusterForAnnotation:aAnnotation inClusteredAnnotations:clusteredAnnotations withDistance:distance];
        if (cluster == nil) {
            BMKClusterAnno *aResult = [[BMKClusterAnno alloc] initWithCoordinate:resultCoor count:1];
            aResult.pois = @[aAnnotation].mutableCopy;
            
            [clusteredAnnotations addObject:aResult];
        } else {
            double totalX = cluster.coordinate.latitude * cluster.count + resultCoor.latitude;
            double totalY = cluster.coordinate.longitude * cluster.count + resultCoor.longitude;
            NSInteger totalCount = cluster.count + 1;
            
            cluster.count = totalCount;
            cluster.coordinate = CLLocationCoordinate2DMake(totalX / totalCount, totalY / totalCount);
            [cluster.pois addObject:aAnnotation];
        }
    }
    return clusteredAnnotations;
}



- (BMKClusterAnno *)getClusterForAnnotation:(BMKClusterModel *)annotation
                        inClusteredAnnotations:(NSArray<BMKClusterAnno *> *)clusteredAnnotations withDistance:(double)distance {
    
    if ([clusteredAnnotations count] <= 0 || annotation == nil) {
        return nil;
    }
    CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:annotation.location.latitude longitude:annotation.location.longitude];
    for (BMKClusterAnno *aCluster in clusteredAnnotations) {
        CLLocation *clusterLocation = [[CLLocation alloc] initWithLatitude:aCluster.coordinate.latitude longitude:aCluster.coordinate.longitude];
        double dis = [clusterLocation distanceFromLocation:annotationLocation];
        if (dis < distance) {
            return aCluster;
        }
    }
    return nil;
}



#pragma mark Initilization
- (void)buildTreeWithPOIs:(NSArray *)pois{
    QuadTreeNodeData *dataArray = malloc(sizeof(QuadTreeNodeData) * [pois count]);
    BoundingBox maxBounding = BMKQuadTreeNodeDataArrayForPOIs(dataArray, pois);
    /*若已有四叉树，清空.*/
    [self clean];
    /*建立四叉树索引. */
    self.root = QuadTreeBuildWithData(dataArray, [pois count], maxBounding, 4);
    free(dataArray);
}


#pragma mark Life Cycle
- (void)clean{
    if (self.root){
        FreeQuadTreeNode(self.root);
    }
}



@end
