//
//  AMapClusterObject.m
//  ShFlyKit
//
//  Created by mac on 2020/10/14.
//

#import "AMapClusterObject.h"



@implementation ClusterAnnotation


-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count{
    self = [super init];
    self.coordinate = coordinate;
    self.count = count;
    self.pois = [NSMutableArray array];
    return self;
}


///是否相等
- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if ([[other class] isEqual:[self class]]) {
        return [self hash:other] == [self hash:self];
    } else {
        return NO;
    }
}


///自定义HASH规则
-(NSUInteger)hash:(ClusterAnnotation*)anno{
    NSString *tohash = [NSString stringWithFormat:@"%.5f%.5f%ld",anno.coordinate.latitude,anno.coordinate.longitude,anno.count];
    return tohash.hash;
}


@end




@implementation AMapClusterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.location = CLLocationCoordinate2DMake(0, 0);
    }
    return self;
}


+(NSArray*)convertAMapPoiToCustomModel:(NSArray*)pois{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (AMapPOI *poi in pois) {
        AMapClusterModel *model = [[AMapClusterModel alloc]init];
        model.uid = poi.uid;
        model.name = poi.name;
        model.address = poi.address;
        model.tel = poi.tel;
        model.location = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        model.email = poi.email;
        model.website = poi.website;
        model.province = poi.province;
        model.pcode = poi.pcode;
        model.city = poi.city;
        model.cityCode = poi.citycode;
        model.district = poi.district;
        model.adcode = poi.adcode;
        [tmpArray addObject:model];
    }
    return tmpArray;
}



@end
