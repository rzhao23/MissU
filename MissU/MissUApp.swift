//
//  MissUApp.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-22.
//

import SwiftUI
import FirebaseCore

@main
struct MissUApp: App {
    
    let notificationDelegate = NotificationDelegate()
    
    init(){
        UNUserNotificationCenter.current().delegate = notificationDelegate
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/* enable notification even in the app */
/* by ios default, app will not notify in the app */
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

