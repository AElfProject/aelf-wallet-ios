//
//  SettingManagerController.swift
//  AelfApp
//
//  Created by MacKun on 2019/5/31.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit


class SettingManagerController: BaseStaticTableController {
    
    @IBOutlet weak var privateTitleLabel: UILabel!
    @IBOutlet weak var privateSubTitleLabel: UILabel!
    
    @IBOutlet weak var identificationTitleLabel: UILabel!
    @IBOutlet weak var identificationSubTitleLabel: UILabel!
    
    @IBOutlet weak var languageTitleLabel: UILabel!
    @IBOutlet weak var currencyTitleLabel: UILabel!
    @IBOutlet weak var assetDisplayTitleLabel: UILabel!
    
    @IBOutlet weak var privateSwitch: UISwitch!
    @IBOutlet weak var identificationSwitch: UISwitch!
    
    @IBOutlet weak var languageValueLabel: UILabel!
    @IBOutlet weak var currencyValueLabel: UILabel!
    @IBOutlet weak var assetValueLabel: UILabel!
    
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var identificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackItem()
        
        tableView.tableFooterView  = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    func loadData(){
        
        languageValueLabel.text = App.languageName
        currencyValueLabel.text = App.currency
        assetValueLabel.text = App.assetMode.stringValue
        privateSwitch.isOn = App.isPrivateMode
        identificationSwitch.isOn = App.isBiometricIdentification
        
        tableView.reloadData()
    }
    
    override func languageChanged() {
        
        title = "Settings".localized()
        privateTitleLabel.text = "Private Mode".localized()
        privateSubTitleLabel.text = "When turn on".localized()
        identificationTitleLabel.text = "Biometric Identification".localized()
        identificationSubTitleLabel.text = "Face ID or Touch ID".localized()
        languageTitleLabel.text = "Language".localized()
        currencyTitleLabel.text = "Pricing Currency".localized()
        assetDisplayTitleLabel.text = "Asset Display".localized()
        
    }
    
    
    @IBAction func privateButtonTapped(_ sender: UIButton) {
        
        privateSwitch.toggle()
        App.isPrivateMode = privateSwitch.isOn
        logInfo("IsOn: \(privateSwitch.isOn)")
        NotificationCenter.post(name: NotificationName.currencyDidChange)
    }
    
    @IBAction func privateSwitchChanged(_ sender: Any) {
        
        logInfo("privateSwitchChanged 走不到: \(privateSwitch.isOn)")
        
    }
    
    func bioValueToggeer() {
        identificationSwitch.toggle()
        App.isBiometricIdentification = identificationSwitch.isOn
    }
    
    @IBAction func identificationButtonTapped(_ sender: UIButton) {
        
        if SecurityVerifyManager.isEnableBiometric() {
            AElfAlertView.show(title: "Are you sure you want to turn off biometrics?".localized(),
                               subTitle: "After closing, you need to enter the password for each payment".localized()) {
                                AElfWallet.deleteBiometricPassword()
                                self.bioValueToggeer()
                                SVProgressHUD.showSuccess(withStatus: "Closed".localized())
            }
        } else {

            SecurityWarnView.show(title: "Do you want to allow AELF Wallet to use biometrics?".localized(),
                                  centerTitle: false,
                                  body: "Using biometrics can be applied to unlock apps and verify payments".localized(),
                                  interactive: true,
                                  confirmTitle: "Confirm".localized()) {
                self.showInputPwdView()
            }
        }
    }
    
    func showInputPwdView() {
        InputAlertView.show(inputType: .confirmPassword) { view in
            let pwd = view.pwdField.text ?? ""
            if let _ = AElfWallet.getPrivateKey(pwd: pwd) {
                view.pwdField.resignFirstResponder()
                view.hide()
                self.showBiometricVerify(password: pwd)
            } else {
                view.showHint()
                SVProgressHUD.showError(withStatus: "Password Error".localized())
            }
        }
    }
    
    
    @IBAction func identificationSwitchChanged(_ sender: Any) {
        
        logInfo("privateSwitchChanged 走不到: \(privateSwitch.isOn)")
        
    }
    
    func showBiometricVerify(password: String) {
//        SecurityVerifyManager.showBiometricVerification(completion: <#T##((String?) -> ())##((String?) -> ())##(String?) -> ()#>)
        BioMetricAuthenticator.shared.allowableReuseDuration = nil // 立即认证
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Verify your identity".localized()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let success):
                logInfo("认证成功: \(success), result: \(result)")
                self.bioValueToggeer()
                AElfWallet.saveBiometric(password: password)
            case .failure(let error):
                switch error {
                case .biometryNotAvailable:
                    SVProgressHUD.showError(withStatus: error.message())
                    
                case .biometryNotEnrolled: break
                case .fallback:break
                case .biometryLockedout:
                    self.showPasscodeAuthentication(message: error.message(),password: password)
                // do nothing on canceled by system or user
                case .canceledBySystem, .canceledByUser: break
                // show error for any other reason
                default:
                    SVProgressHUD.showError(withStatus: error.message())
                }
            }
        }
    }
    
    func showPasscodeAuthentication(message: String,password: String) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success( _):
                logInfo("认证成功: \(message)")
                AElfWallet.saveBiometric(password: password)
                self.bioValueToggeer()
                break
            case .failure(let error):
                SVProgressHUD.showError(withStatus: error.message())
            }
        }
    }
}

extension SettingManagerController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {//language
            let languageVC = UIStoryboard.loadStoryClass(className: LanguageController.className, storyType: .setting)
            push(controller: languageVC)
        }
        if indexPath.row == 3 {//CNY
            let languageVC = UIStoryboard.loadStoryClass(className: ChargeUnitController.className, storyType: .setting)
            push(controller: languageVC)
        }
        if indexPath.row == 4 {//Asset Display
            let languageVC = UIStoryboard.loadStoryClass(className: AssetShowTypeController.className, storyType: .setting)
            push(controller: languageVC)
        }
    }
    
}
