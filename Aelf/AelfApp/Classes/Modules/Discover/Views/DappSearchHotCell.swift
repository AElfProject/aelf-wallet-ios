//
//  DappSearchHotCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2020/2/22.
//  Copyright © 2020 AELF. All rights reserved.
//

import UIKit

class DappSearchHotCell: UITableViewCell {

    @IBOutlet var idxLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    
    func updateContent(idx: Int, name: String) {
        
        titleLabel.text = name
        idxLabel.text = (idx + 1).string
        
        if idx == 0 || idx == 1 {
            idxLabel.textColor = UIColor.red
        } else if idx == 2 {
            idxLabel.textColor = UIColor.orange
        }else {
            idxLabel.textColor = UIColor.c78
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
