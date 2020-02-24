//
//  DappConfirmView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/15.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages

class DappConfirmView: MessageView {

    @IBOutlet weak var cancelButon: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    var confirmAction: (() -> Void)?
    
    class func show(title: String?,content: String?, confirmClosure: ((DappConfirmView) -> Void)?) {
        
        let view = DappConfirmView.loadFromNib(named: DappConfirmView.className) as! DappConfirmView
        view.titleLabel?.text = title
        view.configureAttribute(content: content)
        
        view.confirmAction = { confirmClosure?(view) }
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)

    }
    
    func configureAttribute(content: String?) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        let att = content?.withFont(.systemFont(ofSize: 15)).colored(with: .c78).withParagraphStyle(style)
        bodyLabel?.attributedText = att
    }
    
    func hide() {
        SwiftMessages.hide(animated: false)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        hide()
        
        confirmAction?()
    }
    
}
