//
//  AddressBookCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AddressBookCell: YFTableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.bringSubviewToFront(addressLabel)
    }
   
    
    func setupWithItem(_ item: AddressBookItemModel) {
        nameLabel.text = item.name
        if let _ = item.address?.chainID() {
            addressLabel.text = item.address
        }else {
            addressLabel.text = item.address?.elfAddress()
        }
        self.contentView.bringSubviewToFront(addressLabel)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
