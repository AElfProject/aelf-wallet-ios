//
//  App.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/10.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import KeychainSwift
import Kingfisher

fileprivate let bundleID = String.bundleID
fileprivate let standard = UserDefaults.standard

private struct Keys {
    static let appLanguageID = "\(bundleID).applanguage" // 标识缩写
    static let appLanguageName = "\(bundleID).applanguageName" // 对应名称
    static let appCrrency = "\(bundleID).appcrrency"
    static let appAssetMode = "\(bundleID).appassetMode"
    static let isBackup = "\(bundleID).isBackup"

    static let userInfo = "\(bundleID).userInfo"
    static let privateMode = "\(bundleID).privateMode"
    static let biometricIdentification = "\(bundleID).biometricIdentification" // 是否开启面部/指纹识别
    static let sortAssets = "\(bundleID).sortAssetsKey"
    static let isKeystoreImport = "\(bundleID).isKeystoreImport" //
    static let isMnemonicImport = "\(bundleID).isMnemonicImport" //
    static let isPrivateKeyImport = "\(bundleID).isPrivateKeyImport" //

    static let chainID = "\(bundleID).chainID" //

}

class App {
    
    class var currency: String {
        set { standard.set(newValue, forKey: Keys.appCrrency) }
        get { return standard.string(forKey: Keys.appCrrency) ?? "USD" }
    }
    class var currencySymbol: String {
        get {
            switch App.currency {
            case "CNY":
                return "¥"
            case "USD":
                return "$"
            case "AUD":
                return "A$"
            case "KRW":
                return "₩"
            default:
                return "$"
            }
        }
    }
    class var assetMode: AssetDisplayMode {
        set { standard.set(newValue.rawValue, forKey: Keys.appAssetMode) }
        get {
            let value = standard.integer(forKey: Keys.appAssetMode)
            let mode = AssetDisplayMode(rawValue: value)
            return mode ?? AssetDisplayMode.token
        }
    }
    
    class var languageID: String? {
        set { standard.set(newValue, forKey: Keys.appLanguageID) }
        get {
            return standard.string(forKey: Keys.appLanguageID)
        }
    }

    class var languageName: String {
        set { standard.set(newValue, forKey: Keys.appLanguageName) }
        get { return standard.string(forKey: Keys.appLanguageName) ?? "English" }
    }

    class func isImported() -> Bool {
       // let defauts = UserDefaults.standard
        let isImport = self.isKeystoreImport  || self.isPrivateKeyImport || self.isMnemonicImport
        return isImport;
//        let address = self.address
//        return !address.isEmpty
    }

    class var address: String {
        get {
           return AElfWallet.walletAddress()
        }
    }

    class var publicKey: String {
        get {
           return AElfWallet.walletPublicKey()
        }
    }
    
    class var walletName: String? {
        get {
           return AElfWallet.walletName
        }
    }

    class var userInfo: IdentityInfo? {
        set {
            if let str = newValue?.toJSONString() {
                standard.set(str, forKey: Keys.userInfo)
            }
        }
        get {
            guard let str = standard.string(forKey: Keys.userInfo) else { return nil }
            return IdentityInfo(JSONString: str)
        }
    }

    class var isBackup: Bool {
        set { standard.set(newValue, forKey: Keys.isBackup) }
        get { return standard.bool(forKey: Keys.isBackup)}
    }

    class var isPrivateMode: Bool {
        set { standard.set(newValue, forKey: Keys.privateMode) }
        get { return standard.bool(forKey: Keys.privateMode)}
    }

    class var sortAsset: AssetSortType {
        set { standard.set(newValue.rawValue, forKey: Keys.privateMode) }
        get {
            let value = standard.integer(forKey: Keys.privateMode)
            let type = AssetSortType(rawValue: value)
            return type ?? AssetSortType.byNameAToZ
        }
    }

    class var isBiometricIdentification: Bool {
        set { standard.set(newValue, forKey: Keys.biometricIdentification) }
        get { return standard.bool(forKey: Keys.biometricIdentification) }
    }

    /// 是通过 Keystore 导入，后续废弃
    class var isKeystoreImport: Bool {
        set { standard.set(newValue, forKey: Keys.isKeystoreImport) }
        get { return standard.bool(forKey: Keys.isKeystoreImport)}
    }
    class var isMnemonicImport: Bool {
        set { standard.set(newValue, forKey: Keys.isMnemonicImport) }
        get { return standard.bool(forKey: Keys.isMnemonicImport)}
    }
    class var isPrivateKeyImport: Bool {
        set { standard.set(newValue, forKey: Keys.isPrivateKeyImport) }
        get { return standard.bool(forKey: Keys.isPrivateKeyImport)}
    }
    class var chainID: String {
        set { standard.set(newValue, forKey: Keys.chainID) }
        get { return standard.string(forKey: Keys.chainID) ?? Define.defaultChainID }
    }


}




// MARK: - Delete Wallet Data
extension App {

    /// 通过密码，清除App 钱包所有数据。
    ///
    /// - Parameter pwd: 密码
    static func deleteAllData(pwd: String) {
        AElfWallet.deleteWallet(pwd: pwd)

        MarketCoinModel.deleteAll()
        resetAllData()
    }
    
    
    /// 无需密码，清除 App 钱包所有数据。
    static func clearAppData() {
        AElfWallet.clearAllKeyChain()
        MarketCoinModel.deleteAll()
        resetAllData()
    }
    
    
    static private func resetAllData() {
        
        App.isKeystoreImport = false
        App.isMnemonicImport = false
        App.isPrivateKeyImport = false
        App.isPrivateMode = false
        App.isBiometricIdentification = false

        App.isBackup = false // 后面过渡版本废弃。

        AElfWallet.isBackup = false
        AElfWallet.importFromKeystore = false
        let r = AElfWallet.deleteBiometricPassword()
        logInfo("删除指纹结果：\(r)")
        
        App.chainID = Define.defaultChainID
        
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
}
