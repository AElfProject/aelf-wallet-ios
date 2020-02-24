//
//  AElfAlertView.swift
//  AelfApp
//
//  Created by jinxiansen on 2019/7/11.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import SwiftMessages

class AElfAlertView: MessageView {

    @IBOutlet weak var cancelButton: UIButton!

    var confirmAction: (() -> Void)?

    override func awakeFromNib() {

    }

    class func show(title: String?,subTitle: String?,confirmClosure: (() -> Void)?) {

        guard let view = AElfAlertView.loadFromNib(named: AElfAlertView.className) as? AElfAlertView else { return }
        view.titleLabel?.text = title
        view.bodyLabel?.text = subTitle
        view.confirmAction = { confirmClosure?() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        config.interactiveHide = false

        SwiftMessages.show(config: config, view: view)

    }



    @IBAction func cancelTapped(_ sender: UIButton) {
        SwiftMessages.hide()
    }

    @IBAction func confirmTapped(_ sender: UIButton) {
        SwiftMessages.hide()
        confirmAction?()
    }

}
