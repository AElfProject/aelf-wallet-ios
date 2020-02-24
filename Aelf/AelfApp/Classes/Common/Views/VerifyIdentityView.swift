//
//  VerifyIdentityView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/7/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class VerifyIdentityView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var pwdButton: UIButton!

    private var bioMetricVerify: ((VerifyIdentityView) -> Void)?,passwordVerify: ((VerifyIdentityView) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.frame = screenBounds

        if BioMetricAuthenticator.shared.faceIDAvailable() {
            self.titleLabel.text = "Facial Recognition".localized()
            self.touchButton.setImage(UIImage(named: "faceid_large"), for: .normal)

        } else if BioMetricAuthenticator.shared.touchIDAvailable() {
            self.titleLabel.text = "Please verify with fingerprint".localized()
            self.touchButton.setImage(UIImage(named: "touchid_large"), for: .normal)
        }else {
            self.titleLabel.text = "Login with password".localized()
            self.touchButton.setImage(nil, for: .normal)
        }
    }

    class func loadView(bioMetricVerify: ((VerifyIdentityView) -> Void)?,
                    passwordVerify: ((VerifyIdentityView) -> Void)?) -> VerifyIdentityView {

        let v = VerifyIdentityView.loadFromNib(named: VerifyIdentityView.className) as! VerifyIdentityView
        v.bioMetricVerify = bioMetricVerify
        v.passwordVerify = passwordVerify

        return v
    }


    @IBAction func touchButtonTapped(_ sender: Any) {
        bioMetricVerify?(self)
    }


    @IBAction func pwdButtonTapped(_ sender: Any) {
        passwordVerify?(self)
    }


}


// MARK: Show and Hide

extension VerifyIdentityView {

    func show() {
        if self.superview != nil { return }
        guard let window = UIApplication.shared.keyWindow else { return }

        window.addSubview(self)
    }

    func dismiss(animated: Bool = false) {
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
