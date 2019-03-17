//
//  AppDelegate.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()
        registerNotificationActions()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
// MARK: - CORE DATA STACK
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RemindMe")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

// MARK: - CORE DATA SAVING SUPPORT
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
//MARK: - LOCAL NOTIFICATION SERVICES CONFIGURATION
    // Register for notification services
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
        }
    }

    func registerNotificationActions () {
        print ("Registering Notification Actions")
        // Define the custom actions.
        let snoozeAction = UNNotificationAction(identifier: "SNOOZE_ACTION", title: "Snooze", options: UNNotificationActionOptions(rawValue: 0))
        let doneAction = UNNotificationAction(identifier: "DONE_ACTION", title: "Done", options: UNNotificationActionOptions(rawValue: 0))

        // Define the notification type
        let meetingInviteCategory = UNNotificationCategory(identifier: "REMINDER_ACTIONS", actions: [snoozeAction, doneAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        // Register the notification type.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Get the meeting ID from the original notification.
//        let userInfo = response.notification.request.content.userInfo
//        let meetingID = userInfo["MEETING_ID"] as! String
//        let userID = userInfo["USER_ID"] as! String
        
        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "SNOOZE_ACTION":
            //sharedMeetingManager.acceptMeeting(user: userID,meetingID: meetingID)
            print ("Snooze Action selected")
            break
            
        case "DONE_ACTION":
            print ("Done Action selected")
//            // Get the reminder ID from the original notification.
//            let userInfo = response.notification.request.content.userInfo
//
//            let reminderID = userInfo["REMINDER_ID"] as! String
//
//            // Lookup the chore by notification ID
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            var choresArray = [Chore]()
//            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
//            request.predicate = NSPredicate(format: "tr_reminderID1 CONTAINS[cd] %@", reminderID)
//
//            do {
//                choresArray = try context.fetch(request)
//            } catch {
//                print("Error loading item array, \(error)")
//            }
//            print ("Chores extracted from db \(choresArray.count) \(choresArray[0].ch_title)")
//
//            if choresArray.count == 1 {
//                let reminderTimeArray : [String] = choresArray[0].sh_reminderTimes! as! [String]
//                let reminderTimePassed = reminderTimeArray[0]
//
//                // Remove current reminders (if any)
//                Scheduler().removeNotification(reminderID: reminderID)
//
//                // Reschedule next notification
//                let dc = Scheduler().scheduleDate(reminderTimePassed: reminderTimePassed, startDate: choresArray[0].sh_startDate!, endDate: choresArray[0].sh_endDate!, frequency: choresArray[0].sh_frequency!)
//                let (notificationDate, notificationID) = Scheduler().scheduleNotification(dateComponents: dc, title: "Your reminder", body: choresArray[0].ch_title!)
//
//                print ("Next notification is set for: \(notificationDate) and ID is \(notificationID)")
//
//                //Update the reminder ID and next reminder date
//                do {
//                    let objectUpdate = choresArray[0] as NSManagedObject
//                    objectUpdate.setValue(notificationID, forKey: "tr_reminderID1")
//                    objectUpdate.setValue(notificationDate, forKey: "tr_nextReminder1")
//                } catch {
//                    print ("Error updating record \(error)")
//                }
//
//                //func save items
//                do {
//                    try context.save()
//                } catch {
//                    print("Error saving to Core Data, \(error)")
//                }
//            }
//            break
//
//            // Handle other actions…
//
        default:
           print ("Another action taken")
            break
        }
        
        // Always call the completion handler when done.
        completionHandler()

        
    }
}

