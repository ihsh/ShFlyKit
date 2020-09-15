//
//  AttributeLabel.h
//  AFNetworking
//
//  Created by hsh on 2018/12/6.
//

#import <UIKit/UIKit.h>


@class AttributeConfig;
@class AttributeElements;

@protocol AttributeLabelDelegate <NSObject>
//点击的文案
-(void)clickForText:(NSString*)text;
@end



@interface AttributeLabel : UILabel
@property(nonatomic,weak)id<AttributeLabelDelegate>delegate;

//在起点-终点标识字符串之间的字符变色并可点击
-(void)setContent:(NSString*)content config:(AttributeConfig*)config;
//对应的字符变色并可点击
-(void)setContent:(NSString*)content compares:(NSArray <NSString*>*)compares config:(AttributeConfig*)config;
@end


//起始点类型的配置项
@interface AttributeConfig:NSObject
@property(nonatomic,copy)NSString *startStr;            //匹配的起点字符串
@property(nonatomic,copy)NSString *endStr;              //匹配的终点字符串
@property(nonatomic,copy)NSString *replaceStart;        //起点的替换字符串
@property(nonatomic,copy)NSString *replaceEnd;          //终点的替换字符串
@property(nonatomic,assign)BOOL containsRange;          //是否包含边缘
@property(nonatomic,strong)AttributeElements *elements;
@end


//UI界面元素
@interface AttributeElements : NSObject
@property(nonatomic,strong)UIColor *normalColor;        //正常颜色
@property(nonatomic,strong)UIFont *normalFont;          //正常字体
@property(nonatomic,strong)UIColor *hightColor;         //高亮颜色
@property(nonatomic,strong)UIFont *hightFont;           //高亮字体
@property(nonatomic,assign)BOOL bottomLine;             //是否有底部线
@end



