//
//  BaseTableCell.swift
//
//  Created by 晋先森 on 16/12/19.
//  Copyright © 2016年 晋先森. All rights reserved.
//

import UIKit

class BaseTableCell: UITableViewCell {

    lazy var selectBgView: UIView = {
        $0.frame = CGRect(x: 0, y: 5,
                          width: self.contentView.frame.size.width,
                          height: self.contentView.frame.size.height - 10)
        $0.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return $0
    }(UIView())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        config()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
        config()
    }

    private func config() {

        self.selectedBackgroundView = self.selectBgView
        self.selectionStyle = .none
//        accessoryType = .disclosureIndicator
        textLabel?.textColor = .gray
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.numberOfLines = 0

        detailTextLabel?.textColor = .gray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)

        detailTextLabel?.adjustsFontSizeToFitWidth = true
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
