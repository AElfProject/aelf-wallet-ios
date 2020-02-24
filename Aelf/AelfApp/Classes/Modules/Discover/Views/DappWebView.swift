//
//  DappWebView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore

protocol DappWebViewDelegate: AnyObject {
    func dappWebView(_ webView: DappWebView,connect item: DappWebItem) // 连接 Dapp，验证签名及交换公钥
    func dappWebView(_ webView: DappWebView,account item: DappWebItem) // 获取账号信息
    func dappWebView(_ webView: DappWebView,invoke item: DappWebItem)  //
    func dappWebView(_ webView: DappWebView,invokeRead item: DappWebItem)
    func dappWebView(_ webView: DappWebView,api item: DappWebItem) //
    func dappWebView(_ webView: DappWebView,disconnect item: DappWebItem) // 断开连接
    
    func dappWebView(_ webView: DappWebView,error: DappError,showText: String) //
    func dappWebView(_ webView: DappWebView,log: String?) //

    func dappWebView(_ webView: DappWebView, didStartProvisionalNavigation navigation: WKNavigation)
    func dappWebView(_ webView: DappWebView, didFinish navigation: WKNavigation)
    func dappWebView(_ webView: DappWebView, didFailProvisionalNavigation navigation: WKNavigation, withError error: Error)
}


class DappWebView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubViews()
    }
    
    weak var dappDelegate: DappWebViewDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubViews() {
        addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
     
    deinit {
        logInfo("释放 WebView ")
    }
    
    lazy var webView: WKWebView = {
        
        let config = WKWebViewConfiguration()
        config.preferences = .init()
        config.preferences.minimumFontSize = 12
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.userContentController = WKUserContentController()

        config.processPool = WKProcessPool()
        
        let webView = WKWebView(frame: self.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
 
        return webView
    }()
    
    func addUserContentController() {
        webView.configuration.userContentController.add(self, name: "JSCallback")
    }
    
    func removeUserContentController() {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "JSCallback")
    }
    
    private func setupMessageScript() {
        
        let source = "window.originalPostMessage = window.postMessage;" +
            "window.postMessage = function(message, targetOrigin, transfer) {" +
            "window.webkit.messageHandlers.JSCallback.postMessage(message);" +
            "if (typeof targetOrigin !== 'undefined') {" +
            "window.originalPostMessage(message, targetOrigin, transfer);" +
            "}" +
            "};"
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(script)
        webView.evaluateJavaScript(source, completionHandler: { (result, err) in
            if let result = result {
                logInfo("注入结果：\(result)")
            }else if let err = err {
                logInfo("注入 Err: \(err)")
            }
        })
        
    }
   
}

/// Public func
extension DappWebView {
    
    func loadURL(_ url:URL?) {
        if let url = url {
            logInfo("加载 URL: \(url)")
            let req = URLRequest(url: url)
            webView.load(req)
        }else {
            SVProgressHUD.showInfo(withStatus: "URL is invalid")
        }
    }
    
    func loadURLString(_ urlString: String) {
        loadURL(URL(string: urlString))
    }
}
 
extension DappWebView: WKNavigationDelegate,WKUIDelegate {
    
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        logInfo("Prompt = \(prompt)")
        completionHandler(prompt)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dappDelegate?.dappWebView(self, error: DappError.error(error),showText: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        dappDelegate?.dappWebView(self, didStartProvisionalNavigation: navigation)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logDebug("加载完成")
        dappDelegate?.dappWebView(self, didFinish: navigation)
        
        setupMessageScript()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dappDelegate?.dappWebView(self, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        logInfo("拦截Alert: \(message)")
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        logInfo("拦截Confirm: \(message)")
        completionHandler(true)
    }
    
    
}


extension DappWebView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        logInfo("接收的数据：\(message.body)")
        handlerPromptMessage(message: message)
    }
    
    
}


extension DappWebView {
    
    private func handlerPromptMessage(message: WKScriptMessage) {
        
        guard let originString = message.body as? String,originString.length > 0,
            let base64Encode = originString.components(separatedBy: "?params=").last ,
            let decode = base64Encode.base64Decoded else {
                let text = "Invalid argument".localized()
                dappDelegate?.dappWebView(self, error: DappError.message(text + (message.body as? String ?? "")),showText: text)
                return }
        
        let jsonString = decode.urlDecoded
        logInfo("解析出的JSON:\n\(jsonString)\n")
        
        guard let item = DappWebItem(JSONString: jsonString) else {
            let text = "Data parsing failed".localized()
            dappDelegate?.dappWebView(self, error: DappError.message(text + jsonString), showText: text)
            return
        }
        
        guard let type = DappActionType(rawValue: item.action) else {
            let text = "Unsupported actions".localized() + ":" + item.action
            dappDelegate?.dappWebView(self, error: DappError.message(text),showText: text)
            return
        }
        
        switch type {
        case .connect:
            dappDelegate?.dappWebView(self, connect: item)
        case .account:
            dappDelegate?.dappWebView(self, account: item)
        case .api:
            dappDelegate?.dappWebView(self, api: item)
        case .invoke:
            dappDelegate?.dappWebView(self, invoke: item)
        case .invokeRead:
            dappDelegate?.dappWebView(self, invokeRead: item)
        case .disconnect:
            dappDelegate?.dappWebView(self, disconnect: item)
        }
        
    }
}

extension DappWebView {
    
    private func sendMessage(base64: String) {
        
        guard let json = ["data": base64].jsonString() else {
            dappDelegate?.dappWebView(self, error: DappError.message("Signature failure"), showText: "Signature failure".localized())
            return
        }
        webView.evaluateJavaScript("window.dispatchEvent(new MessageEvent('message', \(json)));") { (result, err) in
            if let result = result {
                logInfo("Send 结果：\(result)")
            }else if let err = err {
                logInfo("Send Err: \(err)")
            }
        }
    }
    
    func sendMessageToWeb(data: [String: Any]) {
        let base64 = data.jsonString()!.urlEncoded.base64Encoded!
        sendMessage(base64: base64)
    }

}


