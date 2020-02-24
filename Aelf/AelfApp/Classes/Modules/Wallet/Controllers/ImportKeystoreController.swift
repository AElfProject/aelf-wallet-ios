//
//  ImportKeystoreController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView


/// 通过 Keystore 导入钱包
class ImportKeystoreController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var keystoreTextView: UITextView!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var pwdFormatLabel: UILabel!

    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var importButton: UIButton!

    var parentVC: ImportContentController?
    let viewModel = ImportKeystoreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        importButton.hero.id = "importID"
    }

    override func languageChanged() {

        keystoreTextView.placeholder = "Input keystore".localized()
    }
    @IBAction func eyeButtonTapped(_ button: UIButton) {
        pwdField.isSecureTextEntry = !pwdField.isSecureTextEntry
        UIView.transition(with: button,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { button.isSelected = !button.isSelected },
                          completion: nil)
    }
    
    @IBAction func importButtonTapped(_ sender: Any) {
        importWallet()
    }
    
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func serviceButtonTapped(_ sender: UIButton) {
        parentVC?.push(controller:  WebViewController.termsOfService())
    }

    func importWallet() {

        view.endEditing(true)
        
        let keystore = keystoreTextView.text ?? ""
        let pwd = pwdField.text ?? ""
        
        if pwd.isEmpty {
            SVProgressHUD.showInfo(withStatus: "Please input password".localized())
            return
        }
        
        if !agreeButton.isSelected {
            SVProgressHUD.showInfo(withStatus: "Please read and agree".localized())
            return
        }

        if keystore.count == 0 {
            SVProgressHUD.showError(withStatus: "Please enter the correct Keystore".localized())
        } else {
            let loadingView = WalletLoadingView.loadView(type: .importWallet)
            loadingView.show()
            AElfWallet.imoportWalletKeyStore(keyStore: keystore, pwd: pwd) { (result) in
                if let result = result {
                    AElfWallet.createKeystoreWallet(item: result, pwd: pwd, callback: { [weak self] (created, account) in
                        if created {
                            App.isKeystoreImport = true;
                            self?.importedHandler(address: result.address,loadingView: loadingView)
                        } else {
                            SVProgressHUD.showInfo(withStatus: "Import failed".localized())
                            loadingView.dismiss()
                        }
                    })
                } else {
                    SVProgressHUD.showInfo(withStatus: "Import failed".localized())
                    loadingView.dismiss()
                }
            }
        }
    }

    func importedHandler(address: String,loadingView: WalletLoadingView) {

        AElfWallet.importFromKeystore = true
        AElfWallet.isBackup = true
        
        let deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? ""
        if (deviceId.length > 0) {
            viewModel.uploadDeviceInfo(address: address,
                                       deviceId: deviceId).subscribe(onNext: { result in
                                        logDebug("updateDeviceToken：\(result)")
                                       }).disposed(by: rx.disposeBag)
        }

        viewModel.bindDefaultAsset(address: address).subscribe(onNext: { result in
            // 返回结果不影响进入首页
        }).disposed(by: rx.disposeBag)

        asyncMainDelay(duration: 1, block: {
            loadingView.dismiss() //
            BaseTableBarController.resetRootController() // 重置 TabBar
        })
    }

}


extension ImportKeystoreController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}


extension ImportKeystoreController {


}
