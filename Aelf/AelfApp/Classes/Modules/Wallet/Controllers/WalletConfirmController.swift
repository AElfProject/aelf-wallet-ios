//
//  WalletConfirmController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

// 确认并校验备份助记词
class WalletConfirmController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topCollectionView: UICollectionView!

    @IBOutlet weak var bottomCollectionView: UICollectionView!

    @IBOutlet weak var nextButton: UIButton!

    var account:WalletAccount? = nil
    var mnemonic: String? = nil
    var walletType:WalletPageType = .create

    private var selecteSource = [String]()
    private var dataSource = [String]()
    fileprivate var originMnemonics = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.hero.id = "createID"
        loadWalletMnemonic()
    }
    
    override func languageChanged() {

        title = "Mnemonic Phrase Backup".localized()
    }

    func loadWalletMnemonic() {

        guard let mnemonic = self.mnemonic else {
            logWarn("助记词为空！")
            return
        }
        logInfo("助记词为：\(mnemonic)")

        originMnemonics = mnemonic.components(separatedBy: " ")
        dataSource = originMnemonics.shuffled() // 打乱顺序。
        bottomCollectionView.reloadData()
    }

    @IBAction func doneButtonTapped(_ sender: Any) {

        if !dataSource.isEmpty { // 验证成功
            logDebug("助记词尚未验证成功。")
            SVProgressHUD.showInfo(withStatus: "Please verify the mnemonic".localized())
            return
        }

        AElfWallet.isBackup = true

        switch self.walletType {
        case .create:
            SVProgressHUD.showInfo(withStatus: "Create successfully".localized())
            asyncMainDelay {
                BaseTableBarController.resetRootController() // 重置 TabBar
            }
        case .export:
            SVProgressHUD.showInfo(withStatus: "Create successfully".localized())
            asyncMainDelay {
                self.popToAccountController()
            }
        case .backUp:
            SVProgressHUD.showInfo(withStatus: "Backup successfully".localized())
            asyncMainDelay {
                BaseTableBarController.resetRootController() // 重置 TabBar
            }
        }
    }

    func popToAccountController()  {
        let controllers = self.navigationController?.viewControllers ?? []
        for vc in controllers {
            if vc is MyAccountController {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension WalletConfirmController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count:CGFloat = 3
        let w = (collectionView.width - count * 10.0 - 20)/count
        return CGSize(width: w, height: 26.0)
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if collectionView == topCollectionView {
            return selecteSource.count
        } else {
            return dataSource.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withClass: WalletConfirmCell.self, for: indexPath)
        if collectionView == topCollectionView {
            cell.titleLabel.text = selecteSource[indexPath.row]

        } else {
            cell.titleLabel.text = dataSource[indexPath.row]
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView == topCollectionView {
            // ...
        } else {
            //  打乱顺序后，取当前选中的 词与原始数组中第N个相比较，单词和顺序一致才匹配。
            if  dataSource[indexPath.row] != originMnemonics[selecteSource.count] {
                SVProgressHUD.showError(withStatus: "Wrong Mnenomic Words Order".localized())
                return
            }

            let word = dataSource.remove(at: indexPath.row)
            selecteSource.append(word)

            topCollectionView.reloadData()
            bottomCollectionView.reloadData()

            if selecteSource.count == 12 {
                self.doneButtonTapped(self.nextButton)
            }
        }
    }
}
