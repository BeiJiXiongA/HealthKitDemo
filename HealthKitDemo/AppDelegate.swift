//
//  AppDelegate.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/9.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import NotificationCenter
import UserNotifications

@available(iOS 10.0, *)
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

//    class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
//        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//            completionHandler([.alert,.sound])
//        }
//    }
//    
//    let notificationHandler = NotificationHandler()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                if granted {
                    // 用户允许进行通知
                }
            }
            
            UNUserNotificationCenter.current().delegate = self
        }else if #available(iOS 8.0, *){
            let myTypes:UIUserNotificationType = .alert
            let settings:UIUserNotificationSettings = UIUserNotificationSettings.init(types: myTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }else {
            
//            UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
//            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
        }
        
        
//        let controller:ViewController = ViewController()
//        let controller:BirthOfDateViewController = BirthOfDateViewController()
        let controller:CalorieViewController = CalorieViewController()
        let nav:UINavigationController = UINavigationController.init(rootViewController: controller)
        self.window?.rootViewController = nav
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        self.testNotificaiton()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        self.testNotificaiton()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func testNotificaiton() {
        //1. 创建通知内容
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            
            content.title = "Time Interval Notification"
            
            content.body = "My first notification"
            
            //2. 创建发送触发
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                            repeats: false)
            //3. 发送请求标识符
            
            let requestIdentifier = "com.onevcat.usernotification.myFirstNotification"
            
            //4. 创建一个发送请求
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            //将请求添加到发送中心
            
            UNUserNotificationCenter.current().add(request)
            { error in
                
                if error == nil {
                    
                    print("TimeInterval Notification scheduled:\(requestIdentifier)")
                    
                }
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

