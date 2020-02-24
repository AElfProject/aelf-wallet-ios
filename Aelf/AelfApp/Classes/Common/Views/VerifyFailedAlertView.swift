//
//  VerifyFailedView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/7/8.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftMessages

class VerifyFailedAlertView: MessageView {

    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tryAgainButton: UIButton!

    var tryAgaginClosure: (() -> Void)?

    class func show(tryAgainClosure: (() -> Void)?) {

        guard let view = VerifyFailedAlertView.loadFromNib(named: VerifyFailedAlertView.className) as? VerifyFailedAlertView else { return }
        view.tryAgaginClosure = tryAgainClosure

        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: true)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)

    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.frame = screenBounds
        cancelButton.cornerRadius = cancelButton.height/2
        tryAgainButton.cornerRadius = tryAgainButton.height/2

        if BioMetricAuthenticator.shared.faceIDAvailable() {
            titleLabel?.text = "Fingerprint Verfication Failed".localized()
            iconImgView.image = UIImage(named: "faceid_small")
        } else if BioMetricAuthenticator.shared.touchIDAvailable() {
            titleLabel?.text = "Face Verfication Failed".localized()
            iconImgView.image = UIImage(named: "touchid_small")
        }else {
            titleLabel?.text = "Verfication Failed".localized()
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        SwiftMessages.hide()
    }
    
    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        SwiftMessages.hide()
        tryAgaginClosure?()
    }
}
