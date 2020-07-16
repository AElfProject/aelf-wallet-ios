//
//  AppDelegateExtension.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import Schedule
import Kingfisher
import SwiftMessages
import JJException

extension AppDelegate {
    
    func setupAppConfigure(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        //Network config
        let network: String = UserDefaults.standard.string(forKey: "kNetwork") ?? ""
        if network.length <= 0 {
            UserDefaults.standard.setValue("https://wallet-app-api-test.aelf.io/", forKey: "kNetwork")
            UserDefaults.standard.synchronize()
        }
        
        // Bugly
        Bugly.start(withAppId: AppConfigManager.shared.config.buglyId)
        
        // IQ
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [AssetTransferController.self]
        IQKeyboardManager.shared.disabledToolbarClasses = [AssetTransferController.self]
        IQKeyboardManager.shared.disabledTouchResignedClasses = [AssetTransferController.self]
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(0.8)
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
//        SVProgressHUD.setMaxSupportedWindowLevel(.alert)
        
        SwiftMessages.pauseBetweenMessages = 0.1 // 多个 SwiftMessages 弹框出现的间隔
        
        UINavigationBar.configAppearance()
        
    }
    
    func compareAppConfig() { // 过渡配置。
        
        if App.isBackup {
            AElfWallet.isBackup = true
        }
        
        if App.isKeystoreImport {
            AElfWallet.importFromKeystore = true
        }
        
        if App.languageID == nil { // 强制要求默认英文（不管手机系统什么语言。）
            App.languageID = "en"
            App.languageName = "English"
            Localize.setCurrentLanguage("en")
        }
        
        if App.chainID == "AElf" { //
            App.chainID = Define.defaultChainID
        }
        
    }
    
    func registerJJException(){ // 崩溃拦截
        JJException.configExceptionCategory(.allExceptZombie)
        JJException.startGuard()
        JJException.register(self);
    }
    
    func createTables() {
        
        DBManager.createTable(table: AddressBookItem.className, of: AddressBookItem.self)
        DBManager.createTable(table: MarketCoinModel.className, of: MarketCoinModel.self)
        DBManager.createTable(table: ChainItem.className, of: ChainItem.self)
    }
    
    func loadStoryboard() {
        
        if App.isImported() { // 如果导入，则跳过；未导入，则跳转创建/导入钱包界面。
            
            let tabbar = BaseTableBarController.loadTabBar()
            self.window = UIWindow(frame: UIScreen.main.bounds) // maybe is a ios bug
            self.window?.rootViewController = tabbar
        } else {
            App.clearAppData()
            let walletNav = UIStoryboard.loadController(BaseNavigationController.self, storyType: .wallet)
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = walletNav
        }
        self.window?.makeKeyAndVisible()
    }
    
    func checkBioMetricAuthen() {
        
        if UIApplication.isSimulator { return }
        
        asyncMainDelay(duration: 0.2) {
            self.showBiometricVerification()
        }
    }
}

extension AppDelegate: JJExceptionHandle {
    
    func handleCrashException(_ exceptionMessage: String, extraInfo info: [AnyHashable : Any]?) {
        logInfo("上传崩溃信息：\(exceptionMessage), 描述：\(info ?? [:])")
        guard let info = info else { return }
        
        Bugly.reportException(withCategory: 2,
                              name: exceptionMessage,
                              reason: exceptionMessage,
                              callStack: [],
                              extraInfo: info,
                              terminateApp: false)
    }
}

// MARK: Biometric Verification
extension AppDelegate {
    
    private func showBiometricVerification() {
        if !App.isBiometricIdentification { return } // 开启登录，认证
        
        // https://blog.csdn.net/heqiang2015/article/details/86508203 指纹变更处理
        let verifyView = VerifyIdentityView.loadView(bioMetricVerify: { v in
            self.showBioMetric(verifyView: v)
        }) { v in
            InputAlertView.show(inputType: .confirmPassword, confirmClosure: { view in
                let pwd = view.pwdField.text ?? ""
                if let _ = AElfWallet.getPrivateKey(pwd: pwd) {
                    view.hide()
                    v.dismiss(animated: true)
                } else {
                    view.showHint()
                    SVProgressHUD.showError(withStatus: "Password Error".localized())
                }
            })
        }
        verifyView.show()
        
        showBioMetric(verifyView: verifyView)
    }
    
    func showBioMetric(verifyView: VerifyIdentityView) {
        
        BioMetricAuthenticator.shared.allowableReuseDuration = nil //
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Verify your identity".localized()) { result in
            
            switch result {
            case .success( _):
                verifyView.dismiss(animated: true)
                logInfo("验证成功！")
            case .failure(let error):
                
                switch error {
                // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    logInfo(error.message())
                    VerifyFailedAlertView.show(tryAgainClosure: {
                        self.showBioMetric(verifyView: verifyView)
                    })
                case .biometryNotEnrolled:
                    break
                // show alternatives on fallback button clicked
                case .fallback:
                    break
                    // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                case .biometryLockedout:
                    self.showPasscodeAuthentication(message: error.message(),verifyView: verifyView)
                // do nothing on canceled by system or user
                case .canceledBySystem, .canceledByUser:
                    break
                // show error for any other reason
                default:
                    logInfo(error.message())
                    VerifyFailedAlertView.show(tryAgainClosure: {
                        self.showBioMetric(verifyView: verifyView)
                    })
                }
            }
            
        }
    }
    
    func showPasscodeAuthentication(message: String,verifyView: VerifyIdentityView) {
        
        BioMetricAuthenticator.authenticateWithPasscode(reason: message) { (result) in
            switch result {
            case .success( _):
                logInfo("验证成功！")
                verifyView.dismiss(animated: true)
            case .failure(let error):
                logInfo(error.message())
                VerifyFailedAlertView.show(tryAgainClosure: {
                    self.showBioMetric(verifyView: verifyView)
                })
            }
        }
    }
    
}

/// MARK: Umeng

extension AppDelegate {
    
    func setupUmengConfigure(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        /// 友盟初始化
        UMConfigure.initWithAppkey(AppConfigManager.shared.config.uMengKey, channel:"App Store")
        #if DEBUG
        UMConfigure.setLogEnabled(true)
        #endif
        
        /// 友盟統計
        MobClick.setScenarioType(eScenarioType.E_UM_NORMAL)
        
        /// iOS 10 以上
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        /// 友盟推送配置
        let entity = UMessageRegisterEntity.init()
        entity.types = Int(UMessageAuthorizationOptions.alert.rawValue) |
            Int(UMessageAuthorizationOptions.badge.rawValue) |
            Int(UMessageAuthorizationOptions.sound.rawValue)
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        UMessage.setAutoAlert(true)
    }
    
    
    /// 拿到 Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UMessage.registerDeviceToken(deviceToken)
        
        var deviceId = ""
        
        if #available(iOS 13, *) {
            let bytes = [UInt8](deviceToken)
            for item in bytes {
                deviceId += String(format:"%02x", item&0x000000FF)
            }
        } else {
            let device = NSData(data: deviceToken)
            
            deviceId = device.description
                .replacingOccurrences(of:"<", with:"")
                .replacingOccurrences(of:">", with:"")
                .replacingOccurrences(of:" ", with:"")
        }
        logDebug("DeviceToken：\(deviceId)")
        
        UserDefaults.standard.set(deviceId, forKey: "deviceId")
        if App.address.length > 0 {
            userProvider.requestData(.updateDeviceToken(address: App.address,
                                                        parent: "ELF",
                                                        iosNoticeToken: deviceId))
                .subscribe(onNext: { (result) in
                    //
                }).disposed(by: rx.disposeBag)
        }
        
    }
    
    /// 注册推送失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        logDebug("error: \(error.localizedDescription)")
    }
    
    /// 接到推送消息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UMessage.didReceiveRemoteNotification(userInfo)
    }
    
    /// iOS10 以前接收的方法
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     withResponseInfo responseInfo: [AnyHashable: Any],
                     completionHandler: @escaping () -> Void) {
        /// 这个方法用来做action点击的统计
        UMessage.sendClickReport(forRemoteNotification: responseInfo)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //iOS10以下使用这两个方法接收通知，
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        //关闭友盟自带的弹出框
        UMessage.setAutoAlert(false)
        logDebug("push userInfo ：\(userInfo)")
        if  UIDevice.current.systemVersion < "10" {
            logDebug("push userInfo ：\(userInfo)")
            UMessage.didReceiveRemoteNotification(userInfo)
            //            self.umUserInfo = userInfo;
            
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    //iOS10新增：处理前台收到通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger is UNPushNotificationTrigger {
            //应用处于前台时的远程推送接受
            //关闭友盟自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
            logDebug("UNPushNotificationTrigger userInfo ：\(userInfo)")
        } else {
            //应用处于后台时的本地推送接受
            logDebug("UNUserNotificationCenter ：\(userInfo)")
        }
        
        //当应用处于前台时提示设置，需要哪个可以设置哪一个
        completionHandler(UNNotificationPresentationOptions(rawValue: UNNotificationPresentationOptions.RawValue(UInt8(UNNotificationPresentationOptions.sound.rawValue) | UInt8(UNNotificationPresentationOptions.badge.rawValue) | UInt8(UNNotificationPresentationOptions.alert.rawValue))))
    }
    
    //iOS10新增：处理后台点击通知的代理方法
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let extra = userInfo["extra"] as? NSDictionary
        var txid: String?
        var fromChainID: String?
 
        if let extra = extra {
            let type = extra.object(forKey: "type") as? Int
            if type == 0 {
                txid = extra.object(forKey: "txid") as? String
            }
            else if type == 1 { // 待处理的交易，在首页调 waiting_cross_trans 接口弹框提醒
                txid = (extra.object(forKey: "txid") as? String)
                fromChainID = extra.object(forKey: "from_chain") as? String
            }
        }
        
        
        logDebug("txid：\(txid ?? "无")")
        guard let txID = txid else { return }
        
        if response.notification.request.trigger is UNPushNotificationTrigger {
            
            //应用处于前台时的远程推送接受 //关闭友盟自带的弹出框
            UMessage.setAutoAlert(false)
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
            
            self.showTranserVC(txid: txID,fromChainID: fromChainID, delayDuration: 1)
        } else {
            //应用处于后台时的本地推送接受
            showTranserVC(txid: txID,fromChainID: fromChainID, delayDuration: 2.5)
        }
    }
    
    func showTranserVC(txid: String,fromChainID: String?,delayDuration: TimeInterval) {
        
        asyncMainDelay(duration: delayDuration) {
            if let rootVC = UIViewController.topViewController() {
                let transactionVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
                transactionVC.txId = txid
                transactionVC.fromChainID = fromChainID
                rootVC.push(controller: transactionVC)
            } else {
                logInfo("RootVC 不存在。")
            }
        }
    }
}


extension AppDelegate {
    
    func loadLaunchScreenAnimation() {
        
        guard let vc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController(),
            let view = vc.view,let mainWindow = UIApplication.shared.keyWindow else {
                return
        }
        view.frame = mainWindow.bounds
        mainWindow.addSubview(view)
        
        UIView.animate(withDuration: 0.6, delay: 0.5, options: .beginFromCurrentState, animations: {
            view.alpha = 0
            view.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1)
        }) { (b) in
            view.removeFromSuperview()
        }
    }
    
}
