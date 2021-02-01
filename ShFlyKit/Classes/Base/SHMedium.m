//
//  SHMedium.m
//  SHKit
//
//  Created by hsh on 2019/8/21.
//  Copyright © 2019 hsh. All rights reserved.
//

#import "SHMedium.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>


static NSString* const kMediumMethod = @"requestWithParameter:instanceResponse:dataResponse:";

static NSString* const kMediumUrlMethod = @"initWithParameter:";


@implementation SHMedium


+ (BOOL)performClass:(NSString *)className
           parameter:(NSDictionary * _Nullable)parameter
    instanceResponse:(void (^)(id))instanceHandler
        dataResponse:(void (^)(id))dataHandler{
    return [self performClass:className method:kMediumMethod parameter:parameter instanceResponse:instanceHandler dataResponse:dataHandler];
}



+ (BOOL)performUrl:(NSURL *)url instanceResponse:(void (^)(id))instanceHandler{
    BOOL performFail = NO;
    // 判断是不是我们自己的host
    if (![url.host hasSuffix:host]) {
        performFail = YES;
    };
    NSString* className = nil;
    NSString* methodName = nil;
    UINavigationController* navigationVC = nil;
    
    NSString* path = url.path;
    NSArray *pathElts = [path componentsSeparatedByString:@"/"];
    NSInteger count = pathElts.count;
    switch (count) { // 第一个元素是空串
        case 0 : case 1:
            performFail = YES;
            break;
        case 2:// 元素2个的时候，判断最后一个元素是否是Tab控制器
        {
            NSDictionary* result = [self getNaviVCForVCTag:[pathElts lastObject] setTab:YES];
            navigationVC = result[@"naviVC"];
            if ([result[@"setTabSuccess"] boolValue]) {
                return YES;
            }
        }
            break;
        default: // 元素3个或以上，判断第2个元素是否是Tab控制器
        {
            NSDictionary* result = [self getNaviVCForVCTag:pathElts[1] setTab:NO];
            navigationVC = result[@"naviVC"];
        }
            break;
    }
    if (performFail) {
        if (instanceHandler) instanceHandler(nil);
        return NO;
    }
    // 最后一个元素作为目标控制器标识
    NSString* targetVCStr = [pathElts lastObject];
    className = [self VCClassForString:targetVCStr];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *queryStr = [url query];
    for (NSString *keyValue in [queryStr componentsSeparatedByString:@"&"]) {
        NSArray *elts = [keyValue componentsSeparatedByString:@"="];
        if([elts count] != 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    methodName = params.count ? kMediumUrlMethod : nil;
    
    return [self performClass:className method:methodName parameter:params instanceResponse:^(id instance) {
        instanceHandler(instance);
        if (navigationVC && [instance isKindOfClass:[UIViewController class]]) {
            [navigationVC pushViewController:instance animated:YES];
        }
    } dataResponse:nil];
}



+ (NSString*)VCClassForString:(NSString*)str{
    return [NSString stringWithFormat:@"%@%@VC",[[str substringToIndex:1] uppercaseString],[str substringFromIndex:1]];
}

/**
 取导航控制器
 
 @param vcTag 控制器标识
 @param toSet 是否设置tabBar
 @return {setTabSuccess:是否有效的设置了TabBar,naviVC:导航控制器}
 */
+ (NSDictionary*)getNaviVCForVCTag:(NSString*)vcTag setTab:(BOOL)toSet{
    BOOL setTabSuccess = NO;
    UINavigationController* naviVC = nil;
    
    NSString* tabClass = [self VCClassForString:vcTag];
    UIViewController* rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        for (UIViewController* vc in ((UITabBarController*)rootVC).viewControllers) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                
                UIViewController* naviRootVC = [((UINavigationController*)vc).viewControllers firstObject];
                if ([naviRootVC isKindOfClass:NSClassFromString(tabClass)]) {
                    if (toSet) {
                        [((UITabBarController*)rootVC) setSelectedViewController:vc];
                        setTabSuccess = YES;
                        
                        // 如果当前顶部控制器不是要显示的控制器，就Pop回去
                        if ([((UINavigationController*)vc).topViewController isKindOfClass:NSClassFromString(tabClass)] == NO) {
                            [(UINavigationController*)vc popToRootViewControllerAnimated:YES];
                        }
                        
                    }
                    
                    naviVC = (UINavigationController*)vc;
                    break;
                }
            }
        }
        
        if (!setTabSuccess) {
            UIViewController* selectedVC = ((UITabBarController*)rootVC).selectedViewController;
            if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                naviVC = selectedVC;
            }
        }
    }else if([rootVC isKindOfClass:[UINavigationController class]]){
        naviVC = (UINavigationController*)rootVC;
    }
    
    return @{@"setTabSuccess":[NSNumber numberWithBool:setTabSuccess],@"naviVC":naviVC};
}



+ (BOOL)performClass:(NSString *)className
              method:(NSString *)methodName
           parameter:(NSDictionary *)parameter
    instanceResponse:(void (^)(id))instanceHandler
        dataResponse:(void (^)(id))dataHandler{
    
    BOOL performFail = NO;
    if (!className || [className isEqualToString:@""]) {
        performFail = YES;
    };
    
    NSObject *target = [[NSClassFromString(className) alloc] init];
    SEL action = NSSelectorFromString(methodName);
    
    if (!target) {
        performFail = YES;
    };
    
    if (!methodName) {
        if (instanceHandler) instanceHandler(target);
        if (dataHandler) dataHandler(nil);
        return YES;
    }
    
    if (![target respondsToSelector:action]){
        performFail = YES;
    };
    
    if (performFail) {
        if (instanceHandler) instanceHandler(nil);
        if (dataHandler) dataHandler(nil);
        return NO;
    }
    
    return [self performTarget:target action:action parameter:parameter instanceResponse:instanceHandler dataResponse:dataHandler];
}



+ (BOOL)performTarget:(NSObject *)target
               action:(SEL)action
            parameter:(NSDictionary *)params
     instanceResponse:(void (^)(id))instanceHandler
         dataResponse:(void (^)(id))dataHandler
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        if (instanceHandler) instanceHandler(nil);
        if (dataHandler) dataHandler(nil);
        return NO;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0
        ||strcmp(retType, @encode(NSInteger)) == 0
        ||strcmp(retType, @encode(BOOL)) == 0
        ||strcmp(retType, @encode(CGFloat)) == 0
        ||strcmp(retType, @encode(NSUInteger)) == 0) {
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
        [invocation setArgument:&params atIndex:2];
        [invocation setArgument:&instanceHandler atIndex:3];
        [invocation setArgument:&dataHandler atIndex:4];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id result = [target performSelector:action withObject:params];
        if ([NSStringFromSelector(action) isEqualToString:kMediumUrlMethod]) {
            instanceHandler(result);
        }
#pragma clang diagnostic pop
    }
    return YES;
}



@end
