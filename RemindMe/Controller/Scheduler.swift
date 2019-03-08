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
    
    func scheduler (){
//SET DATE and TIME Formatters
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
let timeFormatter = DateFormatter()
timeFormatter.dateFormat = "HH:mm"

//TODAY'S DATE
let todayDate : Date = Date.init()



//SET UP START AND END DATES - this would be replaced with real values from DB
let reminderTimeString : String = "12:45"
let weekDay : Int = 4
var startDate : Date = dateFormatter.date(from: "2019-02-09T\(reminderTimeString)")!
var endDate : Date = dateFormatter.date(from: "2020-03-09T\(reminderTimeString)")!

print ("StartDate \(String(describing: startDate))  EndDate \(String(describing: endDate))")

// set Reminder Time
let reminderTime = timeFormatter.date(from: reminderTimeString)

// SCHEDULING DAILY REMINDER
//1. Check that we're not past the endDate
if todayDate > endDate {
    print("schedule ended")
    
} else {
    
    // Configure the recurring date.
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current
    var dateComponentsWk = DateComponents()
    dateComponentsWk.calendar = Calendar.current
    var dateComponentsFn = DateComponents()
    dateComponentsFn.calendar = Calendar.current
    
    // DAILY NEXT REMINDER
    if todayDate < startDate {
        
        let components = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        // assign date components for the trigger
        dateComponents.timeZone = Calendar.current.timeZone
        dateComponents.day = components.day!
        dateComponents.month = components.month!
        dateComponents.year = components.year!
        dateComponents.hour = reminderComp.hour!
        dateComponents.minute = reminderComp.minute!
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
    } else {
        //set reminder to today's reminder time
        let components = Calendar.current.dateComponents([.day, .month, .year], from: todayDate)
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        let nowTimeComp =  Calendar.current.dateComponents([.hour, .minute], from: todayDate)
        
        if nowTimeComp.hour! > reminderComp.hour!{
            dateComponents.day = components.day!+1
        } else {
            dateComponents.day = components.day!
        }
        
        // assign date components for the trigger
        dateComponents.timeZone = Calendar.current.timeZone
        dateComponents.month = components.month!
        dateComponents.year = components.year!
        dateComponents.hour = reminderComp.hour!
        dateComponents.minute = reminderComp.minute!
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
        
    }
    
    // WEEKLY NEXT REMINDER
    if todayDate < startDate {
        
        let components = Calendar.current.dateComponents([.day, .month, .year, .weekday], from: startDate)
        var daysIncrement : Int = 0
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        // Find next weekday interval from start date
        if components.weekday! > weekDay {
            daysIncrement = (7 - components.weekday!+weekDay)
        } else if components.weekday! < weekDay {
            daysIncrement = (weekDay - components.weekday!)
        }
        
        
        // assign date components for the trigger
        dateComponentsWk.day = components.day!+daysIncrement
        dateComponentsWk.month = components.month!
        dateComponentsWk.year = components.year!
        dateComponentsWk.weekday = weekDay
        dateComponentsWk.hour = reminderComp.hour!
        dateComponentsWk.minute = reminderComp.minute!
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsWk, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
        
    } else {
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        // assign date components for the trigger
        dateComponentsWk.weekday = weekDay
        dateComponentsWk.hour = reminderComp.hour!
        dateComponentsWk.minute = reminderComp.minute!
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsWk, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
        
    }
    
    // FORTNIGHTLY NEXT REMINDER
    if todayDate < startDate {
        
        let components = Calendar.current.dateComponents([.day, .month, .year, .weekday], from: startDate)
        var daysIncrement : Int = 0
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        // Find next weekday interval from start date
        if components.weekday! > weekDay {
            daysIncrement = (7 - components.weekday!+weekDay)
        } else if components.weekday! < weekDay {
            daysIncrement = (weekDay - components.weekday!)
        }
        
        
        // assign date components for the trigger
        dateComponentsFn.day = components.day!+daysIncrement
        dateComponentsFn.month = components.month!
        dateComponentsFn.year = components.year!
        dateComponentsFn.weekday = weekDay
        dateComponentsFn.hour = reminderComp.hour!
        dateComponentsFn.minute = reminderComp.minute!
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsFn, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
        
    } else {
        
        let components = Calendar.current.dateComponents([.day, .month, .year, .weekday, .weekOfYear], from: startDate)
        let componentsToday = Calendar.current.dateComponents([.day, .month, .year, .weekday, .weekOfYear], from: todayDate)
        let reminderComp = Calendar.current.dateComponents([.hour, .minute], from: reminderTime!)
        
        let result : Int = Int(components.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
        let result2 : Int = Int(componentsToday.weekOfYear!).remainderReportingOverflow(dividingBy: 2).partialValue
        if result != result2 {
            // assign date components for the trigger
            dateComponentsFn.weekday = weekDay
            dateComponentsFn.weekOfYear = componentsToday.weekOfYear!+1
            dateComponentsFn.hour = reminderComp.hour!
            dateComponentsFn.minute = reminderComp.minute!
            
        } else {
            if componentsToday.weekday! > weekDay {
                // assign date components for the trigger
                dateComponentsFn.weekday = weekDay
                dateComponentsFn.weekOfYear = componentsToday.weekOfYear!+2
                dateComponentsFn.hour = reminderComp.hour!
                dateComponentsFn.minute = reminderComp.minute!
            } else {
                // assign date components for the trigger
                dateComponentsFn.weekday = weekDay
                dateComponentsFn.weekOfYear = componentsToday.weekOfYear!
                dateComponentsFn.hour = reminderComp.hour!
                dateComponentsFn.minute = reminderComp.minute!
            }
        }
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsFn, repeats: false)
        
        print("Next notification date \(String(describing: trigger.nextTriggerDate()))")
    }
    
}


    }
}
