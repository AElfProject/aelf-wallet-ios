//
//  ShareTableCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/7/5.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class ShareTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!



    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: ShareType? {
        didSet {
            guard let item = item else { return }

            titleLabel.text = item.localized
            subTitleLabel.text = item.link
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
