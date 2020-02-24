//
//  SecurityVerifyManager.swift
//  AElfApp
//
//  Created by 晋先森 on 2020/1/4.
//  Copyright © 2020 AELF. All rights reserved.
//

import Foundation

class SecurityVerifyManager: NSObject {
    
    static func isEnableBiometric() -> Bool {
        return AElfWallet.getBiometricPassword() != nil
    }
    
    static func verifyPaymentPassword(completion: @escaping ((String?) -> ()),_ verifyPassword: ((String?) -> ())? = nil) {
        
        if isEnableBiometric() { // 存在则表示开启了指纹支付，但还需要验证是否本人。
            self.showBiometricVerification(completion: completion, verifyPassword)
        }else {
            showInputAlertView(completion: completion)
        }
    }
    
    private static func showInputAlertView(completion: @escaping ((String?) -> ())) {
        
        InputAlertView.show(inputType: .confirmPassword, confirmClosure: { view in
            let pwd = view.pwdField.text ?? ""
            if let _ = AElfWallet.getPrivateKey(pwd: pwd) {
                view.hide()
                completion(pwd)
            } else {
                view.showHint()
                SVProgressHUD.showError(withStatus: "Password Error".localized())
            }
        })
    }
    
    static  func showBiometricVerification(completion: @escaping ((String?) -> ()),_ verifyPassword: ((String?) -> ())? = nil) {
        
        BioMetricAuthenticator.shared.allowableReuseDuration = nil //
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Verify your identity".localized()) { result in
            
            switch result {
            case .success( _):
                logInfo("验证成功！")
                completion(AElfWallet.getBiometricPassword())
            case .failure(let error):
                    logInfo("failure(let error): \(error.message())")
                switch error {
                // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    logInfo("biometryNotAvailable: \(error.message())")
                    if let v = verifyPassword {
                        showInputAlertView(completion: v)
                    } else {
                        VerifyFailedAlertView.show(tryAgainClosure: {
                            self.showBiometricVerification(completion: completion)
                        })
                    }
                case .biometryNotEnrolled:
                    logInfo("biometryNotEnrolled: \(error.message())")
                    break
                // show alternatives on fallback button clicked
                case .fallback:
                    logInfo("fallback: \(error.message())")
                    break
                    // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                case .biometryLockedout:
                    self.showPasscodeAuthentication(message: error.message(),completion: completion)
                // do nothing on canceled by system or user
                case .canceledBySystem, .canceledByUser:
                    logInfo("canceledBySystem: \(error.message())")
                    if let v = verifyPassword {
                        showInputAlertView(completion: v)
                    } else {
                        VerifyFailedAlertView.show(tryAgainClosure: {
                            self.showBiometricVerification(completion: completion)
                        })
                    }
                    break
                // show error for any other reason
                default:
                    logInfo("default: \(error.message())")
                    if let v = verifyPassword {
                        showInputAlertView(completion: v)
                    } else {
                        VerifyFailedAlertView.show(tryAgainClosure: {
                            self.showBiometricVerification(completion: completion)
                        })
                    }
                }
            }
            
        }
    }
    
    static func showPasscodeAuthentication(message: String,completion: @escaping ((String?) -> ())) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { (result) in
            switch result {
            case .success( _):
                logInfo("指纹验证成功了！")
                completion(AElfWallet.getBiometricPassword())
            case .failure(let error):
                logInfo("PasscodeAuthen: \(error.message())")
                VerifyFailedAlertView.show(tryAgainClosure: {
                    self.showBiometricVerification(completion: completion)
                })
            }
        }
    }
}
