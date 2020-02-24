//
//  BackupController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/13.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

enum ExportWalletType {
    case none
    case hint
    case keyStore
    case privateKey
    case mnemonic
    case qrCode
}
class BackupController: BaseStaticTableController {

    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var nodeDesLabel: UILabel!
    @IBOutlet weak var noteTitleLabel: UILabel!
    @IBOutlet weak var backupTitleLabel: UILabel!
    @IBOutlet weak var backupDesLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailDesLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var backType:ExportWalletType = .none

    override func viewDidLoad() {
        super.viewDidLoad()

        addBackItem()
        makeUI()
    }

    func makeUI() {

        title = "Backup Notes".localized()

        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.reloadData()

        nextButton.cornerRadius = nextButton.height/2

        switch backType {
        case .keyStore:
            infoImageView.image = UIImage.init(named: "Keystore")
            noteTitleLabel.text = "Keystore".localized()
            nodeDesLabel.text = "Having your Keystore".localized()
            backupTitleLabel.text = "Keystore Backup".localized()
            backupDesLabel.text = "Please write down Keystore".localized()
            detailLabel.text = "Off-line Saving".localized()
            detailDesLabel.text = "Keep the Keystore".localized()
        case .privateKey:
            infoImageView.image = UIImage.init(named: "Private-Keys")

            noteTitleLabel.text = "Private Keys".localized()
            nodeDesLabel.text = "Having your private keys".localized()
            backupTitleLabel.text = "Private Key Backup".localized()
            backupDesLabel.text = "Please write down the private key".localized()
            detailLabel.text = "Off-line Saving".localized()
            detailDesLabel.text = "Keep the Private keys".localized()
        case .mnemonic:
            infoImageView.image = UIImage.init(named: "Mnemonic-Phrase")
            noteTitleLabel.text = "Mnemonic Phrase".localized()
            nodeDesLabel.text = "Having your mnemonic phrase".localized()
            backupTitleLabel.text = "Mnemonic Phrase Backup".localized()
            backupDesLabel.text = "Please write down the mnemonic words".localized()
            detailLabel.text = "Off-line Saving".localized()
            detailDesLabel.text = "Keep the mnemonic words".localized()
        default:
            break
        }
    }

    // MARK: - Table view data source
    @IBAction func nextAction(_ sender: Any) {

        SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
            if let pwd = pwd {
                asyncMainDelay(duration: 0.25, block: {
                    self.startExport(pwd: pwd)
                })
            }
        })
    }

    func startExport(pwd: String) {

        // password is true
        
        switch self.backType {
            case .mnemonic:
                if let mnemonic = AElfWallet.getMnemonic(pwd: pwd)  {
                    let backUpVC = UIStoryboard.loadController(WalletRemindController.self, storyType: .wallet)
                    backUpVC.mnemonic = mnemonic
                    backUpVC.walletType = .export
                    push(controller: backUpVC)
                }
               
                break
            case .keyStore:
               
                SVProgressHUD.show()
                AElfWallet.getKeyStore(pwd: pwd) { (result) in
                    SVProgressHUD.dismiss()
                    if result?.success == 1 {
                        let exportVC = UIStoryboard.loadController(AccountExportController.self, storyType: .setting)
                        exportVC.backType = .keyStore
                        exportVC.keyStore = result?.keyStore
                        self.push(controller: exportVC)
                    } else {
                        SVProgressHUD.showError(withStatus: "Failed".localized())
                    }
                }
                break
            case .privateKey:
                
                if let privateKey = AElfWallet.getPrivateKey(pwd: pwd) {
                    let exportVC = UIStoryboard.loadController(AccountExportController.self, storyType: .setting)
                    exportVC.backType = .privateKey
                    exportVC.privateKey = privateKey
                    push(controller: exportVC)
                }
            
            default:
                break
        }

    }
    
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
