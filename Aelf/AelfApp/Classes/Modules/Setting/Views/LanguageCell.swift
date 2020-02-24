//
//  LanguageCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class LanguageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var arrowImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none

        // Initialization code
    }

    var item: LanguageItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.displayName

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
