//
//  AppDelegate.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let browserView = AElfBrowserView.init(frame: .zero)
    
    var isAllowBiometricIdentification = true // 允许展示生物认证，5分钟内不杀掉APP只认证1次
    var biometricTimer: Timer?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
            // ..
        #else
            registerJJException()
        #endif
        
        compareAppConfig() // 

        loadStoryboard() //
        loadLaunchScreenAnimation()

        setupAppConfigure(launchOptions: launchOptions)
        setupUmengConfigure(launchOptions: launchOptions)
        createTables()

        checkBioMetricAuthen() // 指纹登录验证
        
        GlobalDataManager.shared.checkAndUpdateData()

        self.window?.addSubview(self.browserView) // transfer js view.
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        logInfo(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        logInfo(#function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        logInfo(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        logInfo(#function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logInfo(#function)
    }

}
