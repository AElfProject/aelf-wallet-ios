//
//  WalletLoadingView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule

enum loadingViewType {
    case createWallet   /// 创建钱包
    case importWallet   /// 导入钱包
    case verifyIdentity /// 验证身份

    var title: String {
        switch self {
        case .createWallet:
            return  "Creating AElf Wallet".localized()
        case .importWallet:
            return "Importing AElf Wallet".localized()
        case .verifyIdentity:
            return "Verify your identity".localized()
        }
    }
}

class WalletLoadingView: UIView {

    @IBOutlet weak var loadImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var pwdButton: UIButton!
    
    var task: Task?

    fileprivate var touchClosure: ((WalletLoadingView) -> Void)?
    fileprivate var pwdLoginClosure: ((WalletLoadingView) -> Void)?
    
    static func loadView(type: loadingViewType,
                         touchClosure: ((WalletLoadingView) -> Void)? = nil,
                         pwdLoginClosure: ((WalletLoadingView) -> Void)? = nil) -> WalletLoadingView {

        guard let v = WalletLoadingView.loadFromNib(named: WalletLoadingView.className) as? WalletLoadingView else {
            fatalError("找不到 Xib 文件。")
        }
        v.titleLabel.text = type.title
        v.touchClosure = touchClosure
        v.pwdLoginClosure = pwdLoginClosure

        if type == .verifyIdentity {
            v.loadImgView.isHidden = true
            v.touchButton.isHidden = false
            v.pwdButton.isHidden = false
        } else {
            v.loadImgView.isHidden = false
            v.touchButton.isHidden = true
            v.pwdButton.isHidden = true
            v.titleLabel.isHidden = true
        }

        return v
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.frame = screenBounds
        touchButton.setTitlePosition(position: .bottom, spacing: 15)

        loadLoadingImages()
    }

    func loadLoadingImages() {

        let duration = 0.75
        task = Plan.now.concat(.every(duration.seconds)).do { [weak self] in
            self?.rotation(duration)
            logDebug("旋转。")
        }
    }

    deinit {
        logInfo("释放 LoadingView！")
    }

    fileprivate func rotation(_ duration: TimeInterval) {
        self.loadImgView.rotate(byAngle: CGFloat.pi,
                                ofType: UIView.AngleUnit.radians,
                                animated: true,
                                duration: duration,
                                completion: nil)
    }

    @IBAction func touchButtonTapped(_ sender: Any) {
        touchClosure?(self)
    }

    @IBAction func pwdButtonTapped(_ sender: UIButton) {
        pwdLoginClosure?(self)
    }
    
    func show() {
        if self.superview != nil { return }
        guard let window = UIApplication.shared.keyWindow else { return }

        window.addSubview(self)
    }

    func dismiss(animated: Bool = false) {
        task?.cancel()

        if !animated {
            self.removeFromSuperview()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }
}
