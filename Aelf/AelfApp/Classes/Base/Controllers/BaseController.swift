//
//  BaseController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class BaseController: UIViewController {

    let isLoading = BehaviorRelay(value: false)

    let headerRefreshTrigger = PublishSubject<Void>()
    let footerRefreshTrigger = PublishSubject<Void>()

    let emptyDataSetButtonTap = PublishSubject<Void>()
    fileprivate var emptyDataSetTitle = "" // 暂时用不到
    
    var emptyDataSetButtonTitle = "Retry".localized()
    var emptyDataSetDescription = BehaviorRelay<String>(value: "Empty Data".localized())
    var emptyDataSetImage = UIImage(named: "information")

    var emptyDataSetImageTintColor = BehaviorRelay<UIColor?>(value: nil)
    var emptyDataButonHidden = BehaviorRelay<Bool>(value: true)
    var isCanShowOtherMessageViews = true //

    override func viewDidLoad() {
        super.viewDidLoad()

        logDebug("进入：\(self.className)")

        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        if let count = navigationController?.viewControllers.count, count > 1 {
           addBackItem()
        }
        // 监听语言改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: NSNotification.language,
                                               object: nil)

        setTitleAttributes()
        configBaseInfo()
        languageChanged()

    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      view.endEditing(true)
    }

    func checkIsBackupMnemonic() {

        guard let isBackup = AElfWallet.isBackup else { return }
        guard AElfWallet.walletAddress().length > 0 && !isBackup else { return }
        isCanShowOtherMessageViews = false
        SecurityWarnView.show(title: "Security Warning".localized(),
                              body: "You have not backed up".localized(),
                              confirmTitle: "Backup Now".localized()) {
                                
                                asyncMainDelay(duration: 0.2, block: {
                                    self.showInputAlertView()
                                })
        }
        
    }

    func showInputAlertView() {

        SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
            if let pwd = pwd ,let mnemonic = AElfWallet.getMnemonic(pwd: pwd) {
                let walletVC = UIStoryboard.loadController(WalletRemindController.self, storyType: .wallet)
                walletVC.mnemonic = mnemonic
                walletVC.walletType = .backUp
                let nav = BaseNavigationController(rootViewController: walletVC)
                nav.modalPresentationStyle = .overFullScreen
                self.present(nav, animated: true, completion: nil)
            }
        })
        
    }

    public func configBaseInfo() {}

    //语言改变后回调重新设置
    @objc public func languageChanged() {}

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func headerRefresh() -> Observable<Void> {
        let refresh = Observable.of(Observable.just(()), headerRefreshTrigger).merge()
        return refresh
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        logDebug("释放：\(String(describing: Mirror(reflecting: self).subjectType))\n")
    }

}

extension BaseController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let count = self.navigationController?.viewControllers.count else { return false }
        return count > 1 ? true:false
    }
}


extension BaseController: DZNEmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: emptyDataSetTitle)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let value = emptyDataSetDescription.value

        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = 20
        paraph.alignment = .center
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16, weight: .semibold),
                          NSAttributedString.Key.foregroundColor: UIColor(hexString: "787F87")!,

                          NSAttributedString.Key.paragraphStyle: paraph]
        let att = NSAttributedString(string: value, attributes: attributes)

        return att
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyDataSetImage
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return emptyDataSetImageTintColor.value
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .clear
    }

}

extension BaseController: DZNEmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return !isLoading.value
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

//    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
//        emptyDataSetButtonTap.onNext(())
//    }
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        emptyDataSetButtonTap.onNext(())
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        let title = emptyDataButonHidden.value == true ? "" : emptyDataSetButtonTitle
        return NSAttributedString(string: title,
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.master])
    }


}
