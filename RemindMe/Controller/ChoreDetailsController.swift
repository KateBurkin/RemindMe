//
//  ChoreDetailsController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol CanReceive {
    func dataReceived(mode:String, row_id: Int, title: String, sound : String, image : String, frequency : String, timesPerDay: Int16, startDate: Date, endDate: Date, reminderTimesArray: [String], reminderTimesChangeLog: [String:String], reminderDeletedArray:[String])
}

class ChoreDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, DTReceive, TXReceive {

    //Buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    //TextFields
    @IBOutlet weak var choreTitle: UITextField!
    @IBOutlet weak var choreSound: UITextField!
    @IBOutlet weak var choreImage: UIImageView!
    @IBOutlet weak var choreStartDate: UITextField!
    @IBOutlet weak var choreEndDAte: UITextField!
    @IBOutlet weak var choreFrequency: UITextField!
    @IBOutlet weak var choreTimesPerDay: UITextField!
    
    @IBOutlet var reminderTimesTable: UITableView!
    @IBOutlet weak var addReminderTime: UIButton!
    
    //Text Pickers
    private var textPickerFrequency = UIPickerView()
    private var textPickerTimesPerDay = UIPickerView()
    private var textPickerMode : String = ""
    
    //Variable to pass to DateTimePicker to set up the date time picker
    var dtp_caller : String = ""
    var dtp_defaultDate : Date = Date.init()
    var txt_caller : String = ""
    var txtPickerArray :[String] = []
    
    //Segue Protocol
    var backscreen : CanReceive?
    
    var selectedChore : Chore?
    var selectedReminderTimes = [ReminderTime]()
    var rtChangeLogArray : [String:String] = [:]
    var rtWorkingArray : [String] = []
    var rtDeletedArray : [String] = []
    
    //Initialise Segue values that are passed over
    var modePassOver : String = ""
    var choreRowPassOver : Int = 0
    var choreReminderTimesPassOver: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print ("Mode Pass Over \(modePassOver)")
        if modePassOver == "New" {
            newChoreData()
        } else {
            loadChoreData()
        }
        
        reminderTimesTable.delegate = self
        reminderTimesTable.dataSource = self
        
    }
    
    //MARK: - REMINDER TIME PICKERS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rtWorkingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTimeCell", for: indexPath)
        cell.textLabel?.text = rtWorkingArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TO DO: - incorporate cocoapods to swipe cell to delete
        
        var response = UITextField()
        let alert = UIAlertController(title: "Delete this Reminder time?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete this Reminder time", style: .default) { (action) in
            if response.text == "Y" {
                //Update rtChangeLog to mark selected RT time as Deleted
                self.rtChangeLogArray[self.rtWorkingArray[indexPath.row]] = "Deleted"
                
                //Remove RT time from Array
                self.rtDeletedArray.append(self.rtWorkingArray[indexPath.row])
                self.rtWorkingArray.remove(at: indexPath.row)
                
                //Reload Table
                self.reminderTimesTable.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Y"
            response = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addReminderTimePressed(_ sender: Any) {
        //TO DO - replace with segue to time picker screen
        dtp_caller = "reminderTime"
        dtp_defaultDate = Date.init()
        self.performSegue(withIdentifier: "goToDateTimePicker", sender: self.choreStartDate)
    }

    //MARK: - DATE FORMATTERS
    func formatDateToString(passedDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return dateFormatter.string(from: passedDate)
    }
    
    func formatStringToDate(passedString: String) -> Date {
        let stringFormatter = DateFormatter()
        stringFormatter.dateFormat = "dd/MM/yyyy"
        return stringFormatter.date(from: passedString)!
    }
    
    //MARK: - UPLOAD CHORE DATA to screen
    func loadChoreData(){
        choreTitle.text = selectedChore!.ch_title!
        choreImage.image = UIImage(named: selectedChore!.ch_image!)
        choreSound.text = selectedChore!.ch_sound!
        choreFrequency.text = selectedChore!.sh_frequency!
        choreStartDate.text = formatDateToString(passedDate: selectedChore!.sh_startDate!)
        choreEndDAte.text = formatDateToString(passedDate: selectedChore!.sh_endDate!)
        loadReminderTimes()
    }
 
    func newChoreData(){
        choreTitle.text = ""
        choreImage.image = UIImage(named: "reminderIcon_Fotor.jpg")
        choreSound.text = "sound.wav"
        choreFrequency.text = "daily"
        choreStartDate.text = formatDateToString(passedDate: Date.init())
        choreEndDAte.text = formatDateToString(passedDate: Date.init().addingTimeInterval(31622400))
    }
    
    func loadReminderTimes(){
        //Populate initial change log
        for tt in selectedReminderTimes {
            rtChangeLogArray[tt.rt_reminderTime!] = "Unchanged"
        }
        
        // Create working Array of reminder times
        rtWorkingArray = Array(self.rtChangeLogArray.keys)
        
        // Sort keys
        self.rtWorkingArray.sort()
        print ("Array of reminder times: \(rtChangeLogArray)")
    }
    
    //MARK: - START AND END DATE PICKERS
    @IBAction func startDatePressed(_ sender: UITextField) {
        dtp_caller = "startDate"
        dtp_defaultDate = formatStringToDate(passedString: choreStartDate.text!)
        self.performSegue(withIdentifier: "goToDateTimePicker", sender: self.choreStartDate)
    }

    
    @IBAction func endDatePressed(_ sender: UITextField) {
        dtp_caller = "endDate"
        dtp_defaultDate = formatStringToDate(passedString: choreEndDAte.text!)
        self.performSegue(withIdentifier: "goToDateTimePicker", sender: self.choreEndDAte)
    }
    
    //MARK: - FREQUENCY AND TIMES PER DAY PICKERS
    @IBAction func frequencyPressed(_ sender: UITextField) {
        txt_caller = "frequency"
        txtPickerArray = ["daily", "weekly", "fortnightly"]
        self.performSegue(withIdentifier: "goToTextPicker", sender: self.choreFrequency)
    }
    
    //MARK:  SEGUE FUNCTIONS
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "goToDateTimePicker" {
            let dateTimePickerVC = segue.destination as! DateTimePicker
            dateTimePickerVC.caller = dtp_caller
            dateTimePickerVC.defaultDate = dtp_defaultDate
            dateTimePickerVC.detailScreen = self
        }
        if segue.identifier == "goToTextPicker"{
            let textPickerVC = segue.destination as! TextPickerViewController
            textPickerVC.caller = txt_caller
            textPickerVC.listArray = txtPickerArray
            textPickerVC.cHdetailScreen = self
        }
    }

    func dateTimePicked(dtp_caller: String, dtp_value: String) {
        switch dtp_caller {
        case "startDate":
            choreStartDate.text = dtp_value
        case "endDate":
            choreEndDAte.text = dtp_value
        case "reminderTime":
            if let test = self.rtChangeLogArray[dtp_value] {
                //Duplicate - no update required
            } else {
                self.rtChangeLogArray[dtp_value] = "New"
                self.rtWorkingArray.append(dtp_value)
                self.rtWorkingArray.sort()
            }
            self.reminderTimesTable.reloadData()
        default:
            break
        }
    }
    
    func textPicked(tp_caller: String, tp_value: String) {
        if tp_caller == "frequency" {
            choreFrequency.text = tp_value
        }
    }
    

    
    //MARK: SAVE BUTTON
    @IBAction func SaveButtonPressed(_ sender: UIButton) {
        backscreen?.dataReceived(mode: modePassOver, row_id: choreRowPassOver, title: choreTitle.text!, sound: choreSound.text!, image: "reminderIcon_Fotor.jpg", frequency: choreFrequency.text!, timesPerDay: 1, startDate: formatStringToDate(passedString: choreStartDate.text!), endDate: formatStringToDate(passedString: choreEndDAte.text!), reminderTimesArray: rtWorkingArray, reminderTimesChangeLog: rtChangeLogArray, reminderDeletedArray: rtDeletedArray)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
