//
//  TextPickerViewController.swift
//  RemindMe
//
//  Created by Kate on 28/3/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit
protocol TXReceive {
    func textPicked(tp_caller : String, tp_value : String)
}
class TextPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    var caller : String = ""
    var defaultValue : String = ""
    var listArray : [String] = []
    
    //Segue Protocol
    var cHdetailScreen : TXReceive?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TextPickerViewController.viewTapped(gestureRecogniser:)))
        view.addGestureRecognizer(tapGesture)
        
        textPicker.delegate = self
        textPicker.dataSource = self

        if caller ==  "frequency" {
            titleLabel.text = "Select Frequency"
        }
        print ("List Array \(listArray)")
    }
    
    @objc func viewTapped(gestureRecogniser: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return listArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaultValue = listArray[row]
    }
    

    @IBAction func saveButtonPressed(_ sender: Any) {
        cHdetailScreen?.textPicked(tp_caller: caller, tp_value: defaultValue)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

    
