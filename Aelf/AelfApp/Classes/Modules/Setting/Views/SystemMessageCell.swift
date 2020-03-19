//
//  SystemMessageCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class SystemMessageCell: BaseTableCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var item : MessageDetaiModel?{
        didSet {
            guard let item = item else { return }
            messageLabel.text = item.title
            contentLabel.text = item.desc
            timeLabel.text = item.createTime
            let timeStamp = item.createTime?.int ?? 0

            timeLabel.text = TimeInterval(timeStamp).transferTime()
            unreadView.isHidden = item.isDidRead()

        }
    }
    func didRead() {
        unreadView.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
