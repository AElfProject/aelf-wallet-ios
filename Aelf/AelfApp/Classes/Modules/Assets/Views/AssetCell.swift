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
                let balance = item.balance
                topLabel.text = classfuncdeleteInvalidNum(num: balance)
                bottomLabel.text = item.total().format(maxDigits: 8, mixDigits: 2) + " \(App.currency)"
            }
            
            if let url = URL(string: item.logo) {
                self.iconImgView.setImage(with: url)
            } else {
                iconImgView.image = UIImage(named: "")
            }
        }
    }
    
    func classfuncdeleteInvalidNum(num: String) -> String {
        var outNumber = num
        var i = 1
        if num.contains(".") {
            while i < num.count {
                if outNumber.hasPrefix("0") {
                    outNumber.remove(at: outNumber.index(before: outNumber.endIndex))
                    i = i + 1
                } else {
                    break
                }
            }
            if outNumber.hasSuffix(".") {
                outNumber.remove(at: outNumber.index(before: outNumber.endIndex))
            }
            return outNumber
        } else {
            return num
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
