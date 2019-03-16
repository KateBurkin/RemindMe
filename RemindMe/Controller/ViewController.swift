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

struct customCell {
    let choreTitleLabel : String!
    let reminderTimeLabel : String!
    let choreImage : UIImage!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate, CanReceive {

    @IBOutlet weak var choresTable: UITableView!
    
    //1. Initialise variables
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
    var choreReminderTimesToPass = ["00:00"]
    var choreReminderIDsArray : [String] = [""]
    var choreReminderTimesArray : [Date] = [Date.init()]
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Chore.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        print ("###DATA FILE PATH \(dataFilePath)")

        // Set yourself as the delegate and datasource here:
        self.choresTable.delegate = self
        self.choresTable.dataSource = self
        

        //Register my CustomCell.xib file here:
        choresTable.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        print ("Got past registering custom cell")
        loadItems()
    }

    //MARK:- TABLE VIEW FUNCTIONS
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choresArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMMM 'at' HH:mm"
        
        let cell = choresTable.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        
        cell.ChoreTitleLabel.text = choresArray[indexPath.row].ch_title!
        cell.ChoreImage.image = UIImage(named: choresArray[indexPath.row].ch_image!)
        
        // TO DO: - update code to select next reminder of the three reminder times
        
        if choresArray[indexPath.row].tr_nextReminder1 != nil {
            cell.NextReminderTimeLabel.text = "Next reminder: \n\(dateFormatter.string(from: choresArray[indexPath.row].tr_nextReminder1!))"
        } else {
            cell.NextReminderTimeLabel.text = "No reminder set"
        }

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
        //choreReminderID = choresArray[indexPath.row].tr_reminderID1!
        
        print (choresArray[indexPath.row].sh_reminderTimes as! [String])
        
        // perform segue to ChoreDetailsController
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self)
    }
    
    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        modeToPass = "New"
        choreRowToPass = 0
        choreTitleToPass = ""
        choreSoundToPass = "sound.wav"
        choreImageToPass = "reminderIcon_Fotor.jpg"
        choreFrequencyToPass = "daily"
        choreTimesPerDayToPass = 1
        choreStartDateToPass = Date.init()
        choreEndDateToPass = Date.init().addingTimeInterval(31622400)
        choreReminderTimesToPass = ["09:00"]
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

        var savedRow_id = row_id
        print ("Reminder times passed to save: \(reminderTimes as! [String])")

        if mode == "Update" {
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let choreRecord = try context.fetch(request)
                let objectUpdate = choreRecord[row_id] as NSManagedObject
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
            self.choresArray.append(newChore)
            savedRow_id = choresArray.count - 1
        }
        saveItems()
        
        // Schedule notifications for each next reminder
        var reminderCount:Int = 0
        
        // Remove current reminders (if any)
        if choresArray[choreRowToPass].tr_reminderID1 != nil && choresArray[choreRowToPass].tr_reminderID1 != "" {
            Scheduler().removeNotification(reminderID: choresArray[choreRowToPass].tr_reminderID1!)
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[savedRow_id] as NSManagedObject
                objectUpdate.setNilValueForKey("tr_reminderID1")
                objectUpdate.setNilValueForKey("tr_nextReminder1")
            } catch {
                print ("Error updating record \(error)")
            }
            saveItems()
        }
        if choresArray[choreRowToPass].tr_reminderID1 != nil && choresArray[choreRowToPass].tr_reminderID2 != "" {
            Scheduler().removeNotification(reminderID: choresArray[choreRowToPass].tr_reminderID2!)
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[savedRow_id] as NSManagedObject
                objectUpdate.setNilValueForKey("tr_reminderID2")
                objectUpdate.setNilValueForKey("tr_nextReminder2")
            } catch {
                print ("Error updating record \(error)")
            }
            saveItems()
        }
        if choresArray[choreRowToPass].tr_reminderID1 != nil && choresArray[choreRowToPass].tr_reminderID3 != "" {
            Scheduler().removeNotification(reminderID: choresArray[choreRowToPass].tr_reminderID3!)
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[savedRow_id] as NSManagedObject
                objectUpdate.setNilValueForKey("tr_reminderID3")
                objectUpdate.setNilValueForKey("tr_nextReminder3")
            } catch {
                print ("Error updating record \(error)")
            }
            saveItems()
        }
        
        // SET new reminders and save reminder IDs to record
        for tt in reminderTimes {            
            let dc = Scheduler().scheduleDate(reminderTimePassed: tt, startDate: startDate, endDate: endDate, frequency: frequency, weekDaysArray: [8])
            let (notificationDate, notificationID) = Scheduler().scheduleNotification(dateComponents: dc, title: "Your reminder", body: title)
            reminderCount += 1
            let request : NSFetchRequest<Chore> = Chore.fetchRequest()
            do {
                let test = try context.fetch(request)
                let objectUpdate = test[savedRow_id] as NSManagedObject
                objectUpdate.setValue(notificationID, forKey: "tr_reminderID\(reminderCount)")
                objectUpdate.setValue(notificationDate, forKey: "tr_nextReminder\(reminderCount)")
            } catch {
                print ("Error updating record \(error)")
            }
            

        }
        
        saveItems()
        loadItems()
    }
    
    
    //MARK: MODEL MANIPULATION METHODS
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving to Core Data, \(error)")
        }
    }
    
    func loadItems() {
        let request : NSFetchRequest<Chore> = Chore.fetchRequest()
        let sort = NSSortDescriptor(key: "tr_nextReminder1", ascending: true)
        request.sortDescriptors = [sort]
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

    
}

