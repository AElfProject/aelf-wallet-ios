//
//  SecurityWarnView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages

class SecurityWarnView: MessageView {
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var buttonbottom: NSLayoutConstraint!
    
    var confirmAction: (() -> Void)?
    
    override func awakeFromNib() {
        confirmButton.cornerRadius = 15
        buttonbottom.constant = isIphoneX ? 34:15
    }
    // Security Warning
    // You have not backed up
    // Backup Now
    
    class func show(title: String?,
                    centerTitle: Bool = false,
                    body: String?,
                    interactive: Bool = false,
                    confirmTitle: String,confirmClosure: (() -> Void)?) {
        
        guard let view = SecurityWarnView.loadFromNib(named: SecurityWarnView.className) as? SecurityWarnView else { return }
        view.titleLabel?.text = title
        view.titleLabel?.textAlignment = centerTitle ? .center:.left
        view.bodyLabel?.text = body
        view.confirmButton.setTitle(confirmTitle, for: .normal)
        
        view.confirmAction = { confirmClosure?() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .bottom
        
        config.dimMode = .gray(interactive: interactive)
        config.keyboardTrackingView = KeyboardTrackingView()
        
        SwiftMessages.show(config: config, view: view)
        
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        SwiftMessages.hide(animated: false)
        confirmAction?()
    }
    
    static func isCanShow() -> Bool {
        guard let window = UIApplication.shared.keyWindow else { return false }
        var isCan = true
        window.subviews.forEach({
//            debugPrint("当前类：\($0)")
            if $0.isKind(of: VerifyIdentityView.self) {
                isCan = false
            }
        })
        return isCan
    }
}
