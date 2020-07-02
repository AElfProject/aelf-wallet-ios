//
//  SwitchNetworkTableCell.swift
//  AelfApp
//
//  Created by yuguo on 2020/6/28.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import UIKit

class SwitchNetworkTableCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var chooseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var item: NetworkModel? {
        didSet {
            guard let item = item else { return }
            if App.languageID == "zh-cn" {
                //中文
                nameLabel.text = item.name
            } else {
                //英文
                nameLabel.text = item.nameEn
            }
            chooseButton.isSelected = item.selected
            nameLabel.textColor = UIColor.init(hexString: item.selected ? "5D1CAD" : "7A8089")
            nameLabel.font = UIFont.systemFont(ofSize: 15, weight: item.selected ? .semibold : .regular)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
