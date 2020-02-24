//
//  PasswordHintController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/13.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class PasswordHintController: BaseController {

    @IBOutlet weak var hintTF: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        title = "Password Hint".localized()
        hintTF.text  = AElfWallet.walletAccount().hint
        addRightNavItem()
    }

    func addRightNavItem() {
        
        let btn = UIButton.init(type: .custom)
        btn.setTitle("Done".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.isEnabled = false
        btn.setTitleColor(.master, for: .normal)
        btn.addTarget(self, action:#selector(self.doneAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        
    }

    @objc func doneAction() {
        
        SecurityVerifyManager.verifyPaymentPassword(completion: { [weak self] (pwd) in
            if let _ = pwd {
                let walletAccount = AElfWallet.walletAccount()
                walletAccount.hint = self?.hintTF.text ?? ""
                AElfWallet.saveAccount(account: walletAccount)
                self?.navigationController?.popViewController(animated: true)
            }
        })
        
    }
}
