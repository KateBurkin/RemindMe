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

  
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    @IBOutlet weak var choresTable: UITableView!
    @IBOutlet var notificationCount: UILabel!
    @IBOutlet var clearNotifications: UIButton!
    

    //1. Initialise variables
    var notifCount : Int = 0
    var choresArray = [Chore]()
    var rtArray = [ReminderTime]()
    var modeToPass : String = ""
    var choreRowToPass : Int = 0
    var choreReminderTimesToPass : [String] = []
    var choreReminderTimesArray : [Date] = [Date.init()]
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Chore.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        print ("###DATA FILE PATH \(String(describing: dataFilePath))")

        // Set yourself as the delegate and datasource here:
        self.choresTable.delegate = self
        self.choresTable.dataSource = self
        
        refreshNotifications()
        
        //Register my CustomCell.xib file here:
        choresTable.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCell")
        loadItems()
    }

    //MARK:- NOTIFICATIONS RECONCILE FUNCTION
    
    func refreshNotifications (){
        // RETRIEVE ALL PENDING NOTIFICATIONS
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            (requests) in
            for request in requests {
                
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                    let triggerDate = trigger.nextTriggerDate() {

                    // Lookup ReminderTimes by Notification ID
                    let dbrequest : NSFetchRequest<ReminderTime> = ReminderTime.fetchRequest()
                    let reminderPredicate = NSPredicate(format: "rt_localNotificationID MATCHEs %@", request.identifier)
                    dbrequest.predicate = reminderPredicate
                    do {
                        self.rtArray = try self.context.fetch(dbrequest)
                    } catch {
                        print("Error loading item array, \(error)")
                    }

                    // Update the next notification date
                    if self.rtArray.count == 1 {
                        //let selectedRT : ReminderTime = rtArray[0]
                        let objectUpdate = self.rtArray[0] as NSManagedObject
                        objectUpdate.setValue(triggerDate, forKey: "rt_nextReminderTime")
                        self.saveItems()
                    }else{
                        print ("Incorrect number of results returned")
                    }
                }
            }
        }
    }
    
    @IBAction func clearNotificationsPressed(_ sender: Any) {
//        let notificationCenter = UNUserNotificationCenter.current()
//        notificationCenter.removeAllPendingNotificationRequests()
//        getNotificationCount()
    }
    
    
    //MARK:- TABLE VIEW FUNCTIONS
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
        // filter reminder times to the selected chore by title using predicate
        let request: NSFetchRequest<ReminderTime> = ReminderTime.fetchRequest()
        let reminderPredicate = NSPredicate(format: "chore.ch_title MATCHEs %@", choresArray[indexPath.row].ch_title!)
        request.predicate = reminderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "rt_nextReminderTime", ascending: false)]
        do {
            rtArray = try context.fetch(request)
        } catch {
            print("Error loading item array, \(error)")
        }
        
        // cycle through array and select first value that is past today's date otherwise pass text "No reminder set"
        cell.NextReminderTimeLabel.text = "No reminder set"
        for tt in rtArray {
            if tt.rt_nextReminderTime != nil{
                if tt.rt_nextReminderTime! > Date.init() {
                    cell.NextReminderTimeLabel.text = "Next reminder: \n\(dateFormatter.string(from: tt.rt_nextReminderTime!))"
                }
            }
        }
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // populate details from selected chore
        modeToPass = "Update"
        choreRowToPass = indexPath.row

        // Fetch reminder times for this chore
        choreReminderTimesToPass = []
        let request: NSFetchRequest<ReminderTime> = ReminderTime.fetchRequest()
        let reminderPredicate = NSPredicate(format: "chore.ch_title MATCHEs %@", choresArray[indexPath.row].ch_title!)
        request.predicate = reminderPredicate
        request.sortDescriptors = [NSSortDescriptor(key: "rt_reminderTime", ascending: true)]
        do {
            rtArray = try context.fetch(request)
        } catch {
            print("Error loading item array, \(error)")
        }

        // perform segue to ChoreDetailsController
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self)
    }
    
    
    @IBAction func addBarButtonPressed(_ sender: UIBarButtonItem) {
        modeToPass = "New"
        choreRowToPass = 0
        
        self.performSegue(withIdentifier: "goToChoreDetails", sender: self.addBarButton )
    }
    
    
    @IBAction func addNewButtonPressed(_ sender: Any) {
        modeToPass = "New"
        choreRowToPass = 0
    }
    
    
    //MARK:  SEGUE FUNCTIONS
     override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destinationVC = segue.destination as! ChoreDetailsController
        if modeToPass == "Update" {
            destinationVC.selectedChore = choresArray[choreRowToPass]
        }
        destinationVC.modePassOver = modeToPass
        destinationVC.choreRowPassOver = choreRowToPass
        destinationVC.selectedReminderTimes = rtArray
        destinationVC.backscreen = self
    }
    
    
    func dataReceived(mode: String, row_id: Int, title: String, sound: String, image: String, frequency: String, dayofweek: Int, timesPerDay: Int16, reminderTimesArray: [String], reminderTimesChangeLog:[String:String], reminderDeletedArray:[String]) {
        
        var savedRow_id = row_id
        //print ("Start Date Passed: \(startDate)   End Date Passed:  \(endDate)")

        if mode == "Update" {
            
            print ("*******Reminder Times count\(reminderTimesArray.count) Reminder Times change LOG\(reminderTimesChangeLog.count)  Reminder Times deleted\(reminderDeletedArray.count)")
            
            let selectedChore : Chore = choresArray[row_id]
            let objectUpdate = choresArray[row_id] as NSManagedObject
            objectUpdate.setValue(title, forKey: "ch_title")
            objectUpdate.setValue(sound, forKey: "ch_sound")
            objectUpdate.setValue(image, forKey: "ch_image")
            objectUpdate.setValue(frequency, forKey: "sh_frequency")
            objectUpdate.setValue(timesPerDay, forKey: "sh_timesPerDay")
            objectUpdate.setValue(dayofweek, forKey: "sh_weekday")
            //objectUpdate.setValue(startDate, forKey: "sh_startDate")
            //objectUpdate.setValue(endDate, forKey: "sh_endDate")
            saveItems()
            
            // Remove Deleted Reminder Times
            for tt in reminderDeletedArray {
                // Delete existing Reminder Time
                let request: NSFetchRequest<ReminderTime> = ReminderTime.fetchRequest()
                let p1 = NSPredicate(format: "chore.ch_title MATCHEs %@", title)
                let p2 = NSPredicate(format: "rt_reminderTime MATCHEs %@", tt)
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])
                request.predicate = predicate
                request.sortDescriptors = [NSSortDescriptor(key: "rt_reminderTime", ascending: true)]
                do {
                    rtArray = try context.fetch(request)
                } catch {
                    print("Error loading item array, \(error)")
                }

                // Cancel local notification reminder
                if rtArray.count == 1 {
                    if rtArray[0].rt_localNotificationID != nil {
                        Scheduler().removeNotification(reminderID: rtArray[0].rt_localNotificationID!)
                    }
                    // delete object reminder
                    context.delete(self.rtArray[0])
                }else{
                    print ("Incorrect number of results returned")
                }
            }
            
            // Add new Reminder Times
            for tt in reminderTimesArray {
                // Look up change log
                let state = reminderTimesChangeLog[tt]
                if state == "New" {
                // Set up NEW Reminder Time
                    // Schedule new local notification reminder --> LNID --> NextReminderDate
                    let startDateDefault = Date.init()
                    let endDateDefault = Date.init()+365
                    let dc = Scheduler().scheduleDate(reminderTimePassed: tt, startDate: startDateDefault, endDate: endDateDefault, frequency: frequency, weekday: dayofweek)
                    let (notificationDate, notificationID) = Scheduler().scheduleNotification(dateComponents: dc, title: "Your reminder", body: title)
                    
                    //add new Reminder time record to DB
                    let newRT = ReminderTime(context: self.context)
                    newRT.rt_reminderTime = tt
                    newRT.rt_suspended = false
                    newRT.rt_localNotificationID = notificationID
                    newRT.rt_nextReminderTime = notificationDate
                    newRT.chore = selectedChore
                    saveItems()
                    print ("Appended new reminder time \(tt) with ID \(notificationID) for \(notificationDate)")
                }
            }
            
            

        } else {
            let newChore = Chore(context: self.context)
            newChore.ch_title = title
            newChore.sh_suspended = false
            newChore.ch_sound = sound
            newChore.ch_image = image
            newChore.sh_frequency = frequency
            newChore.sh_timesPerDay = Int16(timesPerDay)
            newChore.sh_weekday = Int16(dayofweek)
            //newChore.sh_startDate = startDate
            //newChore.sh_endDate = endDate
            //newChore.sh_reminderTimes = reminderTimes as NSObject
            self.choresArray.append(newChore)
            savedRow_id = choresArray.count - 1
            saveItems()
            
            //Add Reminder TImes
            for tt in reminderTimesArray {
                // Set up NEW Reminder Time
                // Schedule new local notification reminder --> LNID --> NextReminderDate
                let startDateDefault = Date.init()
                let endDateDefault = Date.init()+365
                let dc = Scheduler().scheduleDate(reminderTimePassed: tt, startDate: startDateDefault, endDate: endDateDefault, frequency: frequency, weekday: dayofweek)
                let (notificationDate, notificationID) = Scheduler().scheduleNotification(dateComponents: dc, title: "Your reminder", body: title)
                
                //add new Reminder time record to DB
                let newRT = ReminderTime(context: self.context)
                newRT.rt_reminderTime = tt
                newRT.rt_suspended = false
                newRT.rt_localNotificationID = notificationID
                newRT.rt_nextReminderTime = notificationDate
                newRT.chore = newChore
                saveItems()
                print ("Appended new reminder time \(tt)")
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
        do {
            choresArray = try context.fetch(request)
        } catch {
            print("Error loading item array, \(error)")
        }
        choresTable.reloadData()
    }
    
//    func deleteChore(rowNumber: Int) {
//        context.delete(self.choresArray[rowNumber])
//        choresArray.remove(at: rowNumber)
//    }

    
}

