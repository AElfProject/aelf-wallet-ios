//
//  MarketManagerCell.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/6.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class MarketManagerCell: UITableViewCell {


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topButton: UIButton!

    var topClosure: ((MarketCoinModel) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: MarketCoinModel? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = item.symbol?.uppercased()
            
        }
    }

    @IBAction func topButtonTapped(_ sender: UIButton) {

        if let item = item {
            topClosure?(item)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
