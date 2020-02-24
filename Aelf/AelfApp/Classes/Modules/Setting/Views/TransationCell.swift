//
//  TransationCell.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class TransationCell: BaseTableCell {


    @IBOutlet weak var chainLabel: UILabel!
    @IBOutlet weak var receipentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var transStatusLabel: UILabel!
    @IBOutlet weak var transLabel: UILabel!
    @IBOutlet weak var transImgView: UIImageView!
    @IBOutlet weak var unReadView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

    var item : AssetHistory? {
        didSet {
            guard let item = item else { return }
            transStatusLabel.text = item.statusText
            
            transLabel.text = item.symbol.uppercased() + ": " + item.amount
            
            var color: UIColor = .white
            switch item.status.int { // 1成功，0处理中，-1失败
            case 0:
                color = UIColor(hexString: "F9B74B")! // 黄色
            case 1: // category == "send"
                color = item.isTransfer() ? UIColor.master:UIColor.appBlue
            case -1:
                color = UIColor(hexString: "FF4946")! // 红色
            default:
                color = UIColor(hexString: "F9B74B")!
            }
            transStatusLabel.textColor = color
            
            if item.isTransfer(){
                addressLabel.text = item.to.elfAddress(item.toChainID)
                receipentLabel.text = "Receipent Address".localized() + ": "
                transImgView.image = UIImage(named: "trans_receive")
            } else {
                addressLabel.text = item.from.elfAddress(item.fromChainID)
                receipentLabel.text = "Transfer Address".localized() + ": "
                transImgView.image = UIImage(named: "trans_transfer")
            }
             
            unReadView.isHidden = item.isDidRead()
            
            chainLabel.attributedText = sourceChainText(fromChain: item.fromChainID, toChain: item.toChainID)
            
            let timeStamp = item.time?.int ?? 0
            timeLabel.text = TimeInterval(timeStamp).transTime()
        }
    }
    

    func didRead() {
        unReadView.isHidden = true
    }
    
    func sourceChainText(fromChain:String, toChain:String) -> NSAttributedString {
        
        let att = "From".localized().withFont(.systemFont(ofSize: 10)).withTextColor(UIColor.c78)
        let aChainAtt = (" " + fromChain + " ").withFont(.systemFont(ofSize: 10)).withTextColor(UIColor.appBlack)
        let toAtt = "To".localized().withFont(.systemFont(ofSize: 10)).withTextColor(UIColor.c78)

        let bChainAtt = (" " + toChain + " ").withFont(.systemFont(ofSize: 10)).withTextColor(UIColor.appBlack)
        
        att.append(aChainAtt)
        att.append(toAtt)
        att.append(bChainAtt)
        return att
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
