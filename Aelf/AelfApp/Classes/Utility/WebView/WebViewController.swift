//
//  Created by MacKun on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseController {
    
    let progressView = UIProgressView()
    var urlStr : String?
    var url: URL?
    var content : String?
    let wkWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    class func termsOfService() -> WebViewController {
        
        var  nextP = "zh"
        if let id = App.languageID, !id.contains("zh", caseSensitive: true) {
            nextP = "en"
        }

        let name = "UserProtocol_" + nextP
        guard let servicePath = Bundle.main.path(forResource:name, ofType: "html") else {
            fatalError("UserProtocol_zh/en html 不存在。")
        }
        let url = URL(fileURLWithPath: servicePath)

        let vc = WebViewController(url: url)
        //        vc.title = "Terms of service".localized()
        return vc

    }

    class func messageDetail(title:String, body:String) -> WebViewController {
        let vc = WebViewController.init(body: body)
        vc.title = title
        return vc
    }

    init(body: String) {

        let htmlhead = "<html lang=\"zh-cn\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, nickName-scalable=no\"></meta><style>img{max-width: 100%; width:auto; height:auto;}</style></head><body>"
        
        let htmlEnd = "</body></html>"

        let content = htmlhead + body + htmlEnd
        
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    init(urlStr:String) {
        self.url = URL(string: urlStr)
        super.init(nibName: nil, bundle: nil)
    }

    init(url:URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        viewConstraint()
        wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = url {
            let request = URLRequest(url: url)
            wkWebView.load(request)
        }  else  if let content = content {
            wkWebView.loadHTMLString(content, baseURL: nil)
        }   else {
            SVProgressHUD.showInfo(withStatus: "Invalid URL address".localized())
        }

    }
    func viewConstraint() {
        wkWebView.navigationDelegate = self
        //        wkWebView.scrollView.isScrollEnabled = false
        wkWebView.frame = view.bounds
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(wkWebView)

        progressView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 2)
        progressView.backgroundColor = UIColor.white
        progressView.tintColor = UIColor.master
        
        progressView.trackTintColor = UIColor.white
        view.addSubview(progressView)
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(wkWebView.estimatedProgress)
        }
    }
    
    deinit {
        wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
}

extension WebViewController: WKUIDelegate, WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        logDebug("开始加载")
        progressView.progress = 0.0
        progressView.isHidden = false
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        view.bringSubviewToFront(progressView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        logDebug("加载完成")
        let showTitle = webView.title
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logDebug("加载失败")
        progressView.progress = 0.0
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //禁止缩放
        //        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
        //        webView.evaluateJavaScript(javascript, completionHandler: nil)
        //
        //        logDebug("开始返回")
    }
}
