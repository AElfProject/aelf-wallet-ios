//
//  AssetHistoryCell.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftyAttributes

class AssetHistoryCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cnyLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateSubviews(item: AssetHistory,price: Double) {

        fromLabel.attributedText = sourceChainText(fromChain: item.fromChainID, toChain: item.toChainID)
        iconImgView.image = UIImage(named: item.isTransfer() ? "trans_receive":"trans_transfer")
        addressLabel.text = item.isTransfer() ? item.to.elfAddress(item.toChainID) : item.from.elfAddress(item.fromChainID)
        dateLabel.attributedText = transResult(item: item)
        priceLabel.text = item.amount

        let total = (item.amount.double() ?? 0) * price
        cnyLabel.text = "≈ " + total.format() + " \(App.currency)"
        
    }

    func sourceChainText(fromChain:String, toChain:String) -> NSAttributedString {

        let att = "From".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let aChainAtt = (" " + fromChain + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.appBlack)
        let toAtt = "To".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let bChainAtt = (" " + toChain + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.appBlack)

        att.append(aChainAtt)
        att.append(toAtt)
        att.append(bChainAtt)
        return att
    }

    private func transResult(item: AssetHistory) -> NSAttributedString {

        var color: UIColor = .white
        switch item.status.int { // 1成功，0处理中，-1失败
        case 0:
            color = UIColor(hexString: "F9B74B")! // 黄色
        case 1: // category == "send"
            color = item.isTransfer() ? UIColor.master:UIColor.appBlue
        case -1:
            color = UIColor(hexString: "FF4946")! // 红色
        default:
            color = UIColor(hexString: "F9B74B")! // 黄色
        }

        let result = ("  " + (item.statusText)).withFont(UIFont.systemFont(ofSize: 10)).withTextColor(color)
        let timeAtt = TimeInterval(item.time?.int ?? 0).transTime().withFont(.systemFont(ofSize: 10)).withTextColor(.c78)
        timeAtt.append(result)

        return timeAtt
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
