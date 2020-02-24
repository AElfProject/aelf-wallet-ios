//
//  ScanKeystoreController.swift
//  AElfApp
//
//  Created by 晋先森 on 2020/1/4.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import UIKit

class ScanKeystoreController: BaseController {
    
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var scanImgView: UIImageView!
    @IBOutlet weak var scanTitleLabel: UILabel!
    
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var scanResult: String?
    let viewModel = ImportKeystoreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        importButton.hero.id = "importID"
        addAdvancedItem()
        
        scanView.isUserInteractionEnabled = true
        scanView.addTapGesture { [weak self] (tap) in
            self?.enterScanController()
        }
        
        nameLabel.text = nil
        addressLabel.text = nil
        
    }
    
    override func languageChanged() {
        
        title = "Import Wallet".localized()
        
        scanImgView.image = UIImage(named: App.languageID == "en" ? "click_en":"click_cn")
    }
    
    func addAdvancedItem() {
        
        let btn = UIButton(type: .system)
        btn.setTitle("Advanced".localized(), for: .normal)
        btn.setTitleColor(UIColor.master, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action:#selector(advancedButtonTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
    }
    
    @IBAction func eyeButtonTapped(_ button: UIButton) {
        pwdField.isSecureTextEntry = !pwdField.isSecureTextEntry
        UIView.transition(with: button,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { button.isSelected = !button.isSelected },
                          completion: nil)
    }
    
    @objc func advancedButtonTapped() {
        
        let vc = UIStoryboard.loadController(ImportContentController.self, storyType: .wallet)
        push(controller: vc)
    }
    
    
    @IBAction func importButtonTapped(_ sender: Any) {
        importWallet()
    }
    
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func serviceButtonTapped(_ sender: UIButton) {
        push(controller:  WebViewController.termsOfService())
    }
    
    @objc func enterScanController() {
        
        guard UIApplication.isAllowCamera() else {
            SVProgressHUD.showInfo(withStatus: "Scanning QR code requires camera permissions".localized())
            return
        }
        
        let qr = QRScannerViewController()
        qr.scanType = .keystoreScan
        self.push(controller: qr)
        qr.scanResult = { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                logInfo("扫描结果：\(result)")
                self.scanResult = result
                self.scanImgView.image = UIImage(named: "click_result")
                self.parseScanResult(result)
            }else {
                logDebug(error)
                SVProgressHUD.showInfo(withStatus: "Please scan a valid Keystore".localized())
            }
            qr.pop()
        }
    }
    
    func parseScanResult(_ result: String) {
        guard let data = result.data(using: .utf8) else {
            logInfo("无法转为 data.")
            return }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .init()) as? [String: Any] else { return }
        
        if let name = json?["nickName"] as? String {
            nameLabel.text = name
        }
        
        if let address = json?["address"] as? String {
            addressLabel.text = address
        }
        
    }
    
    func importWallet() {
        
        view.endEditing(true)

        guard let keystore = scanResult,!keystore.isEmpty else {
            //SVProgressHUD.showInfo(withStatus: "Please scan a valid Keystore".localized())
            SVProgressHUD.showInfo(withStatus: "Please scan the correct Keystore".localized())
            return
        }
        guard let pwd = pwdField.text, !pwd.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please input password".localized())
            return
        }
        
        if !agreeButton.isSelected {
            SVProgressHUD.showInfo(withStatus: "Please read and agree".localized())
            return
        }
        
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
    
    func importedHandler(address: String,loadingView: WalletLoadingView) {
        logInfo("扫描出来的地址：\(address)")
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
