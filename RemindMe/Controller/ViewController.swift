//
//  ViewController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate, CanReceive {

    @IBOutlet weak var choresTable: UITableView!
    
    var choresArray = [Chore]()
    var modeToPass : String = ""
    var choreRowToPass : Int = 0
    var choreTitleToPass : String = ""
    var choreImageToPass : String = ""
    var choreSoundToPass : String = ""
    var choreFrequencyToPass : String = ""
    var choreTimesPerDayToPass : Int16 = 0
    var choreStartDateToPass : Date = Date.init()
    var choreEndDateToPass : Date = Date.init()
    var choreReminderTimesToPass = ["00:00","01:00","02:00"]
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Chore.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print ("###DATA FILE PATH \(dataFilePath)")

        // Set yourself as the delegate and datasource here:
        self.choresTable.delegate = self
        self.choresTable.dataSource = self
        
        // load up the array from user preferences (if we stored something in the file)
        choresTable.rowHeight = 50.0
        loadItems()
        //choresTable.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choresArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = choresTable.dequeueReusableCell(withIdentifier: "choreItemCell", for: indexPath)
        cell.textLabel?.text = choresArray[indexPath.row].ch_title
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // populate details from selected chore
        modeToPass = "Update"
        choreRowToPass = indexPath.row
        choreTitleToPass = choresArray[indexPath.row].ch_title!
        choreSoundToPass = choresArray[indexPath.row].ch_sound!
        choreImageToPass = choresArray[indexPath.row].ch_image!
        choreFrequencyToPass = choresArray[indexPath.row].sh_frequency!
        choreTimesPerDayToPass = choresArray[indexPath.row].sh_timesPerDay
        choreStartDateToPass = choresArray[indexPath.row].sh_startDate!
        choreEndDateToPass = choresArray[indexPath.row].sh_endDate!
        choreReminderTimesToPass = choresArray[indexPath.row].sh_reminderTimes as! [String]
        
        // perform segue to ChoreDetailsController
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self)
    }
    
    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        modeToPass = "New"
        choreRowToPass = 0
        choreTitleToPass = ""
        choreSoundToPass = ""
        choreImageToPass = ""
        choreFrequencyToPass = ""
        choreTimesPerDayToPass = 0
        choreStartDateToPass = Date.init()
        choreEndDateToPass = Date.init()
        choreReminderTimesToPass = ["08:00","12:00","16:00"]
    }
    
    
    //MARK:  SEGUE FUNCTIONS
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destinationVC = segue.destination as! ChoreDetailsController
        destinationVC.modePassOver = modeToPass
        destinationVC.choreRowPassOver = choreRowToPass
        destinationVC.choreTitlePassOver = choreTitleToPass
        destinationVC.choreSoundPassOver = choreSoundToPass
        destinationVC.choreImagePassOver = choreImageToPass
        destinationVC.choreFrequencyPassOver = choreFrequencyToPass
        destinationVC.timesPerDayPassOver = choreTimesPerDayToPass
        destinationVC.choreStartDatePassOver = choreStartDateToPass
        destinationVC.choreEndDatePassOver = choreEndDateToPass
        destinationVC.choreReminderTimesPassOver = choreReminderTimesToPass
        destinationVC.backscreen = self
    }
    
    
    func dataReceived(mode: String, row_id: Int, title: String, sound: String, image: String, frequency: String, timesPerDay: Int16, startDate: Date, endDate: Date, reminderTimes: [String]) {
        
        if mode == "Update" {
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[row_id] as NSManagedObject
                objectUpdate.setValue(title, forKey: "ch_title")
                objectUpdate.setValue(sound, forKey: "ch_sound")
                objectUpdate.setValue(image, forKey: "ch_image")
                objectUpdate.setValue(frequency, forKey: "sh_frequency")
                objectUpdate.setValue(timesPerDay, forKey: "sh_timesPerDay")
                objectUpdate.setValue(startDate, forKey: "sh_startDate")
                objectUpdate.setValue(endDate, forKey: "sh_endDate")
                objectUpdate.setValue(reminderTimes as NSObject, forKey: "sh_reminderTimes")
            } catch {
                print ("Error updating record \(error)")
            }
            saveItems()
            loadItems()
            
        } else {
            let newChore = Chore(context: self.context)
            newChore.ch_title = title
            newChore.sh_suspended = false
            newChore.ch_sound = sound
            newChore.ch_image = image
            newChore.sh_frequency = frequency
            newChore.sh_timesPerDay = Int16(timesPerDay)
            newChore.sh_startDate = startDate
            newChore.sh_endDate = endDate
            newChore.sh_reminderTimes = reminderTimes as NSObject
            
            //what will happen once the user clicks on the Add Item button on our UIAlert
            self.choresArray.append(newChore)
            saveItems()
            loadItems()
        }
    }
    
    
    //MARK: MODEL MANIPULATION METHODS
    func saveItems() {
        scheduleNotification()
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data, \(error)")
        }
    }
    
    func loadItems() {
        let request : NSFetchRequest<Chore> = Chore.fetchRequest()
        do {
            choresArray = try context.fetch(request)
        } catch {
            print("Error loading item array, \(error)")
        }
        choresTable.reloadData()
    }
    
//    func deleteItems(rowNumber: Int) {
//        context.delete(self.choresArray[rowNumber])
//        choresArray.remove(at: rowNumber)
//    }
    
    func scheduleNotification(){

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {
                print ("Permission not granted")
                return}
            
            // Remove all previous notifications
            notificationCenter.getPendingNotificationRequests { (notifications) in
                print("Original Count: \(notifications.count)")
                for item in notifications {
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Weekly Staff Meeting"
            content.body = "Every Tuesday at 2pm"
            //content.sound = dog_bark4.wav
            
            // Configure the recurring date.
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            dateComponents.weekday = 4  // Friday
            dateComponents.hour = 14    // 14:00 hours
            dateComponents.minute = 40    // 14:00 hours
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the request
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            
            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    // Handle any errors.
                }
            }
            
            // Remove all previous notifications
            notificationCenter.getPendingNotificationRequests { (notifications) in
                print("New Count: \(notifications.count)")
                for item in notifications {
                    print("Item identifier \(item.identifier)")
                    print("Item identifier \(String(describing: item.trigger))")
                    //notificationCenter.removePendingNotificationRequests(withIdentifiers: [item.identifier])
                }
                print("Next notification date \(String(describing: trigger.nextTriggerDate()))")

            }
            
        }
    }

}

