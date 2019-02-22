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
    func dataReceived(mode:String, title: String, row_id: Int)
    
    //choreTitle
    //choreImage
    //choreMusic
    //choreStartDate
    //choreEndDate
    //choreFrequency
    //choreTimesPerDay
    //choreReminderTime1
}

class ChoreDetailsController: UIViewController {
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
    
    var backscreen : CanReceive?
    
    var choreTitlePassOver : String = ""
    var modePassOver : String = ""
//DEL    var choreIDPassOver : Int = 0
    var choreRowPassOver : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choreTitle.text = choreTitlePassOver
    }
    
    @IBAction func SaveButtonPressed(_ sender: UIButton) {
        backscreen?.dataReceived(mode: modePassOver, title: choreTitle.text!, row_id: choreRowPassOver)
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


//
//class SecondViewController: UIViewController {
//
//    var backscreen : CanReceive?
//
//    var textPassOver : String = ""
//    var senderIdentifier : Int = 0
//
//
//
//    @IBOutlet weak var label: UILabel!
//
//    @IBOutlet weak var textFieldBack: UITextView!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        label.text = textPassOver
//    }
//
//
//    @IBAction func BackButtonPressed(_ sender: Any) {
//        backscreen?.dataReceived(data: textFieldBack.text, from: senderIdentifier)
//        dismiss(animated: true, completion: nil)
//
//    }
//
//
//}
//
