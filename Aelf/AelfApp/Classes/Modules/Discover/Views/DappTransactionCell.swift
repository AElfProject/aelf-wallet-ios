//
//  DappTransactionCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/16.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class DappTransactionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        valueLabel.addTapGesture { [weak self] (tap) in
            UIPasteboard.general.string = self?.valueLabel.text
            logDebug(self?.valueLabel.text)
            SVProgressHUD.showSuccess(withStatus: "Copied")
        }
    }

    var item: DappTransactionItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.title

            valueLabel.isUserInteractionEnabled = item.enableCopy
            valueLabel.numberOfLines = item.enableLines ? 0:1
            valueLabel.lineBreakMode = item.enableLines ? NSLineBreakMode.byTruncatingTail:.byTruncatingMiddle

            if let value = item.value as? NSAttributedString {
                valueLabel.attributedText = value
            } else if let value = item.value as? String {
                valueLabel.text = value
            } else {
                valueLabel.text = nil
            }

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
