//
//  NotificationHandler.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/13.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import UIKit
import UserNotifications
import NotificationCenter

@available(iOS 10.0, *)
class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
}
