//
//  AboutUsController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class AboutUsController: BaseStaticTableController {

    @IBOutlet var buttonArray: [UIButton]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var verionLabel: UILabel!
    
    var viewModel = AboutUSViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        addBackItem()
        
        title = "About Us".localized()
        verionLabel.attributedText = versionAttribute()
    }

    func versionAttribute() -> NSAttributedString {
        let version = "V \(String.appVersion)".withFont(.systemFont(ofSize: 15)).withTextColor(.appBlack)
        let build = "(\(String.bundleVersion))".withFont(.systemFont(ofSize: 15)).withTextColor(.c78)

        return version + " " + build
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {

        var type = ShareType.wechat
        switch sender.tag {
        case 1000: // wechat
            type = .wechat
        case 1001: // telegram
            type = .telegram
        case 1002: // twitter
            type = .twitter
        case 1003:
            type = .facebook
        default:
            break
        }

        ShareAlertView.show(type: type,selectedResult: { type in
            logInfo(type.link)
            asyncMainDelay(duration: 0.25, block: {
                UIPasteboard.general.string = type.link
                SVProgressHUD.showSuccess(withStatus: "Copied".localized())
            })
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if indexPath.row == 3 {
            cell.indentationLevel = 1
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: screenWidth, bottom: 0, right: 0)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logDebug(indexPath)
        let row = indexPath.row
        if row == 1 {
            push(controller: VersionLogController())
        }else if row == 2 {
            checkUpgrade()
        }
    }

}

extension AboutUsController {

    func checkUpgrade() {
        SVProgressHUD.show()
        viewModel.requestUpgrade().subscribe(onNext: { result in
            SVProgressHUD.dismiss()
            
            if let localV = String.appVersion.replacingOccurrences(of: ".", with: "").double(),
                let serverV = result.verNo.replacingOccurrences(of: ".", with: "").double(),
                localV >= serverV {
                // 当前版本大于等于接口返回的版本，则弹框提示
                logInfo("v = \(serverV); locV: \(localV)")
                SVProgressHUD.showInfo(withStatus: "No updates".localized())
            } else {
                AppUpdateView.show(appUpdate: result, confirmClosure: { (view) in
                    if let url = URL.init(string: result.appUrl) {
                        UIApplication.shared.openURL(url)
                    }else {
                        SVProgressHUD.showError(withStatus: "Invalid URL address".localized())
                    }
                })
            }
            
        }, onError: { e in
            if let e = e as? ResultError {
                SVProgressHUD.showError(withStatus: e.msg ?? "")
            }
        }).disposed(by: rx.disposeBag)
    }
}
