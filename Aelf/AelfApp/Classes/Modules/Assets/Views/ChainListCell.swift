//
//  ChainListCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/8.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class ChainListCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var arrowImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        arrowImgView?.image = UIImage(named: "arrow-right")?.template
        arrowImgView.tintColor = .white
        
        iconImgView.cornerRadius = iconImgView.height/2
        iconImgView.borderWidth = 0.5
        iconImgView.borderColor = .white
    }

    var item: ChainItem? {
        didSet {
            guard let item = item else { return }
            titleLabel.text = item.name
            bgView.backgroundColor = UIColor(hexString: item.color)
            if let url = URL(string: item.logo) {
                iconImgView.setImage(with: url)
            }
            
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
