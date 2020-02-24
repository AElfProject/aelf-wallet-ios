//
//  ChooseChainCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class ChooseChainCell: BaseTableCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var chainNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImgView.cornerRadius = iconImgView.height/2
        iconImgView.borderWidth = 0.5
        iconImgView.borderColor = .white
    }

    var item: AssetItem? {
        didSet {
            guard let item = item else { return }
            chainNameLabel.text = item.chainID + "-" + item.symbol
            
            bgView.backgroundColor = UIColor(hexString: item.color)
            if App.isPrivateMode {
                priceLabel.text = "*****"
                amountLabel.text = "***** \(App.currency)"
            } else {
                priceLabel.text = item.balanceDouble().format()

                amountLabel.text = "\(String(format: "%.3f", item.total())) \(App.currency)"

            }
            if let url = URL(string: item.logo) {
                iconImgView.setImage(with: url)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
