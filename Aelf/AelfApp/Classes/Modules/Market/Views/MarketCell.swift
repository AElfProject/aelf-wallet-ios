//
//  MarketCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class MarketCell: BaseTableCell {

    @IBOutlet weak var trendImageView: UIImageView!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var symbol: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    var item : MarketCoinModel? {
        didSet {
            guard let item = item else { return }
            symbol.text = item.name?.uppercased()
            priceLabel.text = App.currencySymbol + String(item.lastPrice ?? "")
            let increase = item.increase?.double() ?? 0.0
            // 返回数据 < 0 带 - 号
            let format = (increase > 0 ? "+" : "") + String(format: "%.2f",increase) + "%"
            changeLabel.text = format
            if increase > 0 {
                changeLabel.backgroundColor = .appGreen
            } else {
                changeLabel.backgroundColor = .appRed
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
