//
//  ChoreDetailsController.swift
//  RemindMe
//
//  Created by Kate on 21/2/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
import Foundation

class ChoreDetailsController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var textPassOver : String = ""
    var senderIdentifier : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func SaveButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func CancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
