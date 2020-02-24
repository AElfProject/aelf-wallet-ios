//
//  AElfBrowserView.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/24.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import WebKit
import WKWebViewJavascriptBridge
import ObjectMapper


class AElfBrowserView: UIView {
    public typealias KeyStoreCallback = (_ result:KeyStoreResult?) -> Void
    public typealias TransferCallback = (_ result:TransferResult?) -> Void
    public typealias CreatedWalletCallback = (_ result:WalletResult?) -> Void
    public typealias DappCallback = (_ result:DappResult?) -> Void
    public typealias KeyPairCallback = (_ result:KeyPairResult?) -> Void
    
    
    private let webView = WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
    private var bridge: WKWebViewJavascriptBridge!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(webView)
        webView.navigationDelegate = self
        bridge = WKWebViewJavascriptBridge(webView: webView)
        
        #if DEBUG
        bridge.isLogEnable = true
        #endif
        
        loadHTMLFile()
    }
    func loadHTMLFile() {
        
        guard let elfPath = Bundle.main.path(forResource: "minaelf_iOS", ofType: "html") else {
            fatalError("minaelf_iOS.html 不存在。")
        }
        
        do {
            let pageHtml = try String(contentsOfFile: elfPath, encoding: .utf8)
            let baseURL = URL(fileURLWithPath: elfPath)
            webView.loadHTMLString(pageHtml, baseURL: baseURL)
            logInfo("load elfPath : success!")
        } catch {
            logDebug("webView LoadAELFError error: \(error)")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func getWalletKeyStoreCall(privateKey: String,
                                      address: String,
                                      password: String,
                                      callback: KeyStoreCallback? = nil) {
        let keystoreJson = ["privateKey":privateKey,
                            "address":address,
                            "password":password]
        bridge.call(handlerName: "getWalletKeyStoreJS", data: keystoreJson) { (result) in
            guard let result = result as? String,let keyStore = KeyStoreResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(keyStore)
        }
    }
    public func importWalletKeyStoreCall(keyStore: String,
                                         password:String,
                                         callback: CreatedWalletCallback? = nil) {
        let keystoreJson = ["keystore":keyStore,
                            "password":password]
        bridge.call(handlerName: "importWalletKeyStoreJS", data: keystoreJson) { (result) in
            guard let result1 = result as? String,let wallet = WalletResult(JSONString: result1) else {
                callback?(nil)
                return
            }
            callback?(wallet)
        }
    }
    public func importWalletPrivateKeyCall(privateKey: String,
                                         password:String,
                                         callback: CreatedWalletCallback? = nil) {
        let keystoreJson = ["privateKey":privateKey,
                            "password":password]
        bridge.call(handlerName: "importWalletPrivateKeyJS", data: keystoreJson) { (result) in
            guard let result1 = result as? String,let wallet = WalletResult(JSONString: result1) else {
                callback?(nil)
                return
            }
            callback?(wallet)
        }
    }
    
    /// 根据助记词创建 Wallet。
    ///
    /// - Parameters:
    ///   - mnemonic: 助记词，固定格式：12个字母以空格隔开。
    ///   - callback: 回调
    public func createdWalletCall(mnemonic: String, callback: CreatedWalletCallback? = nil) {
        let mnemonicJson = ["mnemonic":mnemonic]
        bridge.call(handlerName: "getWalletByMnemonicJS", data: mnemonicJson) { (result) in
            guard let result = result as? String,let wallet = WalletResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(wallet)
        }
    }
    
}

//MARK: AElf Transfer
extension AElfBrowserView {
    
    /// AElf 同链转账
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - toAddresss: 接收地址
    ///   - amount: 数量/金额
    ///   - symbol: symbol
    ///   - memo: 备注
    ///   - contractAddress: 接收链合约地址
    ///   - nodeURL: 接收链节点 URL
    ///   - callback: 结果回调，success = 1 转账成功
    public func transferNode(privateKey: String,
                             toAddresss:String,
                             amount:Int,
                             symbol:String,
                             memo: String?,
                             contractAddress: String,
                             nodeURL: String,
                             callback: TransferCallback?) {
        let transferJson =  ["privateKey":privateKey,
                             "toAddress":toAddresss,
                             "symbol":symbol,
                             "nodeUrl": nodeURL,
                             "contractAt":contractAddress,
                             "memo": memo ?? "",
                             "amount":String(amount)]
        logInfo("同链转账 - 请求参数：\(transferJson)")
        bridge.call(handlerName: "transferElfJS", data: transferJson) { (result) in
            guard let result = result as? String, let transfer = TransferResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    /// AElf 跨链转账。
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - fromNode: 发送链节点 URL
    ///   - toNode: 接收链节点 URL
    ///   - toAddresss: 接收地址
    ///   - mainChainID: chainID // 主网为  9992731
    ///   - issueChainID: chainID // 主网为  9992731
    ///   - symbol: symbol
    ///   - memo: 备注
    ///   - amount: 金额/数量
    ///   - callback: 回调, result.success = 1 则转账成功
    public func transferCrossElfCall(privateKey: String,
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
                                     callback: TransferCallback?) {
        let transferJson =  ["privateKey":privateKey,
                             "fromNode": fromNode,
                             "toNode": toNode,
                             "toAddress":toAddress,
                             "mainChainId": mainChainID,
                             "issueChainId": issueChainID,
                             "fromTokenContractAddress":fromTokenContractAddress,
                             "fromCrossChainContractAddress":fromCrossChainContractAddress,
                             "toTokenContractAddress":toTokenContractAddress,
                             "toCrossChainContractAddress":toCrossChainContractAddress,
                             "fromChainName":fromChainName,
                             "toChainName":toChainName,
                             "symbol":symbol,
                             "memo":memo ?? "",
                             "amount":String(amount)]
        logInfo("跨链转账 - 请求参数：\(transferJson)")
        let startTime = CFAbsoluteTimeGetCurrent()
        bridge.call(handlerName: "transferCrossChainJS", data: transferJson) { (result) in
            debugPrint("跨链转账JS耗时：%f 毫秒", (CFAbsoluteTimeGetCurrent() - startTime)*1000)
            guard let result = result as? String, let transfer = TransferResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    
    /// AElf 跨链接收。
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - fromNode: 发送链节点 URL
    ///   - toNode: 接收链节点 URL
    ///   - mainChainID: chainID // 主网为  9992731
    ///   - issueChainID: chainID // 主网为  9992731
    ///   - txID: String txID
    ///   - callback: 回调, result.success = 1 则转账成功
    public func transferCrossReceiveElfCall(privateKey: String,
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
                                            callback: TransferCallback?) {
        let transferJson =  ["privateKey":privateKey,
                             "fromNode": fromNode,
                             "toNode": toNode,
                             "mainChainId": mainChainID,
                             "issueChainId": issueChainID,
                             "fromTokenContractAddress":fromTokenContractAddress,
                             "fromCrossChainContractAddress":fromCrossChainContractAddress,
                             "toTokenContractAddress":toTokenContractAddress,
                             "toCrossChainContractAddress":toCrossChainContractAddress,
                             "fromChainName":fromChainName,
                             "toChainName":toChainName,
                             "txID":txID]
        logInfo("跨链 Receive - 请求参数：\(transferJson)")
        bridge.call(handlerName: "transferCrossChainReceiveJS", data: transferJson) { (result) in
            guard let result = result as? String, let transfer = TransferResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    /// AElf 跨链结果查询。
    ///
    /// - Parameters:
    ///   - privateKey: 私钥
    ///   - fromNode: 发送链节点 URL
    ///   - toNode: 接收链节点 URL
    ///   - mainChainID: chainID // 主网为  9992731
    ///   - issueChainID: chainID // 主网为  9992731
    ///   - txID: String txID
    ///   - callback: 回调, result.success = 1 则转账成功
    public func transferCrossGetTxResultCall(nodeURL: String,
                                             txID: String,
                                             callback: TransferCallback?) {
        let transferJson =  ["nodeURL": nodeURL, "txID":txID]
        logInfo("转账结果查询 - 请求参数：\(transferJson)")
        bridge.call(handlerName: "transferCrossChainGetTxResultJS", data: transferJson) { (result) in
            guard let result = result as? String, let transfer = TransferResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    public func dappInvokeOrInvokeReadJS(privateKey: String,
                                         id: String,
                                         nodeURL: String,
                                         action: String,
                                         contractMethod: String,
                                         contractAddress: String,
                                         argumentsInput: [Any],
                                         callback: DappCallback?) {
        
        let json =  ["privateKey":privateKey,
                     "id":id,
                     "nodeURL": nodeURL,
                     "action": action,
                     "contractMethod":contractMethod,
                     "contractAddress":contractAddress,
                     "argumentsInput":argumentsInput] as [String : Any]
        logInfo("InvokeOrRead - 请求参数：\(json)")
        bridge.call(handlerName: "invokeOrInvokeReadJS", data: json) { (result) in
            guard let result = result as? String, let transfer = DappResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    public func dappAPIJS(id: String,
                          nodeURL: String,
                          action: String,
                          apiPath: String,
                          argumentsInput: [Any],
                          callback: DappCallback?) {
        
        let json =  ["id":id,
                     "nodeURL": nodeURL,
                     "action":action,
                     "apiPath":apiPath,
                     "argumentsInput":argumentsInput] as [String : Any]
        logInfo("dappAPIJS - 请求参数：\(json)")
        bridge.call(handlerName: "dappAPIJS", data: json) { (result) in
            guard let result = result as? String, let transfer = DappResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(transfer)
        }
    }
    
    
    public func generalKeyPair(callback: KeyPairCallback?) {
        bridge.call(handlerName: "generalKeyPair", data: nil) { result in
            guard let result = result as? String, let keypair = KeyPairResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(keypair)
        }
    }
    
    public func keyPairSign(message: String,
                            privateKey: String,
                            callback: KeyPairCallback?) {
        let data = ["message":message,"privateKey":privateKey]
        bridge.call(handlerName: "keyPairSign", data: data) { result in
            guard let result = result as? String, let keypair = KeyPairResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(keypair)
        }
    }
    
    public func keyPairVerify(signature: String,
                              message: String,
                              publicKey: String,
                              callback: KeyPairCallback?) {
        let data = ["signature":signature,
                    "message":message,
                    "publicKey":publicKey]
        bridge.call(handlerName: "keyPairVerify", data: data) { result in
            guard let result = result as? String, let keypair = KeyPairResult(JSONString: result) else {
                callback?(nil)
                return
            }
            callback?(keypair)
        }
    }
    
}

extension AElfBrowserView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logDebug("webViewDidStartLoad")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logDebug("webViewDidFinishLoad")
    }
}
