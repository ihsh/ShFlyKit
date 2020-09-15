//
//  Keychain.h
//  SHKit
//
//  Created by hsh on 2018/10/25.
//  Copyright © 2018 hsh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SHKeychain : NSObject


//保存键值对
+ (void)save:(NSString *)service data:(id)data;


//通过键获取值
+ (id)load:(NSString *)service;


//删除键对应值
+ (void)deleteKeyData:(NSString *)service;


@end


