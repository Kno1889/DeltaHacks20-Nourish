//
//  PlaceTableViewCell.swift
//  Nourish
//
//  Created by user on 1/26/20.
//  Copyright © 2020 Abdel Rahman Ellithy. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var closest: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
