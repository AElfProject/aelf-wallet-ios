//
//  WalletRemindController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

// 备份确认
class WalletRemindController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    var mnemonic: String? = nil
    var walletType: WalletPageType = .create

    override func viewDidLoad() {
        super.viewDidLoad()

      //  startButton.hero.id = "createID"

        if walletType == .export {
            addBackItem()
        } else {
            addEmptyBackItem()
            addLaterButton()
        }
    }

    override func languageChanged() {

    }

    func addLaterButton() {

        let btn = UIButton(type: .system)
        btn.setTitle("Later".localized(), for: .normal)
        btn.setTitleColor(.master, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.sizeToFit()
        btn.addTarget(self, action:#selector(laterTapped), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    func addLeftBackItem() {

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "arrow-left"), for: .normal)
        btn.frame = CGRect(x: 20, y: iPHONE_STATUS_HEIGHT, width: 40, height: 40)
        btn.addTarget(self, action:#selector(laterTapped), for: .touchUpInside)
        view.addSubview(btn)
    }

    @objc func laterTapped() {

        BaseTableBarController.resetRootController() // 重置 TabBar
        NotificationCenter.post(name: NotificationName.updateAssetData)
    }

    @IBAction func startButtonTapped(_ sender: UIButton) {

        performSegue(withIdentifier: WalletBackupController.className, sender: nil)
    }

}
extension WalletRemindController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destination as? WalletBackupController else { return }

        vc.mnemonic = self.mnemonic
        vc.walletType = self.walletType
    }
    
}
