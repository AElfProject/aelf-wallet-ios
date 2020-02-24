//
//  DiscoverGameCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

/// 推荐的游戏 item cell
class DiscoverGameCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: DiscoverDapp? {
        didSet {
            guard let item = item else { return }

            nameLabel.text = item.name
            if let url = URL(string: item.logo) {
                imgView.setImage(with: url)
            }
        }
    }

}
