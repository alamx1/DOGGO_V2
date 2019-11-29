//
//  PetTableViewCell.swift
//  DOGGO-redo
//
//  Created by Michelle Natasha on 11/6/19.
//  Copyright © 2019 Michelle Natasha. All rights reserved.
//

import UIKit

class PetTableViewCell: UITableViewCell {

    //MARK: properties
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
