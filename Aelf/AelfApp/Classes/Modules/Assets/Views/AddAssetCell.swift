//
//  AddAssetCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AddAssetCell: UITableViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var didAddClosure: ((AssetInfo) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
    }
    
    var item: AssetInfo? {
        didSet {
            guard let item = item else { return }
            
            if App.assetMode == .chain {
                coinLabel.text = item.symbol
            } else {
                coinLabel.text = item.chainID + "-" + item.symbol
            }
            
            addressLabel.text = item.contractAddress
            addButton.isSelected = item.aIn == 1
            balanceLabel.text = "Balance".localized() + ": " + (item.balance ?? "")
            
            if let url = URL(string: item.logo ?? "") {
                iconImgView.setImage(with: url, placeholder: nil)
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let item = item else { return }
        didAddClosure?(item)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
