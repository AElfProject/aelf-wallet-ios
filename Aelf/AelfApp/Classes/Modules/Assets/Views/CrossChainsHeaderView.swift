//
//  CrossChainsHeaderView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class CrossChainsHeaderView: UIView {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!

    @IBOutlet weak var totalHeight: NSLayoutConstraint!

    var type: CrossChainType = .present
    var selectedChainClosure: (() -> ())?
 
    override func awakeFromNib() {

        setupUI()
    }

    func setupUI() {
        totalTitleLabel.text = "Total Assets".localized()
    }

    static func instance(type: CrossChainType, symbol: String?) -> CrossChainsHeaderView {
        let v = CrossChainsHeaderView.loadFromNib(named: CrossChainsHeaderView.className) as! CrossChainsHeaderView
        v.type = type
        if type == .present {
            v.totalHeight.constant = 70
            v.sectionLabel.text = "Current identity is in following chains".localized()
        } else {
            v.totalHeight.constant = 0
            v.sectionLabel.text = "%@ is in following chains:".localizedFormat(symbol ?? "ELF")
        }
        return v
    }

    func updateSubViews(totalAmount: String,totalPrice: String) {
        if App.isPrivateMode {
            totalLabel.text = "*****"
            currentLabel.text = "*****"
        }else {
            totalLabel.text = totalAmount
            currentLabel.text = totalPrice
        }
    }

    func contentHeight() -> CGFloat {
        return type == .present ? 200:110
    }
 
}
