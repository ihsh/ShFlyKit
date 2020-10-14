//
//  BMKClusterObject.h
//  ShFlyKit
//
//  Created by mac on 2020/10/14.
//

#import <Foundation/Foundation.h>
#import "BMKAnnotation.h"

///点聚合annotation类
@interface BMKClusterAnno : NSObject<BMKAnnotation>
///对应坐标点
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
///对应点数
@property(nonatomic,assign)NSInteger count;
///对应位置数组
@property(nonatomic,strong)NSMutableArray *pois;


-(instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;

@end



///点集合数据模型
@interface BMKClusterModel : NSObject
@property(nonatomic,strong)NSString *uid;               //编号
@property(nonatomic,strong)NSString *name;              //名称
@property(nonatomic,strong)NSString *address;           //地址
@property(nonatomic,strong)NSString *tel;               //电话号码
@property(nonatomic,assign)CLLocationCoordinate2D location; //地理位置
@property(nonatomic,strong)NSString *email;             //电子邮件
@property(nonatomic,strong)NSString *website;           //网站
@property(nonatomic,strong)NSString *province;          //省
@property(nonatomic,strong)NSString *pcode;             //省code
@property(nonatomic,strong)NSString *city;              //城市
@property(nonatomic,strong)NSString *cityCode;          //城市编码
@property(nonatomic,strong)NSString *district;          //区域名称
@property(nonatomic,strong)NSString *adcode;            //区域编码
@property(nonatomic,strong)NSArray *images;             //图片数组  -->优先
@property(nonatomic,strong)NSArray *imageUlrs;          //图片地址
@end
