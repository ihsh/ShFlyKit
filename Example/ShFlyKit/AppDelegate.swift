//
//  AppDelegate.swift
//  ShFlyKit
//
//  Created by 957929697@qq.com on 09/15/2020.
//  Copyright (c) 2020 957929697@qq.com. All rights reserved.
//

import UIKit
import ShFlyKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,ScreenSnapToolDelegate {
    
    func DidTakeScreenshot(image: UIImage, window: UIWindow) {
        
    }

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //集成Bugly
        BuglyReporter.initBugLyWithAppkey(appKey: "3864583fc1");
        //高德地图
        AMapServices.shared()?.apiKey = "f9830ba96e270eabbfbceb766177c61a";
//        //百度地图
//        BMKService.shareInstance.registerBaidu(key: "1ARVCXTsUzOl2uSXpNoepa4G5n8ZYZdl")
//        //地图
//        BMKService.customMapStyle(fileName: "custom_map_config");
        ScreenSnapTool.shared.registerSnapNotifa(delegate: self);

        self.window = UIWindow(frame: UIScreen.main.bounds);
        self.window?.makeKeyAndVisible();
        let main:MainTabVC = MainTabVC();
        let nav:UINavigationController = UINavigationController(rootViewController: main);
        self.window?.rootViewController = nav;
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

