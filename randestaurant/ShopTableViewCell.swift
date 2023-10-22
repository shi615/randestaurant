//
//  ShopTableViewCell.swift
//  randestaurant
//
//  Created by 石智光 on 2023/10/20.
//

import UIKit

class ShopTableViewCell: UITableViewCell {
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var tellPhoneLabel: UILabel!
    @IBOutlet weak var webSiteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
