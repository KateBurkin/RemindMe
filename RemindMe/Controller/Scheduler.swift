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
    
    func removeNotification (reminderID : String){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderID])
    }
    
    func scheduleNotification(dateComponents:DateComponents, title:String, body:String) -> (Date, String) {
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
        
        //2. Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        returnDate = trigger.nextTriggerDate()!
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
            
        //4. Create the request
        let uuidString = UUID().uuidString
        returnTriggerID = uuidString as String
        
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
        return (returnDate, returnTriggerID)
    }
    
    
    
    func scheduleDate (reminderTimePassed : String, startDate : Date, endDate : Date, frequency : String) -> DateComponents {
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
        //let weekDay : Int = startDateComponents.weekday!
        let reminderTime = timeFormatter.date(from: reminderTimePassed) // set Reminder Time
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
                      if reminderTimePassed > nowTimeString {
                            dayIncrement = 0
                      } else {
                          dayIncrement = 1
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
                    // assign date components for the trigger
                    dateComponents.day = startDateComponents.day!
                    dateComponents.month = startDateComponents.month!
                    dateComponents.year = startDateComponents.year!
                    dateComponents.weekday = startDateComponents.weekday!
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                    
//                } else if todayComponents.weekday! == startDateComponents.weekday! {
//                    if reminderTimePassed > nowTimeString {
//                        dayIncrement = 0
//                    } else {
//                        dayIncrement = 7
//                    }
//                    // determine if reminder should be scheduled for this week or next week
//                    dateComponents.day = todayComponents.day!+dayIncrement
//                    dateComponents.month = todayComponents.month!
//                    dateComponents.year = todayComponents.year!
//                    dateComponents.hour = reminderComponents.hour!
//                    dateComponents.minute = reminderComponents.minute!
                } else {
                    // assign for next weekday at the selected time
                    dateComponents.weekday = startDateComponents.weekday!
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                }
                
                
                
            case "fortnightly":
                if todayDate < startDate {
                    // schedule reminder for the start date
                    dateComponents.day = startDateComponents.day!
                    dateComponents.month = startDateComponents.month!
                    dateComponents.year = startDateComponents.year!
                    dateComponents.weekday = startDateComponents.weekday
                    dateComponents.hour = reminderComponents.hour!
                    dateComponents.minute = reminderComponents.minute!
                } else {

                    // determine if notification is due this week or next week
                    let result : Int = Int(startDateComponents.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
                    let result2 : Int = Int(todayComponents.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
                    if result != result2 {
                        // notification due next week
                        dateComponents.weekday = startDateComponents.weekday!
                        dateComponents.weekOfYear = todayComponents.weekOfYear!+1
                        dateComponents.hour = reminderComponents.hour!
                        dateComponents.minute = reminderComponents.minute!
                        
                    } else { // notification due next fortnight
                        if todayComponents.weekday! < startDateComponents.weekday! {
                            // trigger due later this week
                            dateComponents.weekday = startDateComponents.weekday!
                            dateComponents.weekOfYear = todayComponents.weekOfYear!
                            dateComponents.hour = reminderComponents.hour!
                            dateComponents.minute = reminderComponents.minute!
                        } else if todayComponents.weekday! == startDateComponents.weekday! && reminderTimePassed < nowTimeString {
                            // trigger due later today
                            dateComponents.weekday = startDateComponents.weekday!
                            dateComponents.weekOfYear = todayComponents.weekOfYear!
                            dateComponents.hour = reminderComponents.hour!
                            dateComponents.minute = reminderComponents.minute!
                        } else {
                            // trigger due next fortnight
                            dateComponents.weekday = startDateComponents.weekday!
                            dateComponents.weekOfYear = todayComponents.weekOfYear!+2
                            dateComponents.hour = reminderComponents.hour!
                            dateComponents.minute = reminderComponents.minute!
                        }
                    }
                }
                
            default:
                print ("Error")
                break
            }
            
        }
        
        print("schedule determined as \(dateComponents)")
        return dateComponents
        
    }

}
