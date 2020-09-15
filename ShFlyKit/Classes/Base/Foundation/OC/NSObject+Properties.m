//
//  NSObject+Properties.m
//  SHKit
//
//  Created by hsh on 2019/5/28.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "NSObject+Properties.h"
#import <objc/runtime.h>

@implementation NSObject (Properties)


- (NSDictionary*)propertiesValues{
    // 获取属性列表
    NSArray *properties = [self propertyNames:[self class]];
    // 根据属性列表获取属性值
    return [self propertiesAndValuesDictionary:self properties:properties];
}


#pragma private - 私有方法
// 获取一个类的属性名字列表
- (NSArray*)propertyNames:(Class)class{
    NSMutableArray  *propertyNames = [[NSMutableArray alloc] init];
    unsigned int     propertyCount = 0;
    objc_property_t *properties    = class_copyPropertyList(class, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i){
        objc_property_t  property = properties[i];
        const char      *name     = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}



// 根据属性数组获取该属性的值
- (NSDictionary*)propertiesAndValuesDictionary:(id)obj properties:(NSArray *)properties{
    NSMutableDictionary *propertiesValuesDic = [NSMutableDictionary dictionary];
    
    for (NSString *property in properties){
        SEL getSel = NSSelectorFromString(property);
        
        if ([obj respondsToSelector:getSel]){
            NSMethodSignature  *signature  = nil;
            signature                      = [obj methodSignatureForSelector:getSel];
            NSInvocation       *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:obj];
            [invocation setSelector:getSel];
            NSObject * __unsafe_unretained valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            //assign to @"" string
            if (valueObj == nil){
                valueObj = @"";
            }
            propertiesValuesDic[property] = valueObj;
        }
    }
    return propertiesValuesDic;
}


@end
