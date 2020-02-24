//
//  TransactionVoucherHeaderCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class TransactionVoucherHeaderCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    var item: TransactionVoucherItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
