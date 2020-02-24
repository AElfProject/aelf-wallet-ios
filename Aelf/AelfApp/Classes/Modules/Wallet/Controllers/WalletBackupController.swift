//
//  WalletBackupController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule

enum WalletPageType {

    case create
    case export
    case backUp
}
// 备份钱包
class WalletBackupController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!

    var mnemonic: String? = nil
    var walletType:WalletPageType = .create

    fileprivate var dataSource = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
    }

    func makeUI() {

        nextButton.hero.id = "createID"

        asyncMainDelay(duration: 0.5) {
            WalletWarnView.show()
        }

        dataSource = mnemonic?.components(separatedBy: " ") ?? []
        collectionView.reloadData()
    }

    override func languageChanged() {

        title = "Phrase Backup".localized()
    }

    // 下一步验证
    @IBAction func nextButtonTapped(_ sender: Any) {

        performSegue(withIdentifier: WalletConfirmController.className, sender: nil)
    }
}

extension WalletBackupController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count:CGFloat = 3
        let w = (collectionView.width - count * 10.0 - 20)/count //
        return CGSize(width: w, height: 26.0)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: WalletConfirmCell.self, for: indexPath)
        cell.titleLabel.text = dataSource[indexPath.row]

        return cell
    }

}

extension WalletBackupController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        logInfo("跳转处理。")
        if let vc = segue.destination as? WalletConfirmController {
            vc.mnemonic = self.mnemonic
            vc.walletType = self.walletType
        } else {
        }
    }
}
