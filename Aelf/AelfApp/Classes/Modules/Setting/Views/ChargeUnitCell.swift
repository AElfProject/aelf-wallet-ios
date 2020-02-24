//
//  ChargeUnitCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/9.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class ChargeUnitCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var arrowImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        // Initialization code
    }
    var item: CurrencyItemModel? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.id ?? ""
           // titleLabel.text = (item.name ?? "") + " (\(item.id ?? ""))"
            
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
