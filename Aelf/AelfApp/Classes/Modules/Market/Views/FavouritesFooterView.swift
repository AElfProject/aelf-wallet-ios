//
//  FavouritesFooterView.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class FavouritesFooterView: UIView {

    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitlePosition(position: .right, spacing: 5)
    }

}


