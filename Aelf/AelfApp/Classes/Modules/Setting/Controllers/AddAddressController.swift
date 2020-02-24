//
//  AddAddressController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Validator

struct EditContactItem {
    var name: String
    var note: String?
    var address: String
}

class AddAddressController: BaseController {

    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var remarkTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    var rightBtn :UIButton?
    
    var editItem: EditContactItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        addRightNavItem()

        bindEvent()
    }

    override func languageChanged() {

        nameTF.placeholder = "Please enter contact name".localized()
        remarkTF.placeholder = "Remark (optional)".localized()
        addressTF.placeholder = "Enter a valid address".localized()
        
        if let item = editItem {
            title = "Edit Contact".localized()
            nameTF.text = item.name
            remarkTF.text = item.note
            addressTF.text = item.address
        }else {
            title = "New Contact".localized()
        }
    }

    func bindEvent() {

        nameTF.rx.text.orEmpty.map({ $0.removingEmoji() }).bind(to:  nameTF.rx.text).disposed(by: rx.disposeBag)
        addressTF.rx.text.orEmpty.map({ $0.removingEmoji() }).bind(to:  addressTF.rx.text).disposed(by: rx.disposeBag)
        
    }
    
    @IBAction func scanAction(_ sender: Any) {
        
        guard UIApplication.isAllowCamera() else {
            SVProgressHUD.showInfo(withStatus: "Scanning QR code requires camera permissions".localized())
            return
        }
        
        let qr = QRScannerViewController()
        qr.scanType = .addressScan
        self.push(controller: qr)
        qr.scanResult = { result, error in
            if let address = result {
                logInfo("扫描结果：\(address)")
                self.addressTF.rx.text.onNext(address)
            }else {
                logDebug(error)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            qr.pop()
        }
    }
    
    func addRightNavItem() {
        
       let btn = UIButton(type: .system)
        btn.setTitle("Save".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.isEnabled = false
        btn.setTitleColor(.master, for: .normal)
        btn.addTarget(self, action:#selector(self.saveAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)

    }
    @objc func saveAction() {
        
        guard let name = nameTF.text,!name.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please enter contact name".localized())
            return }
        
        guard let address = addressTF.text,!address.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please enter address".localized())
            return }
        
        if !AElfWallet.isAELFAddress(address) {
            SVProgressHUD.showInfo(withStatus: "Invalid Address".localized())
            return
        }
        
        SVProgressHUD.show()
        userProvider.requestData(.addContact(fromAddress: App.address,
                                             toAddress: address,
                                             name: nameTF.text ?? "",
                                             remark: remarkTF.text ?? ""))
            .subscribe(onNext: { result in
                if result.isOk {
                    SVProgressHUD.showSuccess(withStatus: "Saved".localized())
                    asyncMainDelay(duration: 1) {
                        self.pop()
                    }
                } else {
                    SVProgressHUD.showInfo(withStatus: result.msg)
                }
            }, onError: { err in
                SVProgressHUD.dismiss()
            }).disposed(by: rx.disposeBag)
    }

}
