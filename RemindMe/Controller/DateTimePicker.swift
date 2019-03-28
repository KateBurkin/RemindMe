//
//  DateTimePicker.swift
//  RemindMe
//
//  Created by Kate on 28/3/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit

protocol DTReceive {
    func dateTimePicked(dtp_caller : String, dtp_value : String)
    
}

class DateTimePicker: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var caller : String = ""
    var defaultDate : Date = Date.init()
    
    //Segue Protocol
    var detailScreen : DTReceive?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DateTimePicker.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        switch caller {
        case "startDate":
            titleLabel.text = "Select Start Date"
            datePicker.datePickerMode = .date
            datePicker.date = defaultDate
        case "endDate":
            titleLabel.text = "Select End Date"
            datePicker.datePickerMode = .date
            datePicker.date = defaultDate
        case "reminderTime":
            titleLabel.text = "Select Reminder Time"
            datePicker.datePickerMode = .time
            datePicker.minuteInterval = 15
        default:
            break
        }
        
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func formatDateToString(passedDate: Date) -> String {
        let dateFormatter = DateFormatter()
        if caller == "reminderTime" {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd/MM/YYYY"
        }
        return dateFormatter.string(from: passedDate)
        
    }

    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        detailScreen?.dateTimePicked(dtp_caller: caller, dtp_value: formatDateToString(passedDate: datePicker.date))
        dismiss(animated: true)
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    

}
