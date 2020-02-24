//
//  AssetShowTypeController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule

enum AssetDisplayMode: Int {
    case token
    case chain

    var stringValue: String {
        if App.languageID == "en" {
            switch self {
            case .chain: return "By Chain"
            case .token: return "By Token"
            }
        } else {
            switch self {
            case .chain: return "按链"
            case .token: return "按资产"
            }
        }
    }
    
}

class AssetShowTypeController: BaseTableViewController {

    var assetItems : Observable<[AssetDisplayMode]>?

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindViewModel()
    }

    func makeUI() {

        title = "Asset Display".localized()

        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.bounces = false
        tableView.separatorColor = .lightGray
    }

    override func languageChanged() {
        tableView.reloadData()
    }

    func bindViewModel() {

        tableView.register(nibWithCellClass: AssetShowTypeCell.self)

        assetItems = Observable.just([AssetDisplayMode.chain,AssetDisplayMode.token])

        assetItems?
            .bind(to: tableView.rx.items(cellIdentifier: AssetShowTypeCell.className,
                                         cellType: AssetShowTypeCell.self)) { (_, item, cell) in
                cell.item = item
                cell.arrowImgView.isHidden = !(App.assetMode == item)
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(AssetDisplayMode.self).subscribe(onNext: { [weak self] item in
            if item == .token {
                App.chainID = Define.defaultChainID // 切换资产展示方式，默认显示 AELF 链
            }
            App.assetMode = item
            NotificationCenter.post(name: NotificationName.assetDisplayModeChange, object: item)
            SVProgressHUD.showSuccess(withStatus: "Set Successfully".localized())
            asyncMainDelay(duration: 0.8, block: {
                self?.pop()
            })
        }).disposed(by: rx.disposeBag)
    }

}
