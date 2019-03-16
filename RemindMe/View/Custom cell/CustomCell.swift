//
//  CustomCell.swift
//  RemindMe
//
//  Created by Kate on 15/3/19.
//  Copyright © 2019 Kate Guru. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet var ChoreImage: UIImageView!
    @IBOutlet var ChoreTitleLabel: UILabel!
    @IBOutlet var NextReminderTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
        
    }
}
