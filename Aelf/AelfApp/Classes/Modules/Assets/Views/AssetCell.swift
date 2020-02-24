//
//  AssetCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class AssetCell: BaseTableCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var coinLabel: UILabel!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: AssetItem? {
        didSet {
            guard let item = item else { return }

            coinLabel.text = item.symbol
            
            if App.isPrivateMode {
                topLabel.text = "*****"
                bottomLabel.text = "*****" + " \(App.currency)"
            }else {
                topLabel.text = item.balance
                bottomLabel.text = item.total().format(maxDigits: 8, mixDigits: 8) + " \(App.currency)"
            }
            
            if let url = URL(string: item.logo) {
                self.iconImgView.setImage(with: url)
            } else {
                iconImgView.image = UIImage(named: "")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
