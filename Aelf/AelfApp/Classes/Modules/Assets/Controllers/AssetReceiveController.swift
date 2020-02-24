//
//  AssetReceiveController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AssetReceiveController: BaseController {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var qrImgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var noticeLabel: UILabel!

    var item: AssetDetailItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        addNavigationItem()
    }

    func makeUI() {

        guard let item = item else { return }
        let address = App.address.elfAddress(item.chainID)
        qrImgView.image = QRCodeUtil.getQRCode(origin: address)
        addressLabel.text = address

        if let str = item.logo, let url = URL(string: str) {
            iconImgView.setImage(with: url, placeholder: UIImage(named: "logo-mark"))
        }
    }

    func addNavigationItem() {

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
    }

    lazy var shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Share".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(.master, for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action:#selector(sharedTapped), for: .touchUpInside)
        return btn
    }()

    @objc func sharedTapped() {

        addEmptyBackItem() // 隐藏返回
        shareButton.isHidden = true
        guard let view = navigationController?.view, let image = view.screenshot else {
            logDebug("获取截图失败！")
            return
        }
        addBackItem()
        shareButton.isHidden = false

        let vc = VisualActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }

 
    override func languageChanged() {

        title = (item?.chainID ?? "") + " " + "%@ Receive".localizedFormat("ELF")
    }

    // MARK: Copy Event
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = App.address.elfAddress((item?.chainID ?? ""))
        SVProgressHUD.showSuccess(withStatus: "Copied".localized())
    }
}
