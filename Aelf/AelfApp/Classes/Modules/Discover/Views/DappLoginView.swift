//
//  DappLoginView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/15.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftMessages

class DappLoginView: MessageView {
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var subTitleLabel: UILabel!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var confirmAction: (() -> Void)?
    
    class func show(content: String?, confirmClosure: ((DappLoginView) -> Void)?) {
        
        let view = DappLoginView.loadFromNib(named: DappLoginView.className) as! DappLoginView
        view.bodyLabel?.text = content
        
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
    
    func hide() {
        SwiftMessages.hide(animated: false)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        hide()
    }
    
    @IBAction func confirmTapped(_ sender: UIButton) {
        hide()
        
        confirmAction?()
    }
    
}
