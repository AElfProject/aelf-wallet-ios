//
//  ExportQRCodeController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/16.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import Photos

class ExportQRCodeController: BaseStaticTableController {
    
    @IBOutlet weak var avactorImageView: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var nodeDesLabel: UILabel!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var backupTitleLabel: UILabel!
    @IBOutlet weak var backupDesLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var pwd: String? = nil
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        addBackItem()

        makeUI()
        
        loadData()
        
        updateUI(info: App.userInfo)
    }

    func makeUI() {

        title = "Backup Notes".localized()

        activityView.hidesWhenStopped = true
        nextButton.isUserInteractionEnabled = false
        nextButton.alpha = 0.5
        nextButton.cornerRadius = nextButton.height/2

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }

    func updateUI(info: IdentityInfo?) {
        guard let info = info else { return }
        
        if let url = URL(string: info.img ?? "") {
            self.avactorImageView.setImage(with: url, placeholder: UIImage(named: "aelf_icon"))
        }else {
            self.avactorImageView.image = UIImage(named: "aelf_icon")
        }
    }
    func loadData() {
        self.activityView.startAnimating()
        AElfWallet.getKeyStore(pwd: pwd ?? "") { (result) in
             self.activityView.stopAnimating()
             self.nextButton.alpha = 1
             self.nextButton.isUserInteractionEnabled = true
            if result?.success == 1 {
                self.qrImageView.image = QRCodeUtil.getQRCode(origin: result?.keyStore ?? "")
            } else {
                SVProgressHUD.showError(withStatus: "Failed".localized())
            }
        }
       
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        addEmptyBackItem() // 隐藏返回
        sender.isHidden = true
        guard let view = navigationController?.view, let image = view.screenshot else {
            logDebug("获取截图失败！")
            addBackItem()
            sender.isHidden = false
            return
        }
        addBackItem()
        sender.isHidden = false

        saveImage(image: image)
    }
    
    func saveImage(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (isSuccess, error) in
            if isSuccess {
                SVProgressHUD.showSuccess(withStatus: "Saved".localized())
            } else {
                SVProgressHUD.showInfo(withStatus: "Failed".localized())
            }
        }
    }

}


extension ExportQRCodeController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
