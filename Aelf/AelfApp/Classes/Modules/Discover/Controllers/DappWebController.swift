//
//  DappWebController.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/8.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import WebKit

struct DappItem {
    let url: String
    let name: String
}

// 与安卓一致的随机生成的私钥。
private let dappDefaultSignPrivateKey = "bdb3b39ef4cd18c2697a920eb6d9e8c3cf1a930570beb37d04fb52400092c42b"

class DappWebController: BaseController {
    
    let item: DappItem
    init(item: DappItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var wallet: DappWallet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = item.name
        
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(progressView)
        
        webView.loadURLString(item.url)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addUserContentController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeUserContentController()
    }
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 2)
        progressView.backgroundColor = UIColor.white
        progressView.tintColor = UIColor.master
        
        progressView.trackTintColor = UIColor.white
        return progressView
    }()
    
    lazy var webView: DappWebView = {
        let web = DappWebView(frame: self.view.bounds)
        web.dappDelegate = self
        return web
    }()
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.webView.estimatedProgress)
        }
    }
    
    deinit {
        
    }
    
}


extension DappWebController: DappWebViewDelegate {
    
    func dappWebView(_ webView: DappWebView, connect item: DappWebItem) {
        parseConnectItem(item: item)
    }
    
    func dappWebView(_ webView: DappWebView, account item: DappWebItem) {
        
        let title = "Dapp request visite wallet address".localized()
        let content = "Dapp request visite description".localizedFormat(self.item.name)
        DappConfirmView.show(title: title, content: content) { [weak self] v in
            self?.parseAccountData(item: item)
        }
    }
    
    
    func dappWebView(_ webView: DappWebView, api item: DappWebItem) {
        parseApiData(item: item)
    }
    
    func dappWebView(_ webView: DappWebView, disconnect item: DappWebItem) {
        parseDisconnectItem(item)
    }
    
    func dappWebView(_ webView: DappWebView, invoke item: DappWebItem) {
        parseInvokeItem(item)
    }
    
    func dappWebView(_ webView: DappWebView, invokeRead item: DappWebItem) {
        parseInvokeReadItem(item)
    }
    
    func dappWebView(_ webView: DappWebView, getContractMethods item: DappWebItem) {
        parseContractItem(item)
    }
    
    func dappWebView(_ webView: DappWebView, error: DappError, showText: String) {
        logInfo("Error: \(showText)\n\(error)")
    }
    
    func dappWebView(_ webView: DappWebView, log: String?) {
        
    }
    
    func dappWebView(_ webView: DappWebView, didFinish navigation: WKNavigation) {
        logDebug("加载完成")
        let showTitle = webView.webView.title
        if showTitle != ""  {
            title = showTitle
        }
        
        progressView.progress = 1.0
        UIView.animate(withDuration: 0.5, animations: {
            self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        }, completion: { _ in
            self.progressView.isHidden = true
        })
    }
    
    func dappWebView(_ webView: DappWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        logDebug("开始加载")
        progressView.progress = 0.0
        progressView.isHidden = false
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        view.bringSubviewToFront(progressView)
    }
    
    func dappWebView(_ webView: DappWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error) {
        logDebug("加载失败")
        progressView.progress = 0.0
        progressView.isHidden = true
    }
}


extension DappWebController {
    
    // https://kjur.github.io/jsrsasign/sample/sample-ecdsa.html
    private func parseConnectItem(item: DappWebItem) {
        
        guard let param = item.params else {
            let info = "Missing parameters".localized() + ": `params`"
            logInfo(info)
            self.sendErrorMessage(info,code: 1003, id: item.id)
            return
        }
        guard let encryptType = param.encryptAlgorithm, encryptType == "secp256k1" else {
            let info = "Encryption type is not supported".localized() + ":" + (param.encryptAlgorithm ?? "")
            logInfo(info)
            self.sendErrorMessage(info,code: 1005, id: item.id)
            return
        }
        
        guard let signature = param.signature,let dappPublicKey = param.publicKey,let timestamp = param.timestamp else {
            let info = "Missing parameters".localized()
            logInfo(info)
            self.sendErrorMessage(info,code: 1003, id: item.id)
            return
        }
        
        DappWallet.verify(signature: signature, message: timestamp, dappPublicKey: dappPublicKey) { [weak self] verifyResult in
            
            guard let self = self else { return }
            
            guard verifyResult else {
                logInfo("Invalid argument".localized())
                self.sendErrorMessage("Invalid argument".localized(),code: 1006, id: item.id)
                return }
            
            logInfo("验证结果：\(verifyResult)")
            
            if !self.isValidTime(timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            
            DappWallet.generalDappWallet { [weak self] wallet in
                
                guard let wallet = wallet else {
                    logInfo("生成私钥失败".localized())
                    return
                }
                
                self?.wallet = wallet
                self?.wallet?.dappPublicKey = dappPublicKey
                
                logDebug("\n--------------- General KeyPair ------------- 生成的公钥：\(wallet.publicKey)\n私钥：\(wallet.privateKey)\n")
                
                let random = String(randomOfLength: 32)
                let hexRandom = random.data(using: .utf8)!.hex
                logInfo("产生的随机数：\(random)")
                logInfo("随机数的 Hex ：\(hexRandom)")
                wallet.sign(message: random) { [weak self] signatureRandom in
                    
                    guard let signatureRandom = signatureRandom else {
                        SVProgressHUD.showError(withStatus: "Signature failure".localized())
                        self?.sendErrorMessage("Signature failure".localized(),code: 1007, id: item.id)
                        return
                    }
                    let dict = ["random":hexRandom,
                                "publicKey":wallet.publicKey,
                                "signature":signatureRandom] as [String : Any]
                    
                    let result = [
                        "code":0,
                        "msg":"success",
                        "error":[],
                        "data":dict] as [String : Any]
                    
                    let sendParams = ["result":result,"id":item.id] as [String : Any]
                    
                    logInfo("Connect 构造签名数据：\(dict)")
                    self?.webView.sendMessageToWeb(data: sendParams)
                }
            }
        }
        
    }
    
    func parseAccountData(item: DappWebItem) {
        
        guard let wallet = wallet else {
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        
        guard let params = item.params else {
            logInfo("缺少 Params ")
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        
        params.parseParams(dappPublicKey: wallet.dappPublicKey) { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            
            logInfo("apiItem: \(apiItem)")
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            
            let accounts = [["name":App.walletName ?? "","address":App.address,"publicKey":wallet.publicKey]]
            let dict = ["accounts":accounts,"chains":self.getChains()] as [String : Any]
            
            // result 字典转码并签名
            let result = ["code":0,"msg":"success","error":[],"data":dict] as [String : Any]
            let originalResult = result.jsonString()!.urlEncoded
            logInfo("Account 原始构造数据：\(result)")
            wallet.sign(message: originalResult) { [weak self] signature in
                guard let signature = signature else {
                    SVProgressHUD.showError(withStatus: "Signature failure".localized())
                    self?.sendErrorMessage("Signature failure".localized(),code: 1007, id: item.id)
                    return
                }
                
                let sendParams = ["id":item.id,"result":["signature":signature,"originalResult":originalResult.base64Encoded!]] as [String : Any]
                //            logInfo("\(item.action) 签名结果： \(sendParams)")
                self?.webView.sendMessageToWeb(data: sendParams)
            }
        }
        
    }
    
    func parseApiData(item: DappWebItem) {
        
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        guard let params = item.params else {
            logInfo("缺少 Params ")
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        
        params.parseParams(dappPublicKey: wallet.dappPublicKey, callback: { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            
            logInfo("apiItem: \(apiItem)")
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            self.openDappAPI(id: item.id, action: item.action, item: apiItem)
            
        })
    }
    
    func parseInvokeItem(_ item: DappWebItem) {
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        guard let params = item.params else {
            logInfo("缺少 Params ");
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        params.parseParams(dappPublicKey: wallet.dappPublicKey, callback: { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            
            // 如果从 keystore 能够取得白名单私钥，则不需要弹框请求授权。
            let url = self.item.url
            if let pri = DappVerifyManager.getPrivateKey(url: url) {
                self.invokeEventHandler(privateKey: pri, id: item.id, action: item.action, item: apiItem)
            } else {
                // 弹框授权
                
                var arguments = json
                if let input = apiItem.argumentsInput, let ags = input as? [[String: Any]] {
                    let result = ags.map({ $0.jsonString(prettify: true) }).compactMap({ $0 }).joined(separator: "")
                    arguments = result
                }
                logInfo("转换后的输出数据：\(arguments)")
                let addr = "Dapp sign address".localized() + App.address
                let content = addr + "\n\n" + "Dapp sign content".localized() + "\n" + arguments
                self.showPasswordView(content: content,id: item.id, callback: { [weak self] privateKey in
                    if let privateKey = privateKey {
                        self?.invokeEventHandler(privateKey: privateKey,id: item.id,action: item.action, item: apiItem)
                    }
                })
            }
        })
        
    }
    
    func parseInvokeReadItem(_ item: DappWebItem) {
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        guard let params = item.params else {
            logInfo("缺少 Params ")
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        params.parseParams(dappPublicKey: wallet.dappPublicKey, callback: { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            
            self.invokeEventHandler(privateKey: dappDefaultSignPrivateKey, id: item.id,action: item.action, item: apiItem)
        })
        
    }
    
    
    func parseContractItem(_ item: DappWebItem) {
        
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        guard let params = item.params else {
            logInfo("缺少 Params ")
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        params.parseParams(dappPublicKey: wallet.dappPublicKey, callback: { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            
            self.getContractsMethods(id: item.id, appId: item.appId, action: item.action, address: apiItem.address, item:apiItem)
        })
    }
    
    func showPasswordView(content: String, id: String,callback: @escaping ((String?) -> ())) {
        
        let url = self.item.url
        DappSignConfirmView.show(content: content, confirmClosure: { view in
            let pwd = view.pwdField.text ?? ""
            if let privateKey = AElfWallet.getPrivateKey(pwd: pwd) {
                view.pwdField.resignFirstResponder()
                view.hide()
                callback(privateKey)
                
                if view.isJoined { //确认时判断， 密码输入正确，且已勾选加入白名单
                    DappVerifyManager.addWhiteList(url: url, privateKey: privateKey)
                    logInfo("加入白名单：\(url)")
                }
                
            } else {
                view.showHint()
                callback(nil)
                SVProgressHUD.showError(withStatus: "Password Error".localized())
            }
        }) {
            self.sendErrorMessage("User cancelled".localized(), code: 1101, id: id)
        }
        
    }
    
    func parseDisconnectItem(_ item: DappWebItem) {
        
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            self.sendErrorMessage("Please sign in".localized(),code: 1004, id: item.id)
            return
        }
        guard let params = item.params else {
            self.sendErrorMessage("Missing parameters".localized() + ": params",code: 1003, id: item.id)
            return
        }
        params.parseParams(dappPublicKey: wallet.dappPublicKey, callback: { [weak self] (err, json) in
            guard let self = self else { return }
            if let err = err {
                logInfo(err.msg)
                self.sendErrorMessage(err.msg,code: 1000, id: item.id)
                return
            }
            guard let apiItem = DappAPIItem(JSONString: json) else {
                logInfo("数据解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: item.id)
                return
            }
            if !self.isValidTime(apiItem.timestamp) {
                self.sendErrorMessage("Invalid timestamp".localized(),code: 1001, id: item.id)
                return
            }
            logInfo("Disconnect Item: \(apiItem)")
            self.sendSuccessMessage(value: [:], id: item.id)
        })
        
    }
}


extension DappWebController {
        
    func getContractsMethods(id: String, appId: String, action: String, address: String, item: DappAPIItem) {
        
        guard let chain = ChainItem.getMainItem() else {
            GlobalDataManager.shared.checkAndUpdateData()
            return
        }
        let params = ["timestamp":item.timestamp,
                      "endpoint":item.endpoint,
                      "address":item.address]
        let nodeUrl = item.endpoint.length > 0 ? item.endpoint : chain.node.removeSlash()
        AElfWallet.dappGetContractMethods(id: id,
                                          address: address,
                                          nodeUrl:nodeUrl,
                                          appId: appId,
                                          action: action,
                                          params: params)
        { [weak self] result in
            guard let result = result else {
                self?.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: id)
                return }
            
            guard result.isOk else {
                logInfo("invoke 获取失败：\(result.err)")
                self?.sendErrorMessage(result.err,code:1000, id: id)
                return
            }
            
            guard let data = result.data else {
                self?.sendErrorMessage("Missing parameters".localized() + ": data",code: 1003, id: id)
                return
            }
            self?.sendSuccessMessage(value: data, id: id)
        }
    }
    
    func invokeEventHandler(privateKey: String,id: String,action: String, item: DappAPIItem) {
        
        guard let chain = ChainItem.getMainItem() else {
            GlobalDataManager.shared.checkAndUpdateData()
            return
        }
        let nodeUrl = item.endpoint.length > 0 ? item.endpoint : chain.node.removeSlash()
        AElfWallet.dappInvokeOrInvokeReadJS(privateKey: privateKey,
                                            id: id,
                                            nodeURL: nodeUrl,
                                            action: action,
                                            contractMethod: item.contractMethod,
                                            contractAddress: item.contractAddress,
                                            argumentsInput: item.argumentsInput ?? [])
        { [weak self] result in
            guard let result = result else {
                self?.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: id)
                return }
            
            guard result.isOk else {
                logInfo("invoke 获取失败：\(result.err)")
                self?.sendErrorMessage(result.err,code:1000, id: id)
                return
            }
            
            guard let data = result.data else {
                self?.sendErrorMessage("Missing parameters".localized() + ": data",code: 1003, id: id)
                return
            }
            self?.sendSuccessMessage(value: data, id: id)
        }
    }
    
    func openDappAPI(id: String,action: String,item: DappAPIItem) {
        
        guard let chain = ChainItem.getMainItem() else {
            GlobalDataManager.shared.checkAndUpdateData()
            return
        }
        
        AElfWallet.dappAPIJS(id: id,
                             nodeURL: chain.node,
                             action: action,
                             apiPath: item.apiPath,
                             argumentsInput: item.argumentsInput ?? [])
        { [weak self] (result) in
            guard let self = self else { return }
            guard let result = result else {
                logInfo("解析失败");
                self.sendErrorMessage("Data parsing failed".localized(),code: 1002, id: id)
                return }
            logInfo("API 回调结果：\(result)")
            
            guard result.isOk else {
                logInfo("openDappAPI Error: \(result.err)")
                self.sendErrorMessage(result.err,code:1000, id: id)
                return
            }
            
            guard let data = result.data else {
                self.sendErrorMessage("Missing parameters".localized() + ": data",code: 1003, id: id)
                return
            }
            
            self.sendSuccessMessage(value: data, id: id)
        }
    }
    
    func getChains() -> [[String:Any]] {
        var chains = [[String:Any]]()
        
        ChainItem.getItems().forEach({
            let c = ["chainId":$0.name,
                     "url":$0.node.removeSlash(),
                     "isMainChain":$0.isMain()] as [String : Any]
            chains.append(c)
        })
        return chains
    }
    
    func isValidTime(_ timestamp: String) -> Bool {
        let current = Date().unixTimestamp.int
        let value = current - (timestamp.int ?? 0)
        return value >= -5 && value <= 4*60 // 4分钟内有效； -5 为时间误差
    }
}

extension DappWebController {
    
    
    /// 失败消息发送。
    /// - Parameters:
    ///   - error: 失败消息内容
    ///   - id: 事件 id
    func sendErrorMessage(_ error: String,code: Int,id: String) {
        
        guard let wallet = wallet else {
            logInfo("Please sign in".localized())
            // 这里不调用sendErrorMessage， 否则死循环
            return
        }
        // result 字典转码并签名
        let result = ["code":code,"msg":error,"error":[error],"data":[:]] as [String : Any]
        let originalResult = result.jsonString()!.urlEncoded
        logInfo("Error 原始构造数据：\(result)")
        wallet.sign(message: originalResult) { [weak self] signature in
            guard let signature = signature else {
                SVProgressHUD.showError(withStatus: "Signature failure".localized())
                return
            }
            
            let sendParams = ["id":id,"result":["signature":signature,
                                                "originalResult":originalResult.base64Encoded!]] as [String : Any]
            //            logInfo("Error 签名结果： \(sendParams)")
            self?.webView.sendMessageToWeb(data: sendParams)
        }
        
        /*
         
         * 1001 时间戳无效：  Invalid timestamp
         * 1002 数据解析失败： Data parsing failed
         * 1003 缺少参数： Missing parameters
         * 1004 请先登录：Please sign in
         * 1005 加密类型不支持：Encryption type is not supported
         * 1006 参数无效： Invalid argument
         * 1007 签名失败： Signature failure
         * 1008 不支持的 action：Unsupported actions
         
         * 1100 未知错误： unknown error
         
         1101：用户取消
         1102：链节点无法连接
         1103：网络错误
         
         */
        
    }
    
    
    func sendSuccessMessage(value: Any,id: String) {
        
        // result 字典转码并签名
        let sendResult = ["code":0,"msg":"success","error":[],"data":value] as [String : Any]
        let originalResult = sendResult.jsonString()!.urlEncoded
        logInfo("Success 原始构造数据：\(sendResult)")
        
        self.wallet!.sign(message: originalResult) { [weak self] signature in
            guard let signature = signature else {
                SVProgressHUD.showError(withStatus: "Signature failure".localized())
                return
            }
            
            let sendParams = ["id":id,"result":["signature":signature,
                                                "originalResult":originalResult.base64Encoded!]] as [String : Any]
            self?.webView.sendMessageToWeb(data: sendParams)
        }
    }
    
}


