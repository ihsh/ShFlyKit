//
//  SHMedium.h
//  SHKit
//
//  Created by hsh on 2019/8/21.
//  Copyright © 2019 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>


//组件通信协议
@protocol SHMediumProtocol <NSObject>
@required
/**
 组件通信的默认方法
 @param parameter 传参 nullable（组件对外暴露的方法如果接受传参，要注明参数字典支持的key名称和value类型）
 @param instanceHandler 回调实例
 @param dataHandler 回调其他数据
 */
- (void)requestWithParameter:(NSDictionary* _Nullable )parameter
            instanceResponse:(void (^_Nullable)(id _Nullable instance))instanceHandler
                dataResponse:(void (^_Nullable)(id _Nullable data))dataHandler;
@end



@protocol SHMediumUrlProtocol <NSObject>
@required
/**
 URL跳转协议默认的方法，有传参需求的控制器必须实现
 
 @param parameter 参数字典
 @return 控制器实例
 */
- (instancetype _Nullable )initWithParameter:(NSDictionary* _Nullable)parameter;
@end




static NSString * _Nullable host = @"";

///组件通信类
@interface SHMedium : NSObject

/**
 组件间调用
 
 @param className 被调用的类名称
 @param parameter 传参，Nullable（组件对外暴露的方法如果接受传参，要注明参数字典支持的key名称和value类型）
 @param instanceHandler 回调实例
 @param dataHandler 回调其他数据
 @return 调用是否成功
 */
+ (BOOL)performClass:(NSString * _Nonnull)className
           parameter:(NSDictionary * _Nullable)parameter
    instanceResponse:(void (^_Nullable)(id _Nullable instance))instanceHandler
        dataResponse:(void (^_Nullable)(id _Nullable data))dataHandler;

/**
 URLScheme跳转
 格式：scheme://[host]/[path]?[params] (path最后一层作为目标控制器识别码，层级2层或以上，第一层作为tab控制器的设别码，其他的层级会被忽略)
 举例：hlldapp://huolala.cn/me/welfare?id=403
 
 @param url 调用方URL
 @param instanceHandler 回调跳转到的实例
 @return 调用是否成功
 */
+ (BOOL)performUrl:(NSURL * _Nonnull)url
  instanceResponse:(void (^_Nullable)(id _Nullable instance))instanceHandler;

@end


