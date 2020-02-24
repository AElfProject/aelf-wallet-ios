//
//  TransactionVoucherFooterCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/10.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class TransactionVoucherFooterCell: UITableViewCell {

    var confirmClosure: (() -> ())?

    @IBOutlet weak var confirmButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    @IBAction func confirmTapped(_ sender: UIButton) {

        confirmClosure?()
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
