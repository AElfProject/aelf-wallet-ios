//
//  AElfWallet.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/12.
//  Copyright © 2019 AELF. All rights reserved.
//

import BitcoinKit
import KeychainSwift

public final class AElfWallet {
    
    typealias ElfTransferCallback = (_ result:TransferResult) -> Void
    typealias ElfWalletCallback = (_ created:Bool, _ wallet:WalletAccount?) -> Void
    fileprivate var account = WalletAccount()
    
    static let sharedInstance = AElfWallet()
    class var shared : AElfWallet {
        return sharedInstance
    }
    /*生成注记词*/
    static func generateMnemonic() -> [String] {
        var mnemonic:[String] = []
        do {
            try mnemonic = Mnemonic.generate(strength: .default, language: .english)
        } catch  {
            logDebug("生成失败：\(error)")
        }
        
        return mnemonic
    }
    required  init(){
        
        self.account = loadKeyChainWallet()
    }
    
    private func loadKeyChainWallet() -> WalletAccount {
        let result = KeychainSwift().getData("aelf_account")
        if (result != nil) {
            do {
                if let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(result!) as? WalletAccount {
                    return loadedStrings
                }
            } catch {
                logDebug("Couldn't read file: \(error)")
            }
        }
        return WalletAccount.init()
    }
    static func isAELFAddress(_ address:String) -> Bool {
        
        guard let raw = Base58.decode(address.removeChainID()) else {
            return false
        }
        
        let checksum = raw.suffix(4)
        let pubKeyHash = raw.dropLast(4)
        let checksumConfirm = Crypto.sha256sha256(pubKeyHash).prefix(4)
        return checksum == checksumConfirm
        
    }
    static func isCreateWallet() -> Bool {
        return shared.account.address != ""
    }
    
    static func walletAccount() -> WalletAccount {
        return shared.account
    }
    
    static func walletAddress() -> String {
        return shared.account.address
    }
    static func walletPublicKey() -> String {
        return shared.account.publicKey
    }
    
    static var walletName: String? {
        return shared.account.accoutName
    }
    
    static func getPrivateKey(pwd:String) -> String? {
        let result = KeychainSwift().get("privateKey_"+pwd.aelfMd5())
        return result
    }
    
    static func getMnemonic(pwd:String) -> String? {
        let result = KeychainSwift().get("mnemonic_"+pwd.aelfMd5())
        return result
    }
    
    static func imoportWalletKeyStore(keyStore:String, pwd:String, callback: AElfBrowserView.CreatedWalletCallback? = nil)  {
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.importWalletKeyStoreCall(keyStore: keyStore, password: pwd) { (result) in
            logInfo(result)
            callback?(result)
        }
    }
    
    static func imoportWalletPrivateKey(privateKey:String, pwd:String, callback: AElfBrowserView.CreatedWalletCallback? = nil)  {
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.importWalletPrivateKeyCall(privateKey: privateKey, password: pwd) { (result) in
            logInfo(result)
            callback?(result)
        }
    }
    
    static func getKeyStore(pwd:String, callback: AElfBrowserView.KeyStoreCallback? = nil)  {
        guard let privateKey = self.getPrivateKey(pwd: pwd) else { callback?(nil); return }
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.getWalletKeyStoreCall(privateKey: privateKey, address: App.address, password: pwd) { (result) in
            logInfo(result)
            callback?(result)
        }
    }
    
}



/// 创建钱包
extension AElfWallet {
    
    /// 创建 AElf 钱包，通过助记词和密码。
    ///
    /// - Parameters:
    ///   - mnemonic: 助记词，数组形式，内为 12个 字符串，固定格式。
    ///   - pwd: 密码
    ///   - hint: 提示语
    ///   - name: 用户名称
    ///   - callback: 返回结果 ElfWalletCallback 的 created = true ，则创建成功。
    static func createWallet(mnemonic:[String], pwd:String, hint:String, name:String, callback: ElfWalletCallback? = nil){
        let mnemonicStr = mnemonic.joined(separator: " ")
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        
        appDelegate.browserView.createdWalletCall(mnemonic: mnemonicStr) { (result) in
            logInfo(result)
            guard let result = result else {
                logInfo("result = nil !!!")
                callback?(false,nil)
                return
            }
            if result.address.isEmpty {
                callback?(false,nil)
            } else {
                let account = WalletAccount()
                account.signature = result.signature
                account.signedAddress = result.signedAddress
                account.publicKey = result.publicKey
                account.address = result.address
                account.accoutName = name
                account.hint = hint
                shared.account = account
                let saved = saveAccount(account: account)
                    && saveMnemonic(mnemonic: mnemonicStr, pwd: pwd)
                    && savePrivateKey(privateKey: result.privateKey, pwd: pwd)
                callback?(saved,account)
            }
        }
    }
    
    /// 创建 AElf 钱包，通过私钥和密码。
    ///
    /// - Parameters:
    ///   - privateKey: 私钥。
    ///   - pwd: 密码
    ///   - hint: 提示语
    ///   - name: 用户名称
    ///   - callback: 返回结果 ElfWalletCallback 的 created = true ，则创建成功。
    static func createPrivateKeyWallet(privateKey:String, pwd:String, hint:String, name:String, callback: ElfWalletCallback? = nil){
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.importWalletPrivateKeyCall(privateKey: privateKey, password: pwd) {(result) in
            logInfo(result)
            guard let result = result else {
                logInfo("result = nil !!!")
                callback?(false,nil)
                return
            }
            if result.address.isEmpty {
                callback?(false,nil)
            } else {
                let account = WalletAccount()
                account.signature = result.signature
                account.signedAddress = result.signedAddress
                account.publicKey = result.publicKey
                account.address = result.address
                account.accoutName = name
                account.hint = hint
                shared.account = account
                let saved = saveAccount(account: account)
                    && savePrivateKey(privateKey: privateKey, pwd: pwd)
                callback?(saved,account)
            }
        }
        
    }
    
    
    /// 创建 AElf 钱包，通过 WalletResult 对象和密码。
    ///
    /// - Parameters:
    ///   - item: WalletResult 对象
    ///   - pwd: 密码
    ///   - callback: 返回结果 ElfWalletCallback 的 created = true ，则创建成功。
    static func createKeystoreWallet(item: WalletResult, pwd: String, callback :ElfWalletCallback? = nil){
        
        guard item.privateKey.count > 0 else {
            callback?(false,nil)
            return
        }
        let account = WalletAccount()
        account.signature = item.signature
        account.signedAddress = item.signedAddress
        account.publicKey = item.publicKey
        account.address = item.address
        shared.account = account
        let saved = saveAccount(account: account)
            && savePrivateKey(privateKey: item.privateKey, pwd: pwd)
        
        callback?(saved,account)
    }
    
}


//MARK: Delete Action
extension AElfWallet {
    
    @discardableResult
    static func deleteWallet(pwd:String) -> Bool {
        let isDelete = deleteAccount()  && deleteMnemonic(pwd: pwd) && deletePrivateKey(pwd:pwd)
        return isDelete
    }
    
    @discardableResult
    static func deleteAccount() -> Bool {
        return KeychainSwift().delete("aelf_account")
    }
    
    @discardableResult
    static func deleteMnemonic(pwd:String) -> Bool {
        return KeychainSwift().delete("mnemonic_"+pwd.aelfMd5())
    }
    
    @discardableResult
    static func deletePrivateKey(pwd:String) -> Bool {
        return KeychainSwift().delete("privateKey_"+pwd.aelfMd5())
    }
    
    @discardableResult
    static func clearAllKeyChain() -> Bool {
        return KeychainSwift().clear()
    }
 
}

//MARK: Save Action
extension AElfWallet {
    
    @discardableResult
    static func saveAccount(account: WalletAccount) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: account)
        return KeychainSwift().set(data, forKey: "aelf_account")
    }
    
    @discardableResult
    static func saveMnemonic(mnemonic:String,pwd:String) -> Bool {
        return KeychainSwift().set(mnemonic, forKey: "mnemonic_"+pwd.aelfMd5())
    }
    
    @discardableResult
    static func savePrivateKey(privateKey:String,pwd:String) -> Bool {
        return KeychainSwift().set(privateKey, forKey: "privateKey_"+pwd.aelfMd5())
    }
    
}

// Dapp 使用
extension AElfWallet {
    
    
//    static func saveDAppWhite(url: String,privateKey: String) -> Bool {
//
//        let urlMd5 = url.urlEncoded.md5()
//
//        KeychainSwift().set(Date().timeIntervalSince1970.string, forKey: urlMd5)
//
//        guard let timestamp = KeychainSwift().get(urlMd5) else { return false }
//
//        let key = (timestamp + "_" + urlMd5).md5()
//        // pwd encrypt
//        return KeychainSwift().set(privateKey, forKey: key)
//    }
//
////    /// Dapp 使用，白名单保存 priv，存取用
//    static func getDAppWhite(url: String) -> String? {
//
//        let urlMd5 = url.urlEncoded.md5()
//
//        guard let timestamp = KeychainSwift().get(urlMd5) else { return nil }
//        let key = (timestamp + "_" + urlMd5).md5()
//        return KeychainSwift().get(key)
//    }
//
//    @discardableResult
//    static func deleteDAppWhite(url: String) -> Bool {
//
//        let urlMd5 = url.urlEncoded.md5()
//
//        guard let timestamp = KeychainSwift().get(urlMd5) else { return false }
//        let key = (timestamp + "_" + urlMd5).md5()
//        return KeychainSwift().delete(key) && KeychainSwift().delete(urlMd5)
//    }
}

extension AElfWallet {
    
    static func saveBiometric(password: String) {
        KeychainSwift().set(password, forKey: biometricKey())
    }
    
    static func getBiometricPassword() -> String? {
        return KeychainSwift().get(biometricKey())
    }
    
    @discardableResult
    static func deleteBiometricPassword() -> Bool {
        return KeychainSwift().delete(biometricKey())
    }
    
    private static func biometricKey() -> String {
        return "\(UUID.keyChainUUID)_Biometric".md5()
    }
}

extension AElfWallet {
    
    static var isBackup: Bool? {
        set { KeychainSwift().set(newValue ?? false, forKey: "aelf_isBackup")}
        get { return KeychainSwift().getBool("aelf_isBackup") }
    }
    static var importFromKeystore: Bool {
        set { KeychainSwift().set(newValue, forKey: "aelf_importFromKeystore")}
        get { return KeychainSwift().getBool("aelf_importFromKeystore") ?? false }
    }
}

//MARK: Transfer
extension AElfWallet {
    
    /// AElf 主链转账，有节点
    ///
    /// - Parameters:
    ///   - pwd: 密码
    ///   - toAddress: 接收地址
    ///   - amount: 数量
    ///   - symbol: 币名
    ///   - callback: 回调
    static func transferNode(pwd:String,
                             toAddress:String,
                             amount: Int,
                             symbol:String,
                             memo: String?,
                             nodeURL: String,
                             contractAddress: String,
                             callback: AElfBrowserView.TransferCallback?)  {
        guard let privateKey = self.getPrivateKey(pwd: pwd) else { callback?(nil); return }
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.transferNode(privateKey: privateKey,
                                             toAddresss: toAddress,
                                             amount: amount,
                                             symbol: symbol,
                                             memo: memo,
                                             contractAddress: contractAddress,
                                             nodeURL: nodeURL,
                                             callback: callback)
    }
    
    /// AElf 跨链转账
    ///
    /// - Parameters:
    ///   - pwd: 密码
    ///   - toAddress: 接收地址
    ///   - mainChainID: 目标链 id 
    ///   - issueChainID: 是这个token的发行链
    ///   - amount: 数量
    ///   - symbol: 币名
    ///   - memo: 备注，可选
    ///   - fromNode: 发送节点地址
    ///   - toNode: 接收节点地址
    ///   - callback: 回调
    static func transferCross(pwd:String,
                              fromNode: String,
                              toNode: String,
                              toAddress:String,
                              mainChainID: String,
                              issueChainID: String,
                              fromTokenContractAddress:String,
                              fromCrossChainContractAddress:String,
                              toTokenContractAddress:String,
                              toCrossChainContractAddress:String,
                              fromChainName: String,
                              toChainName: String,
                              symbol:String,
                              memo: String?,
                              amount:Int,
                              callback: AElfBrowserView.TransferCallback?)  {
        guard let privateKey = self.getPrivateKey(pwd: pwd) else { callback?(nil); return }
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        
        appDelegate.browserView.transferCrossElfCall(privateKey: privateKey,
                                                     fromNode: fromNode,
                                                     toNode: toNode,
                                                     toAddress: toAddress,
                                                     mainChainID: mainChainID,
                                                     issueChainID: issueChainID,
                                                     fromTokenContractAddress:fromTokenContractAddress,
                                                     fromCrossChainContractAddress:fromCrossChainContractAddress,
                                                     toTokenContractAddress:toTokenContractAddress,
                                                     toCrossChainContractAddress:toTokenContractAddress,
                                                     fromChainName: fromChainName,
                                                     toChainName: toChainName,
                                                     symbol: symbol,
                                                     memo: memo,
                                                     amount: amount,
                                                     callback: callback)
    }
    
    
    /// AElf 跨链接收
    ///
    /// - Parameters:
    ///   - pwd: 密码
    ///   - toAddress: 接收地址
    ///   - amount: 数量
    ///   - symbol: 币名
    ///   - memo: 备注，可选
    ///   - sendNode: 发送节点地址
    ///   - receiveNode: 接收节点地址
    ///   - callback: 回调
    static func transferCrossReceive(pwd:String,
                                     fromNode: String,
                                     toNode: String,
                                     mainChainID: String,
                                     issueChainID: String,
                                     fromTokenContractAddress:String,
                                     fromCrossChainContractAddress:String,
                                     toTokenContractAddress:String,
                                     toCrossChainContractAddress:String,
                                     fromChainName: String,
                                     toChainName: String,
                                     txID: String,
                                     callback: AElfBrowserView.TransferCallback?)  {
        guard let privateKey = self.getPrivateKey(pwd: pwd) else { callback?(nil); return }
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        
        appDelegate.browserView.transferCrossReceiveElfCall(privateKey: privateKey,
                                                            fromNode: fromNode,
                                                            toNode: toNode,
                                                            mainChainID: mainChainID,
                                                            issueChainID: issueChainID,
                                                            fromTokenContractAddress:fromTokenContractAddress,
                                                            fromCrossChainContractAddress:fromCrossChainContractAddress,
                                                            toTokenContractAddress:toTokenContractAddress,
                                                            toCrossChainContractAddress:toCrossChainContractAddress,
                                                            fromChainName: fromChainName,
                                                            toChainName: toChainName,
                                                            txID: txID,
                                                            callback: callback)
    }
    
    
    /// AElf 跨链结果查询。
    ///
    /// - Parameters:
    ///   - nodeURL: 对应链 URL
    ///   - txID: String txID
    ///   - callback: 回调, result.success = 1 则转账成功
    static func transferCrossGetTxResultCall(nodeURL: String,
                                             txID: String,
                                             callback: AElfBrowserView.TransferCallback?)  {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        
        appDelegate.browserView.transferCrossGetTxResultCall(nodeURL: nodeURL,
                                                             txID: txID,
                                                             callback: callback)
    }
    
    
    
    /// Dapp Invoke 或 InvokeRead 方法。
    /// - Parameters:
    ///   - pwd: 密码，invoke 需要授权，invokeRead 不需要，随便找个私钥就行。
    ///   - id: 事件 id
    ///   - nodeURL: 节点地址
    ///   - action: 事件名
    ///   - contractMethod: 合约方法名
    ///   - contractAddress: 合约地址
    ///   - argumentsInput: 参数
    ///   - callback: 回调
    static func dappInvokeOrInvokeReadJS(privateKey: String,
                                         id: String,
                                         nodeURL: String,
                                         action: String,
                                         contractMethod: String,
                                         contractAddress: String,
                                         argumentsInput: [Any],
                                         callback: AElfBrowserView.DappCallback?) {
//        // 写死的1个私钥
//        var privateKey = ""
//        if let pwd = pwd { // invoke
//            guard let priv = self.getPrivateKey(pwd: pwd) else { callback?(nil); return }
//            privateKey = priv
//        }else { // invokeRead
//            privateKey = "bdb3b39ef4cd18c2697a920eb6d9e8c3cf1a930570beb37d04fb52400092c42b"
//        }
        
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.dappInvokeOrInvokeReadJS(privateKey: privateKey,
                                                         id: id,
                                                         nodeURL: nodeURL,
                                                         action: action,
                                                         contractMethod: contractMethod,
                                                         contractAddress: contractAddress,
                                                         argumentsInput: argumentsInput,
                                                         callback: callback)
    }
    
    
    
    /// Dapp 调获取合约方法名
    /// - Parameters:
    ///   - id: 本次调用事件 id
    ///   - action: 事件类型
    ///   - params: 参数
    ///   - callback: 回调
    static func dappGetContractMethods(id: String,
                                       address: String,
                                       nodeUrl: String,
                                       appId: String,
                                       action: String,
                                       params: Dictionary<String, Any>,
                                       callback: AElfBrowserView.DappCallback?) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.dappGetContractMethods(id: id,
                                                       address: address,
                                                       nodeUrl: nodeUrl,
                                                       appId: appId,
                                                       action: action,
                                                       params: params,
                                                       callback: callback)
    }
    
    /// Dapp 调用 js api 方法。
    /// - Parameters:
    ///   - id: 本次调用事件 id
    ///   - appId: appId
    ///   - action: 事件类型
    ///   - apiPath: api 路径
    ///   - argumentsInput: 传递的参数
    ///   - callback: 回调
    static func dappAPIJS(id: String,
                          nodeURL: String,
                          action: String,
                          apiPath: String,
                          argumentsInput: [Any],
                          callback: AElfBrowserView.DappCallback?) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.dappAPIJS(id: id,
                                          nodeURL: nodeURL,
                                          action: action,
                                          apiPath: apiPath,
                                          argumentsInput: argumentsInput,
                                          callback: callback)
    }
    
    
    static func generalKeyPair(callback: AElfBrowserView.KeyPairCallback?) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.generalKeyPair(callback: callback)
    }
    
    static func keyPairSign(message: String,
                            privateKey: String,
                            callback: AElfBrowserView.KeyPairCallback?) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.keyPairSign(message: message, privateKey: privateKey, callback: callback)
    }
    
    static func keyPairVerify(signature: String,
                              message: String,
                              publicKey: String,
                              callback: AElfBrowserView.KeyPairCallback?) {
        let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
        appDelegate.browserView.keyPairVerify(signature: signature, message: message, publicKey: publicKey, callback: callback)
    }
}
