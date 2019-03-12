//
//  ChoreDetailsController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import Foundation

protocol CanReceive {
    func dataReceived(mode:String, row_id: Int, title: String, sound : String, image : String, frequency : String, timesPerDay: Int16, startDate: Date, endDate: Date, reminderTimes: [String])
    
}

class ChoreDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    //Temp text fields for reminder timers
    @IBOutlet var NotificationTime1: UITextField!
    @IBOutlet var NotificationTime2: UITextField!
    @IBOutlet var NotificationTime3: UITextField!
    
    
    @IBOutlet var reminderTimesTable: UITableView!
    
    //Date and Text Pickers
    private var datePicker : UIDatePicker?
    private var textPickerFrequency = UIPickerView()
    private var textPickerTimesPerDay = UIPickerView()
    private var textPickerMode : String = ""
    private var timePicker1 : UIDatePicker?
    private var timePicker2 : UIDatePicker?
    private var timePicker3 : UIDatePicker?
    
    var frequencyArray = ["daily", "weekly", "fortnightly"]
    var timesPerDay = [1,2,3]
    var weekdaysArray = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    //Segue Protocol
    var backscreen : CanReceive?
    
    //Initialise Segue values that are passed over
    var modePassOver : String = ""
    var choreTitlePassOver : String = ""
    var choreRowPassOver : Int = 0
    var choreImagePassOver : String = ""
    var choreSoundPassOver : String = ""
    var choreFrequencyPassOver : String = ""
    var timesPerDayPassOver : Int16 = 0
    var choreStartDatePassOver : Date = Date.init()
    var choreEndDatePassOver : Date = Date.init()
    var choreReminderTimesPassOver = ["00:00","01:00","02:00"]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load up the values passed from segue
        choreTitle.text = choreTitlePassOver
        choreSound.text = choreSoundPassOver
        choreImage.image = UIImage(named: choreImagePassOver)
        choreFrequency.text = choreFrequencyPassOver
        choreTimesPerDay.text = String(timesPerDayPassOver)
        choreStartDate.text = formatDate(passedDate: choreStartDatePassOver)
        choreEndDAte.text = formatDate(passedDate: choreEndDatePassOver)
        
        // sort reminder times array before loading into the table
        choreReminderTimesPassOver.sort()
        
        textPickerFrequency.delegate = self
        textPickerFrequency.dataSource = self
        textPickerTimesPerDay.delegate = self
        textPickerTimesPerDay.dataSource = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChoreDetailsController.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        
        
        
        // Set yourself as the delegate and datasource here:
        self.reminderTimesTable.delegate = self
        self.reminderTimesTable.dataSource = self
        reminderTimesTable.allowsSelection = true
        self.reminderTimesTable.rowHeight = 30.0
        reminderTimesTable.reloadData()
        
        // load notification times to temp text boxes
        loadNotificationTimes()

    }
    
    func loadNotificationTimes() {
//        choreReminderTimesPassOver.forEach { tt in
//        }
        
        NotificationTime1.text = choreReminderTimesPassOver[0]
        NotificationTime2.text = choreReminderTimesPassOver[1]
        NotificationTime3.text = choreReminderTimesPassOver[2]
        
        
    }
    
    func formatDate(passedDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return dateFormatter.string(from: passedDate)
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    
    
    //MARK: - START AND END DATE PICKERS
    @IBAction func startDatePressed(_ sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.date = choreStartDatePassOver
        //datePicker?.maximumDate = choreEndDatePassOver
        let selectedDate = datePicker?.addTarget(self, action:
            #selector(ChoreDetailsController.startDateChanged(datePicker:)), for: .valueChanged)
        choreStartDate.inputView = datePicker
    }
    
    
    @objc func startDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        choreStartDate.text = dateFormatter.string(from: datePicker.date)
        choreStartDatePassOver = datePicker.date
    }
 
    
    @IBAction func endDatePressed(_ sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.date = choreEndDatePassOver
        //datePicker?.minimumDate = choreStartDatePassOver
        let selectedDate = datePicker?.addTarget(self, action:
            #selector(ChoreDetailsController.endDateChanged(datePicker:)), for:  .valueChanged)
        choreEndDAte.inputView = datePicker
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        choreEndDAte.text = dateFormatter.string(from: datePicker.date)
        choreEndDatePassOver = datePicker.date
    }
    

    //MARK: - REMINDER TIME PICKERS
    
    @IBAction func Notification1Pressed(_ sender: Any) {
        print ("Notification 1 pressed")
        timePicker1 = UIDatePicker()
        timePicker1?.datePickerMode = .time
        let selectedDate = timePicker1?.addTarget(self, action:
            #selector(ChoreDetailsController.notification1TimeChanged(datePicker:)), for:  .valueChanged)
        NotificationTime1.inputView = timePicker1
    }
    
    @objc func notification1TimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        NotificationTime1.text = dateFormatter.string(from: datePicker.date)
        choreReminderTimesPassOver[0] = dateFormatter.string(from: datePicker.date)
    }
    
    
    @IBAction func Notification2Pressed(_ sender: Any) {
        print ("Notification 2 pressed")
        timePicker2 = UIDatePicker()
        timePicker2?.datePickerMode = .time
        let selectedDate = timePicker2?.addTarget(self, action:
            #selector(ChoreDetailsController.notification2TimeChanged(datePicker:)), for:  .valueChanged)
        NotificationTime2.inputView = timePicker2
    }
    
    @objc func notification2TimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        NotificationTime2.text = dateFormatter.string(from: datePicker.date)
        choreReminderTimesPassOver[1] = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func Notification3Pressed(_ sender: Any) {
        print ("Notification 3 pressed")
        timePicker3 = UIDatePicker()
        timePicker3?.datePickerMode = .time
        let selectedDate = timePicker3?.addTarget(self, action:
            #selector(ChoreDetailsController.notification3TimeChanged(datePicker:)), for:  .valueChanged)
        NotificationTime3.inputView = timePicker3
    }
    
    @objc func notification3TimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        NotificationTime3.text = dateFormatter.string(from: datePicker.date)
        choreReminderTimesPassOver[2] = dateFormatter.string(from: datePicker.date)
    }
    
    //MARK: - FREQUENCY AND TIMES PER DAY PICKERS
    @IBAction func frequencyPressed(_ sender: UITextField) {
        textPickerMode = "Frequency"
        choreFrequency.inputView = textPickerFrequency
    }


    @IBAction func timesPerDatePressed(_ sender: UITextField) {
        textPickerMode = "TimesPerDay"
        choreTimesPerDay.inputView = textPickerTimesPerDay
    }


    func numberOfComponents(in textPicker: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ textPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countOfRows : Int = 0
        if textPickerMode == "TimesPerDay" {
            countOfRows = timesPerDay.count
        } else if textPickerMode == "Frequency" {
            countOfRows = frequencyArray.count
        }
        return countOfRows
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var rowTitle : String = ""
        if textPickerMode == "TimesPerDay" {
            rowTitle = String(timesPerDay[row])
        } else if textPickerMode == "Frequency" {
            rowTitle = frequencyArray[row]
        }
        return rowTitle
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if textPickerMode == "Frequency" {
            choreFrequency.text = frequencyArray[row]
        } else if textPickerMode == "TimesPerDay" {
            choreTimesPerDay.text = String(timesPerDay[row])
        }
    }

    
    //MARK: - REMINDER TIME TABLE
    func tableView(_ reminderTimesTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choreReminderTimesPassOver.count
    }

    func tableView(_ reminderTimesTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reminderTimesTable.dequeueReusableCell(withIdentifier: "reminderTimeCell", for: indexPath)
        cell.textLabel?.text = choreReminderTimesPassOver[indexPath.row]
        return cell
    }
    

    func tableView(_ reminderTimesTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
   
    
    //MARK: SAVE BUTTON
    @IBAction func SaveButtonPressed(_ sender: UIButton) {
        // sort reminder times array before saving
        choreReminderTimesPassOver.sort()
        backscreen?.dataReceived(mode: modePassOver, row_id: choreRowPassOver, title: choreTitle.text!, sound: choreSound.text!, image: "image name text", frequency: choreFrequency.text!, timesPerDay: Int16(choreTimesPerDay.text!)!, startDate: choreStartDatePassOver, endDate: choreEndDatePassOver, reminderTimes: choreReminderTimesPassOver)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
