//
//  MarketSearchCell.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class MarketSearchCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: MarketCoinModel? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = item.name
            priceLabel.text = App.currencySymbol + String(item.lastPrice ?? "")

            favouriteButton.isSelected = item.exist()
        }
    }

    @IBAction func favouriteButtonTapped(_ sender: Any) {

        guard let item = item else { return }
        if item.exist() {
            item.delete()
            favouriteButton.isSelected = false
        } else {
            item.save()
            favouriteButton.isSelected = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
