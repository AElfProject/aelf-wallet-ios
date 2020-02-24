//
//  FavouritesTopView.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/9.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class FavouritesTopView: UIView {

    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    
    func languageChanged() {
        
        currencyLabel.text = "Market_currency".localized()
        priceLabel.text = "Market_price".localized()
        changeLabel.text = "Market_change".localized()
    }
    
}
