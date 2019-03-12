//
//  Scheduler.swift
//  RemindMe
//
//  Created by Kate on 9/3/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import UserNotifications

class Scheduler {
    
    func scheduleNotification(dateComponents:DateComponents, title:String, body:String, reminderID: String?="") -> (Date, String) {
        var returnDate : Date = Date.init()
        var returnTriggerID : String = ""
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        //1. Verify that permission for notifications has been granted
        notificationCenter.getNotificationSettings { (settings) in
        // Do not schedule notifications if not authorized.
        guard settings.authorizationStatus == .authorized else {
            print ("Permission not granted")
            return}
        }
        
        //2. Remove existing notification if it was passed
        if reminderID != "" {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderID!])
        }
        
        //2. Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        returnDate = trigger.nextTriggerDate()!
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
        print("Return Date \(returnDate)")
            
        //4. Create the request
        let uuidString = UUID().uuidString
        returnTriggerID = uuidString as String
        print("Return Trigger ID \(returnTriggerID)")
        
            //4b. Set content of notification
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.userInfo = ["REMINDER_ID" : returnTriggerID]
            content.categoryIdentifier = "REMINDER_ACTIONS"
//            let attachment = try! UNNotificationAttachment(identifier: "image", url: url!, options: [:])
//            content.attachments = [attachment]
//        
//            content.attachments = UIImage(named: "binicon.png")
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
        //5. Schedule the request with the system.
        notificationCenter.add(request) { (error) in
                    if error != nil {
                        print ("Error adding request")
                    }
            }
        
        notificationCenter.getPendingNotificationRequests { (notifications) in
            print("Notification Count: \(notifications.count)")
        }
        
        return (returnDate, returnTriggerID)
    }
    
    func scheduleDate (reminderTimeArray : [String], startDate : Date, endDate : Date, frequency : String, weekDaysArray : [Int]) -> DateComponents {
        //1. Initialise variables and formatters
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        let todayDate : Date = Date.init() //Initialise today's date
        let nowTimeString = timeFormatter.string(from: todayDate)
        
        let todayComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .weekday, .weekOfYear], from: todayDate)
        let startDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .weekday, .weekOfYear], from: startDate)
        
        var reminderTime = timeFormatter.date(from: reminderTimeArray[0]) // set Reminder Time
        var reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        var dayIncrement : Int = 0
        
        
        //2. Check that schedule is not past the endDate
        if todayDate > endDate {
            print("schedule ended \(dateComponents)")
            return dateComponents
            
        } else {
            
            //2. Determine Schedule based on frequency
            switch frequency {
            case "daily":
                if todayDate < startDate {
                    // assign start Date for the trigger
                    dateComponents.day = startDateComponents.day!
                    dateComponents.month = startDateComponents.month!
                    dateComponents.year = startDateComponents.year!
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                } else {
                    // find next reminder time by comparing with current time
                    for tt in reminderTimeArray {
                        if tt > nowTimeString {
                            reminderTime = timeFormatter.date(from: tt)
                            reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
                            dayIncrement = 0
                            break
                        } else {
                            dayIncrement = 1
                        }
                    }
                    // assign date components for the trigger
                    dateComponents.day = todayComponents.day!+dayIncrement
                    dateComponents.month = todayComponents.month!
                    dateComponents.year = todayComponents.year!
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                }
                
                
            case "weekly":
                if todayDate < startDate {
                    // Find next nominated weekday from start date
                    if startDateComponents.weekday! > weekDaysArray[0] {
                        dayIncrement = (7 - startDateComponents.weekday!+weekDaysArray[0])
                    } else if startDateComponents.weekday! < weekDaysArray[0] {
                        dayIncrement = (weekDaysArray[0] - startDateComponents.weekday!)
                    }
                    
                    // assign date components for the trigger
                    dateComponents.day = startDateComponents.day!+dayIncrement
                    dateComponents.month = startDateComponents.month!
                    dateComponents.year = startDateComponents.year!
                    dateComponents.weekday = weekDaysArray[0]
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                    
                } else {
                    // the reminder is due today need to find next reminder time
                    if todayComponents.weekday! == weekDaysArray[0] {
                        for tt in reminderTimeArray {
                            if tt > nowTimeString {
                                reminderTime = timeFormatter.date(from: tt)
                                reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
                                break
                            }
                        }
                    }
                    // assign date components for the trigger
                    dateComponents.weekday = weekDaysArray[0]
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                }
                
                
                
            case "fortnightly":
                if todayDate < startDate {
                    // Find next weekday interval from start date
                    if startDateComponents.weekday! > weekDaysArray[0] {
                        dayIncrement = (7 - startDateComponents.weekday!+weekDaysArray[0])
                    } else if startDateComponents.weekday! < weekDaysArray[0] {
                        dayIncrement = (weekDaysArray[0] - startDateComponents.weekday!)
                    }
                    
                    // assign date components for the trigger
                    dateComponents.day = startDateComponents.day!+dayIncrement
                    dateComponents.month = startDateComponents.month!
                    dateComponents.year = startDateComponents.year!
                    dateComponents.weekday = weekDaysArray[0]
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                    
                } else {
                    // the reminder is due today need to find next reminder time
                    if startDateComponents.weekday! == weekDaysArray[0] {
                        // find next reminder time for today
                        for tt in reminderTimeArray {
                            if tt > nowTimeString {
                                reminderTime = timeFormatter.date(from: tt)
                                reminderComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
                                break
                            }
                        }
                    }
                    
                    let result : Int = Int(startDateComponents.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
                    let result2 : Int = Int(todayComponents.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
                    if result != result2 {
                        // assign date components for the trigger
                        dateComponents.weekday = weekDaysArray[0]
                        dateComponents.weekOfYear = todayComponents.weekOfYear!+1
                        dateComponents.hour = reminderComponents.hour!
                        dateComponents.minute = reminderComponents.minute!
                        
                    } else {
                        if todayComponents.weekday! > weekDaysArray[0] {
                            // assign date components for the trigger
                            dateComponents.weekday = weekDaysArray[0]
                            dateComponents.weekOfYear = todayComponents.weekOfYear!+2
                            dateComponents.hour = reminderComponents.hour!
                            dateComponents.minute = reminderComponents.minute!
                        } else {
                            // assign date components for the trigger
                            dateComponents.weekday = weekDaysArray[0]
                            dateComponents.weekOfYear = todayComponents.weekOfYear!
                            dateComponents.hour = reminderComponents.hour!
                            dateComponents.minute = reminderComponents.minute!
                        }
                    }
                }
                
            default:
                print ("Error")
            }
            
        }
        
        print("schedule determined as \(dateComponents)")
        return dateComponents
        
    }

}
