//
//  DiscoverRecordCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

// 交易记录 Cell
class DiscoverRecordCell: BaseTableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    var item: DiscoverItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.name
            subTitleLabel.text = item.fullName
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
