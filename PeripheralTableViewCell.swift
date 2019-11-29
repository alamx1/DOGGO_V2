//
//  PeripheralTableViewCell.swift
//  DOGGO-redo
//
//  Created by Alam Figueroa Aguilar on 11/18/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import UIKit

class PeripheralTableViewCell: UITableViewCell {

    @IBOutlet weak var peripheralLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
