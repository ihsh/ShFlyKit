//
//  BMKClusterObject.m
//  ShFlyKit
//
//  Created by mac on 2020/10/14.
//

#import "BMKClusterObject.h"


@implementation BMKClusterAnno

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
-(NSUInteger)hash:(BMKClusterAnno*)anno{
    NSString *tohash = [NSString stringWithFormat:@"%.5f%.5f%ld",anno.coordinate.latitude,anno.coordinate.longitude,anno.count];
    return tohash.hash;
}


@end








@implementation BMKClusterModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.location = CLLocationCoordinate2DMake(0, 0);
    }
    return self;
}
@end
