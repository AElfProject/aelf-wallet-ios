//
//  UnConfirmTransactionCell.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/1.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import FoldingCell

class UnConfirmTransactionCell: FoldingCell {
    
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    // -----
    @IBOutlet weak var source2Label: UILabel!
    @IBOutlet weak var amount2Label: UILabel!
    @IBOutlet weak var to2Label: UILabel!
    @IBOutlet weak var memo2Label: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    
    @IBOutlet weak var txID2Label: UILabel!
    @IBOutlet weak var time2Label: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    var seeMoreClosure:((UnConfirmTransactionItem?) -> ())?
    var confirmClosure:((UnConfirmTransactionItem?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        addBgShadow()
        
//        backgroundColor = UIColor.white
//        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 1
//        layer.cornerRadius = 8
//        clipsToBounds = true
        
        [toLabel,to2Label,txID2Label].forEach({ $0?.isUserInteractionEnabled = true })
        
        toLabel.addTapGesture { [weak self] (tap) in
            guard let self = self ,let item = self.item else { return }
            UIPasteboard.general.string = item.toAddress.elfAddress(item.toChain)
            SVProgressHUD.showSuccess(withStatus: "Copied")
        }
        to2Label.addTapGesture { [weak self] (tap) in
            guard let self = self ,let item = self.item else { return }
            UIPasteboard.general.string = item.toAddress.elfAddress(item.toChain)
            SVProgressHUD.showSuccess(withStatus: "Copied")
        }
        
        txID2Label.addTapGesture { [weak self] (tap) in
            guard let self = self ,let item = self.item else { return }
            UIPasteboard.general.string = item.txid
            SVProgressHUD.showSuccess(withStatus: "Copied")
        }
    }
    
    var item: UnConfirmTransactionItem? {
        didSet {
            guard let item = item else { return }
            
            timeLabel.text = TimeInterval(item.time.double).transTime()
            sourceLabel.attributedText = sourceChainText(symbol: item.symbol,fromChain: item.fromChain, toChain: item.toChain)
            amountLabel.text = item.amount
            toLabel.attributedText = toAttributed()
            
            ///
            source2Label.attributedText = sourceChainText(symbol: item.symbol,fromChain: item.fromChain, toChain: item.toChain)
            amount2Label.text = item.amount
            to2Label.attributedText = toAttributed()
            txID2Label.attributedText = txIDAttributed()
            
            memo2Label.attributedText = memoAttributed()
            
            time2Label.text = TimeInterval(item.time.double).transTime()
        }
    }
    
    
    func toAttributed() -> NSAttributedString {
        guard let item = item else { return NSAttributedString() }
        let toAtt = ("To".localized() + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let addressAttr = item.toAddress.elfAddress(item.toChain).withFont(.systemFont(ofSize: 13, weight: .regular)).withTextColor(.appBlack)
        return toAtt + addressAttr + " " + copyAttributed()
    }
    
    func fromAttributed() -> NSAttributedString {
        guard let item = item else { return NSAttributedString() }
        let fromAtt = "From".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let addressAttr = item.fromAddress.elfAddress(item.fromChain).withFont(.systemFont(ofSize: 13, weight: .regular)).withTextColor(.appBlack)
        return fromAtt + " " + addressAttr + " " + copyAttributed()
    }
    
    func memoAttributed() -> NSAttributedString {
        guard let item = item else { return NSAttributedString() }
        let att = "Memo".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)

        let memoAttr = item.memo.withFont(.systemFont(ofSize: 13, weight: .regular)).withTextColor(.appBlack)
        return att + " " + memoAttr
    }
    
    func txIDAttributed() -> NSAttributedString {
        guard let item = item else { return NSAttributedString() }
        let att = "TxID".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let txIDAttr = item.txid.withFont(.systemFont(ofSize: 15, weight: .regular)).withTextColor(.appBlack)
        return att + " " + txIDAttr + " " + copyAttributed()
    }
    
    func copyAttributed() -> NSAttributedString {
        let ach = NSTextAttachment()
        ach.image = UIImage(named: "address_copy")
        ach.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        return NSAttributedString(attachment: ach)
    }
    
    func sourceChainText(symbol: String,fromChain:String, toChain:String) -> NSAttributedString {
        
        let symbolAtt = (symbol + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.appBlack)
        
        let fromAtt = "From".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let aChainAtt = (" " + fromChain + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.appBlack)
        let toAtt = "To".localized().withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.c78)
        let bChainAtt = (" " + toChain + " ").withFont(.systemFont(ofSize: 12)).withTextColor(UIColor.appBlack)
        
        return symbolAtt + " " + fromAtt + aChainAtt + toAtt + bChainAtt
    }
    
    
    @IBAction func seeMoreTapped(_ sender: UIButton) {
        seeMoreClosure?(item)
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        confirmClosure?(item)
    }
    
    
    func addBgShadow() {
        
        //        bgView.backgroundColor = UIColor.white
        //        bgView.layer.cornerRadius = 10
        //        bgView.layer.shadowOffset = CGSize(width: 0, height: 2)
        //        bgView.layer.shadowRadius = 2
        //        bgView.layer.shadowOpacity = 0.25
        //        bgView.layer.shadowColor = UIColor.black.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type: FoldingCell.AnimationType) -> TimeInterval {
//        let durations: [TimeInterval] = [0.35, 0.35, 0.35,0.35]
//        return durations[itemIndex]
        return 0.35
    }
    
}
