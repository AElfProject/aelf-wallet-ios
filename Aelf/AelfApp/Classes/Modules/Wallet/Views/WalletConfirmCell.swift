//
//  WalletConfirmCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class WalletConfirmCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        bgView.cornerRadius = 8

        aSelected = false
    }

    var aSelected = false {
        didSet {
            if aSelected {
                bgView.backgroundColor = UIColor(hexString: "#ADB6C4")
                titleLabel.textColor = UIColor.white
            } else {
                bgView.backgroundColor = UIColor(hexString: "#F3F5F9")
                titleLabel.textColor = UIColor.black
            }
        }
    }

}
