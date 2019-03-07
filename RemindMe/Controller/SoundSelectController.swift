//
//  SoundSelectController.swift
//  RemindMe
//
//  Created by Kate on 1/3/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import Foundation
import UIKit

class SoundSelectorController: UITableViewController {
    
    let soundArray = ["dog_bark4.wav", "cat_meow_x.wav"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load up the array from user preferences (if we stored something in the file)
        tableView.rowHeight = 80.0
        tableView.reloadData()
        //loadItems()
        //print (dataFilePath)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "soundCell", for: indexPath)
        cell.textLabel?.text = soundArray[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ remindeTimesTable: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
    }
    
    
}

