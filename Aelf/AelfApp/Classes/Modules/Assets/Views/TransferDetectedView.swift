//
//  TransferDetectedView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/29.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages

class TransferDetectedView: MessageView {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!

    @IBOutlet weak var confirmButton: UIButton!

    var confirmAction: (() -> Void)?

    class func show(fromChain: String, toChain:String, confirmClosure: (() -> Void)?) {

        let view = TransferDetectedView.loadFromNib(named: TransferDetectedView.className) as! TransferDetectedView
        view.fromLabel.text = fromChain
        view.toLabel.text = toChain

        view.confirmAction = confirmClosure
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .center

        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)
    }


    @IBAction func confirmTapped(_ sender: UIButton) {
        SwiftMessages.hide(animated: false)
        confirmAction?()
    }

}
