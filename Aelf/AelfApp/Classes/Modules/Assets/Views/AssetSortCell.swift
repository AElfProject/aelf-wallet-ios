//
//  AssetSortCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/13.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class AssetSortCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
