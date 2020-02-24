//
//  AppUpdateView.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/26.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages
import SwiftyAttributes

class AppUpdateView: MessageView {
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var laterButton: UIButton!
    
    var config = SwiftMessages.defaultConfig
    
    override func awakeFromNib() {
    }
    
    var confirmAction: (() -> Void)?
    
    class func show(appUpdate: AppVersionUpdate,confirmClosure: ((AppUpdateView) -> Void)?) {
        
        guard let view = AppUpdateView.loadFromNib(named: AppUpdateView.className) as? AppUpdateView else { return }
       
        view.confirmAction = { confirmClosure?(view) }
        view.versionLabel.text = "New Version".localizedFormat(appUpdate.verNo)
        
        view.backgroundHeight = 220 + view.textStyle(appUpdate: appUpdate).height
        view.config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        view.config.duration = .forever
        view.config.presentationStyle = .center
        view.config.dimMode = .gray(interactive: true)
        view.config.keyboardTrackingView = KeyboardTrackingView()
        view.config.interactiveHide = false
        SwiftMessages.show(config: view.config, view: view)
        
    }

    func textStyle(appUpdate: AppVersionUpdate) -> CGSize {

        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 10
        var text = ""
        for (index,value) in (appUpdate.intro ?? []).enumerated() {
            if value == appUpdate.intro?.last { // last
                text.append("\(index + 1). \(value)")
            }else {
                text.append("\(index + 1). \(value)\n")
            }
        }

        let attri = text.withFont(.systemFont(ofSize: 13)).withTextColor(.c78).withParagraphStyle(paraph)
        self.desLabel.attributedText = attri
        let textRect = self.desLabel.sizeThatFits(CGSize(width: 250, height: CGFloat.greatestFiniteMagnitude))
        return textRect
    }
    
    func hide() {
        self.endEditing(true)
        SwiftMessages.hide()
    }
    
    @IBAction func laterAction(_ sender: Any) {
        self.hide()
    }
    @IBAction func confirmTapped(_ sender: Any) {
        self.hide()
        confirmAction?()
    }
    
}
