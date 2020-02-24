//
//  SettingCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/5/30.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AccountItemCell: BaseTableCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var settingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
