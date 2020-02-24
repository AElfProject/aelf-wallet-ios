//
//  CreateWalletController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/31.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import Hero

// 创建钱包
class CreateWalletController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var pwdEyeButton: UIButton!
    @IBOutlet weak var confirmEyeButton: UIButton!
    
    @IBOutlet weak var hintField: UITextField!
    @IBOutlet weak var creatButton: UIButton!

    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var pwdInfoLabel: UILabel!


    // MARK: ViewModel
    var viewModel = CreateWalletViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        //        menmonicTextView.text = "main case speed hint similar maze fish benefit oppose adapt hollow subway"
        userNameField.text = "我是name"
        passwordField.text = "111111111aA!"
        confirmPasswordField.text = "111111111aA!"
        hintField.text = "auto"
        
        #endif
        
        creatButton.hero.id = "createID"
        bindCreateViewModel()
    }

    override func languageChanged() {

        title = "Create Wallet".localized()

        passwordField.placeholder = "%d-%d characters password".localizedFormat(pwdLengthMin,pwdLengthMax)
        confirmPasswordField.placeholder = "Please confirm your password".localized()
        hintField.placeholder = "Password hints (Optional)".localized()

        pwdInfoLabel.text = "please enter %d-%d characters password rule".localizedFormat(pwdLengthMin,pwdLengthMax)
    }

    func bindCreateViewModel() {

        // 长度限制。
        userNameField.rx.text.orEmpty.map({ $0[0..<WalletInputLimit.nameRange.upperBound - 1]})
            .bind(to: userNameField.rx.text).disposed(by: rx.disposeBag)
        passwordField.rx.text.orEmpty.map({ $0[0..<pwdLengthMax]})
            .bind(to: passwordField.rx.text).disposed(by: rx.disposeBag)
        confirmPasswordField.rx.text.orEmpty.map({ $0[0..<pwdLengthMax]})
            .bind(to: confirmPasswordField.rx.text).disposed(by: rx.disposeBag)
        hintField.rx.text.orEmpty.map({ $0[0..<WalletInputLimit.hintRange.upperBound - 1]})
            .bind(to: hintField.rx.text).disposed(by: rx.disposeBag)

        let input = CreateWalletViewModel.Input(userName: userNameField.asDriver(),
                                                pwd: passwordField.asDriver(),
                                                confirmPwd: confirmPasswordField.asDriver(),
                                                createTrigger: creatButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)

        output.result.asObservable().subscribe(onNext: { (v) in
            SVProgressHUD.showInfo(withStatus: v.message)
        }).disposed(by: rx.disposeBag)
        
        output.verifyOK.subscribe(onNext: { [weak self] v in
            self?.creatWallet()
        }).disposed(by: rx.disposeBag)

    }
    
    @IBAction func pwdEyeButtonTapped(_ sender: UIButton) {
        updateTextFieldState(passwordField, sender: sender)
    }
    

    @IBAction func confirmEyeButtonTapped(_ sender: UIButton) {

        updateTextFieldState(confirmPasswordField, sender: sender)
    }
    
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func serviceButtonTapped(_ sender: Any) {
        push(controller:  WebViewController.termsOfService())
    }
    
    func updateTextFieldState(_ textField: UITextField ,sender: UIButton) {
        
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        UIView.transition(with: sender,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { sender.isSelected = !sender.isSelected },
                          completion: nil)
    }

    func creatWallet() {

        self.view.endEditing(true)
        
        if !agreeButton.isSelected {
            SVProgressHUD.showInfo(withStatus: "Please read and agree".localized())
            return
        }
        
        let loadingView = WalletLoadingView.loadView(type: .createWallet)
        loadingView.show()
        let pwd = passwordField.text ?? ""
        let userName = self.userNameField.text ?? ""
        let mnemonics = AElfWallet.generateMnemonic()
        AElfWallet.createWallet(mnemonic: mnemonics,
                                pwd: pwd,
                                hint: self.hintField.text ?? "",
                                name: userName,
                                callback: { (created,wallet) in
            asyncMainDelay(duration: 1.5, block: { [weak self] in // loading 一会
                if created {
                    self?.createdHandler(wallet: wallet, mnemonics: mnemonics, userName: userName, loadingView: loadingView)
                } else {
                    loadingView.dismiss()
                    SVProgressHUD.showInfo(withStatus: "Create failed".localized())
                }
            })
        })
    }

    func createdHandler(wallet: WalletAccount?,mnemonics: [String],userName: String,loadingView: WalletLoadingView) {
        guard let wallet = wallet else { return }
        let deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? ""
        if (deviceId.length > 0) {
            viewModel.uploadDeviceInfo(address: wallet.address, deviceId: deviceId).subscribe(onNext: { result in
                logDebug("updateDeviceToken：\(result)")
            }).disposed(by: rx.disposeBag)
        }

        viewModel.uploadUserName(userName, address: wallet.address).subscribe(onNext: { result in
            //
        }).disposed(by: rx.disposeBag)

        viewModel.bindDefaultAsset(address: wallet.address).subscribe(onNext: { [weak self] result in
            guard let self = self else { return }
            loadingView.dismiss()
            self.performSegue(withIdentifier: WalletRemindController.className,
                              sender: mnemonics.joined(separator: " "))
        }, onError: { e in
            SVProgressHUD.showInfo(withStatus: "Network exception, please try again later".localized())
        }).disposed(by: rx.disposeBag)
    }

}

extension CreateWalletController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let vc = segue.destination as? WalletRemindController,
            let mnemionic = sender as? String else { return }
        vc.mnemonic = mnemionic
        vc.walletType = .create
    }

}
