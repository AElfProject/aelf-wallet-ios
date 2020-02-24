//
//  InputAlertView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import SwiftMessages

enum InputType {
    /// 确认密码
    case confirmPassword
    /// 编辑钱包名称
    case editUserName
    
}

class InputAlertView: MessageView {
    
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var forgetButtonHeight: NSLayoutConstraint!
    
    
    var config = SwiftMessages.defaultConfig
    
    var type: InputType? {
        didSet {
            guard let type = type else { return }
            switch type {
            case .confirmPassword:
                titleLabel?.text = "Please input password".localized()
                pwdField.placeholder = "Please input wallet password".localized()
                
                if #available(iOS 11.0, *) {
                    pwdField.textContentType = .password
                }
                #if DEBUG
                pwdField.text = "111111111aA!"
                #endif
                
                self.forgetButton.setTitle("Forgot password".localized(), for: .normal)
                self.forgetButtonHeight.constant = 35
                self.forgetButton.isHidden = false
                
            case .editUserName:
                titleLabel?.text = "Please input wallet name".localized()
                pwdField.placeholder = "Wallet name".localized()
                pwdField.rx.text.orEmpty.map({ $0[0..<WalletInputLimit.nameRange.upperBound - 1]})
                    .bind(to: pwdField.rx.text).disposed(by: rx.disposeBag)
                pwdField.isSecureTextEntry = false
                if #available(iOS 11.0, *) {
                    pwdField.textContentType = .username
                }
                
                self.forgetButtonHeight.constant = 0
                self.forgetButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        confirmButton.cornerRadius = confirmButton.height/2
    }
    
    var confirmAction: (() -> Void)?
//    var forgotAction: (() -> Void)?
    
    class func show(inputType: InputType,confirmClosure: ((InputAlertView) -> Void)?) {
        
        guard let view = InputAlertView.loadFromNib(named: InputAlertView.className) as? InputAlertView else { return }
        view.backgroundHeight = inputType == .confirmPassword ? 278:238
        view.type = inputType
        view.confirmAction = { confirmClosure?(view) }
        
        view.config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        view.config.duration = .forever
        view.config.presentationStyle = .center
        view.config.dimMode = .gray(interactive: true)
        view.config.keyboardTrackingView = KeyboardTrackingView()
        view.config.interactiveHide = false
        SwiftMessages.show(config: view.config, view: view)
        
    }
    
    func hide() {
        self.endEditing(true)
        SwiftMessages.hide(animated: false)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        config.dimMode = .gray(interactive: true)
        confirmAction?()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        hide()
    }
    
    @IBAction func forgetButtonTapped(_ sender: UIButton) {
        
        hide()
        SecurityWarnView.show(title: "Forgot password Warning".localized(), centerTitle: true, body: nil, interactive: true, confirmTitle: "Confirm".localized()) {
            App.clearAppData()
            self.logoutSuccessful()
        }
    }
    
    func logoutSuccessful() {
        asyncMainDelay(duration: 0.2, block: {
            BaseTableBarController.resetImportRootController()
        })
    }
    
    func showHint() {
        
        let hint = AElfWallet.walletAccount().hint
        guard hint.length > 0 else { return }
        
        let s = App.languageID == "en" ? ":":"："
        hintLabel.text = "Password Hint".localized() + s + hint
        hintLabel.shake()
        
    }
    
}
