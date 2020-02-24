//
//  DappSignConfirmView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/15.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftMessages

class DappSignConfirmView: MessageView {

    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinDescLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        pwdField.placeholder = "Please input wallet password".localized()
        pwdField.rx.text.orEmpty.map({ $0[0..<pwdLengthMax]})
            .bind(to: pwdField.rx.text).disposed(by: rx.disposeBag)
        if #available(iOS 11.0, *) {
            pwdField.textContentType = .password
        }
        #if DEBUG
        pwdField.text = "111111111aA!"
        #endif
        
        joinButton.setTitle("Dapp join White list".localized(), for: .normal)
        joinButton.setTitlePosition(position: .right, spacing: 15)
        
    }
    
    var confirmAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    class func show(content: String,confirmClosure: ((DappSignConfirmView) -> Void)?,cancelClosure: (() -> Void)?) {
        
        guard let view = DappSignConfirmView.loadFromNib(named: DappSignConfirmView.className) as? DappSignConfirmView else { return }
        view.updateTextView(content: content)

        view.confirmAction = { confirmClosure?(view) }
        view.cancelAction = { cancelClosure?() }
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)
        
    }
    
    var isJoined: Bool {
        return joinButton.isSelected
    }
    
    func updateTextView(content: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 7
        let att = content.withFont(.systemFont(ofSize: 15)).colored(with: .c78).withParagraphStyle(style)
        textView.attributedText = att
        
        let size = textView.sizeThatFits(CGSize(width: screenWidth - 30*4, height: CGFloat.greatestFiniteMagnitude))
        
        textViewHeight.constant = size.height > 250 ? 250:size.height
    }
    
    func hide() {
        self.endEditing(true)
        SwiftMessages.hide(animated: true)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        hide()
        cancelAction?()
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func confirmTapped(_ sender: Any) {
        
        confirmAction?()
    }
    
    func showHint() {
        
        let hint = AElfWallet.walletAccount().hint
        guard hint.length > 0 else { return }
        
        let s = App.languageID == "en" ? ":":"："
        hintLabel.text = "Password Hint".localized() + s + hint
        hintLabel.shake()
        
    }
}
