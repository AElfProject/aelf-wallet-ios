//
//  DappGameCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class DappGameCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: DiscoverDapp? {
        didSet {
            guard let item = item else { return }

            nameLabel.text = item.name
            descLabel.text = item.desc
            if let url = URL(string: item.logo)  {
                iconImgView.setImage(with: url)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
