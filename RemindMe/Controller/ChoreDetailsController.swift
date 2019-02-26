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

class ChoreDetailsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet weak var choreTimeOfNotification: UITextField!
    
    @IBOutlet weak var reminderTimesTable: UITableView!
    
    //Date and Text Pickers
    private var datePicker : UIDatePicker?
    private var textPicker2 = UIPickerView()
    private var textPickerMode : String = "Frequency"
    
    var frequencyArray = ["daily", "weekly", "fortnightly", "monthly"]
    var timesPerDay = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
    
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
        
        // Set yourself as the delegate and datasource here:
        reminderTimesTable.delegate = self
        reminderTimesTable.dataSource = self
        
        // load up the array from user preferences (if we stored something in the file)
        reminderTimesTable.rowHeight = 50.0
        
        //print (dataFilePath)
        reminderTimesTable.reloadData()
        
        // Load up the values passed from segue
        choreTitle.text = choreTitlePassOver
        choreSound.text = choreSoundPassOver
        choreImage.image = UIImage(named: choreImagePassOver)
        choreFrequency.text = choreFrequencyPassOver
        choreTimesPerDay.text = String(timesPerDayPassOver)
        choreStartDate.text = formatDate(passedDate: choreStartDatePassOver)
        choreEndDAte.text = formatDate(passedDate: choreEndDatePassOver)
    
        textPicker2.delegate = self
        textPicker2.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChoreDetailsController.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
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
        datePicker?.maximumDate = choreEndDatePassOver
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
        datePicker?.minimumDate = choreStartDatePassOver
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
    
    
    @IBAction func timeOfNotificationPressed(_ sender: UITextField) {
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .time
        //datePicker?.date = choreEndDatePassOver
        let selectedDate = datePicker?.addTarget(self, action:
            #selector(ChoreDetailsController.notificationTimeChanged(datePicker:)), for:  .valueChanged)
        choreTimeOfNotification.inputView = datePicker
    }
    
    @objc func notificationTimeChanged(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        choreTimeOfNotification.text = dateFormatter.string(from: datePicker.date)
        //choreEndDatePassOver = datePicker.date
    }
    
    

    //MARK: - FREQUENCY AND TIMES PER DAY PICKERS
    @IBAction func frequencyPressed(_ sender: UITextField) {
        textPickerMode = "Frequency"
        choreFrequency.inputView = textPicker2
    }
    
    
    @IBAction func timesPerDatePressed(_ sender: UITextField) {
        textPickerMode = "TimesPerDay"
        choreTimesPerDay.inputView = textPicker2
    }
    
    
    func numberOfComponents(in textPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ textPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countOfRows : Int = 0
        if textPickerMode == "Frequency" {
            countOfRows = frequencyArray.count
        } else if textPickerMode == "TimesPerDay" {
            countOfRows = timesPerDay.count
        }
        return countOfRows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var rowTitle : String = ""
        if textPickerMode == "Frequency" {
            rowTitle = frequencyArray[row]
        } else if textPickerMode == "TimesPerDay" {
            rowTitle = String(timesPerDay[row])
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choreReminderTimesPassOver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reminderTimesTable.dequeueReusableCell(withIdentifier: "reminderTimeCell", for: indexPath)
        cell.textLabel?.text = choreReminderTimesPassOver[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
    
    
    //MARK: SAVE BUTTON
    @IBAction func SaveButtonPressed(_ sender: UIButton) {
        print("********* \(choreReminderTimesPassOver[0]), \(choreReminderTimesPassOver[1]), \(choreReminderTimesPassOver[2])")
        backscreen?.dataReceived(mode: modePassOver, row_id: choreRowPassOver, title: choreTitle.text!, sound: choreSound.text!, image: "image name text", frequency: choreFrequency.text!, timesPerDay: Int16(choreTimesPerDay.text!)!, startDate: choreStartDatePassOver, endDate: choreEndDatePassOver, reminderTimes: choreReminderTimesPassOver)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
