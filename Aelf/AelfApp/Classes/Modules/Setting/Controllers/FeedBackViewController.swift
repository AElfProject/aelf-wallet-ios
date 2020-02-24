//
//  FeedBackViewController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/26.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class FeedBackViewController: BaseController {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Submit Feedback".localized()
        textView.placeholder = "Feed_content_placeholder".localized()
        textView.placeholderColor = .c78
        
        titleTF.placeholder = "Feed_title".localized()
        emailTF.placeholder = "Email_address".localized()
        emailTF.setPlaceHolderTextColor(.c78)
        titleTF.setPlaceHolderTextColor(.c78)
        
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        guard let title = titleTF.text,!title.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please enter Feedback title".localized())
            return }
        
        guard let desc = textView.text,!desc.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please enter Feedback contents".localized())
            return }
        
        guard let email = emailTF.text,!email.isEmpty else {
            SVProgressHUD.showInfo(withStatus: "Please enter E-mail".localized())
            return }
        
        SVProgressHUD.show()
        userProvider.requestData(.feedback(address: App.address,
                                           title: title,
                                           email: email, desc: desc))
            .subscribe(onNext: { (result) in
                SVProgressHUD.dismiss()
                if result.isOk {
                    SVProgressHUD.showInfo(withStatus: "Submit successfully".localized())
                    asyncMainDelay {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    SVProgressHUD.showInfo(withStatus: result.msg)
                }
            }).disposed(by: rx.disposeBag)
    }
}
