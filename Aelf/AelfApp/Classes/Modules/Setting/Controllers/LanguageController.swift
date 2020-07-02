//
//  LanguageController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule

struct LanguageItem {

    var displayName: String // 显示名称
    var localID: String     // iOS 本地化语言标识
    var serverID: String    // 对应服务端 ID
}

class LanguageController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 50
        tableView.register(nibWithCellClass: LanguageCell.self)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
        tableView.separatorColor = .lightGray

        bindDataSource()
    }

    func bindDataSource() {
//        let all = Localize.availableLanguages()
//        let allName = all.map{ Localize.displayNameForLanguage($0) }

        var items = [LanguageItem]()
        items.append(.init(displayName: "简体中文", localID: "zh-Hans", serverID: "zh-cn"))
        items.append(.init(displayName: "English", localID: "en", serverID: "en"))

        Observable.just(items).asDriver(onErrorJustReturn: []).drive(tableView.rx.items(cellIdentifier: LanguageCell.className,
                                                                              cellType: LanguageCell.self)) { (_, item,cell) in
                logDebug(item.displayName)
                cell.item = item
                cell.arrowImgView.isHidden = !(App.languageID == item.serverID)
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(LanguageItem.self).subscribe(onNext: { [weak self] item in

            App.languageID = item.serverID
            App.languageName = item.displayName
            logInfo("当前设置语言ID：\(String(describing: App.languageID)), 名称：\(App.languageName)")
            Localize.setCurrentLanguage(item.localID)
            SVProgressHUD.showSuccess(withStatus: "Set Successfully".localized())

            asyncMainDelay(duration: 0.5, block: {
                self?.pop()
            })

            }).disposed(by: rx.disposeBag)
    }

    override func languageChanged() {

        title = "Set Language".localized()
    }
}


