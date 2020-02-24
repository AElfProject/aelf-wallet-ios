//
//  ImportMnemonicController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/31.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Hero
import JXSegmentedView


/// 通过 助记词 导入钱包
class ImportMnemonicController: BaseController {
    
    @IBOutlet weak var menmonicTextView: UITextView!
    
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var confirmPwdField: UITextField!
    @IBOutlet weak var hintField: UITextField!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var serverProtocolButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    
    @IBOutlet weak var pwdInfoLabel: UILabel!
    
    var parentVC: ImportContentController?
    let viewModel = ImportMnemonicViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        //        menmonicTextView.text = "main case speed hint similar maze fish benefit oppose adapt hollow subway"
        menmonicTextView.text = "kite magnet crew kitten cradle jealous amateur chalk gospel meadow toward pear"
        pwdField.text = "111111111aA!"
        confirmPwdField.text = "111111111aA!"
        hintField.text = "auto"
        
        #endif
        
        menmonicTextView.placeholder = "Input mnemonic".localized()
        importButton.hero.id = "importID"
        bindImportViewModel()
    }
    
    override func languageChanged() {
        
        pwdField.placeholder = "%d-%d characters password".localizedFormat(pwdLengthMin,pwdLengthMax)
        confirmPwdField.placeholder = "Please confirm your password".localized()
        hintField.placeholder = "Password hints (Optional)".localized()
        pwdInfoLabel.text = "please enter %d-%d characters password rule".localizedFormat(pwdLengthMin,pwdLengthMax)
    }
    
    func bindImportViewModel() {
        
        menmonicTextView.rx.text.orEmpty//.map{ $0.setMnemonicFormatter() }
            .bind(to: menmonicTextView.rx.text).disposed(by: rx.disposeBag)
        
        pwdField.rx.text.orEmpty.map({ $0[0..<pwdLengthMax]})
            .bind(to: pwdField.rx.text).disposed(by: rx.disposeBag)
        confirmPwdField.rx.text.orEmpty.map({ $0[0..<pwdLengthMax]})
            .bind(to: confirmPwdField.rx.text).disposed(by: rx.disposeBag)
        hintField.rx.text.orEmpty.map({ $0[0..<WalletInputLimit.hintRange.upperBound - 1]})
            .bind(to: hintField.rx.text).disposed(by: rx.disposeBag)
        
        let input = ImportMnemonicViewModel.Input(pwd: pwdField.asDriver(),
                                                  confirmPwd: confirmPwdField.asDriver(),
                                                  importTrigger: importButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.result.asObservable().subscribe(onNext: { (v) in
            SVProgressHUD.showInfo(withStatus: v.message)
        }).disposed(by: rx.disposeBag)
        
        output.verifyOK.subscribe(onNext: { [weak self] v in
            self?.importWalletHandler()
        }).disposed(by: rx.disposeBag)
        
    }
    
    func transitionEyeButton(_ button: UIButton) {
        UIView.transition(with: button,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { button.isSelected = !button.isSelected },
                          completion: nil)
    }
    
    @IBAction func eyeButton2Tapped(_ sender: UIButton) {
        
        pwdField.isSecureTextEntry = !pwdField.isSecureTextEntry
        transitionEyeButton(sender)
    }
    
    // 隐私模式
    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        
        confirmPwdField.isSecureTextEntry = !confirmPwdField.isSecureTextEntry
        transitionEyeButton(sender)
    }
    
    // 查看用户服务协议
    @IBAction func serverButtonTapped(_ sender: UIButton) {
        parentVC?.push(controller:  WebViewController.termsOfService())
    }
    
    // 同意协议
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    func importWalletHandler() {
        
        view.endEditing(true)
        if !agreeButton.isSelected {
            SVProgressHUD.showInfo(withStatus: "Please read and agree".localized())
            return
        }
        
        let array = menmonicTextView.text.setMnemonicFormatter().components(separatedBy: " ")
        let pwd = pwdField.text ?? ""
        let hint = hintField.text ?? ""
        if array.count != 12 {
            SVProgressHUD.showError(withStatus: "Please enter 12 mnemonic words".localized())
        } else {
            let loadingView = WalletLoadingView.loadView(type: .importWallet)
            loadingView.show()
            AElfWallet.createWallet(mnemonic: array,
                                    pwd: pwd,
                                    hint: hint,
                                    name: Define.defaultChainID,
                                    callback: { [weak self] (created, wallet) in
                                        if created {
                                            App.isMnemonicImport = true;
                                            self?.importedHandler(address: wallet?.address,loadingView: loadingView)
                                        } else {
                                            SVProgressHUD.showInfo(withStatus: "Import failed".localized())
                                            loadingView.dismiss()
                                        }
            })
        }
    }
    
    
    func importedHandler(address: String?,loadingView: WalletLoadingView) {
        guard let address = address else { return }
        
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

extension ImportMnemonicController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
