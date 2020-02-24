//
//  WalletWarnView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import SwiftMessages

class WalletWarnView: MessageView {

    @IBOutlet weak var contentView: UIView!
    var confirmAction: (() -> Void)?

    fileprivate class func loadWarnView() -> WalletWarnView {

        guard let v = WalletWarnView.loadFromNib(named: WalletWarnView.className) as? WalletWarnView  else {
            fatalError("加载 xib 出错！")
        }
        return v
    }

    class func show() {

        let view = WalletWarnView.loadWarnView()

        view.backgroundHeight = screenHeight

        view.confirmAction = { SwiftMessages.hide() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)

    }

    @IBAction func confirmTapped(_ sender: Any) {
        confirmAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
