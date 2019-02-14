//
//  AppDelegate.swift
//  Agon
//
//  Created by Gabriela Villalobos on 02.11.18.
//  Copyright © 2018 UNIL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?
    let healthKitSetupAssistant = HealthKitSetupAssistant()

    // MARK: - Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initializes in Realm the Last Sync Timestamp -> This determines the starting day of the baseline
        SynchronizationModel().initializeLastDaySync(year: 2018, month: 12, day: 1, hour: 0, minute: 0, second: 0)
        
        // Override point for customization after application launch.
        //print("application did finish launching with options")
        healthKitSetupAssistant.requestAccessWithCompletion(){ success, error in
            if success{
                print("Healthkit access requested from App Delegate") // Note: Access Requested not necessarily granted
            }
            else{
                print("Error requesting access to HealthKit: \(error)")
            }
        }

        return true
        
//        healthKitSetupAssistant.authorizeHealthKit { (authorized , error) in
//            guard authorized else {
//
//            let baseMessage = "HealthKit Authorization Failed from App Delegate"
//
//            if let error = error {
//                print("\(baseMessage). Reason: \(error.localizedDescription)")
//            } else {
//                print(baseMessage)
//            }
//            return
//            }
//
//            print("HealthKit Successfully Authorized from App Delegate.")
//
//        // Setting the observer query on the app delegate
//        let readDataTypes = self.healthKitSetupAssistant.dataTypesToRead()
//            self.healthKitSetupAssistant.setUpBackgroundDeliveryForDataTypes(types: readDataTypes, completion: {steps in
//
//            })
//
//        }
//
//        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
