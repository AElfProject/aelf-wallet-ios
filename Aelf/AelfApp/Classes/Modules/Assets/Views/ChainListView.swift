//
//  ChainListView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/8.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftMessages

private let cellHeight = 65

class ChainListView: MessageView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableHeight: NSLayoutConstraint!

    var closeAction: (() -> Void)?
    var confirmAction: ((ChainItem) -> Void)?

    class func show(items: [ChainItem],closeAction: (() -> Void)?, confirmClosure: ((ChainItem) -> Void)?) {

        let view = ChainListView.loadFromNib(named: ChainListView.className) as! ChainListView

        view.closeAction = closeAction
        view.confirmAction = confirmClosure
        view.setupTableView(items: items)

        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)
    }

    func setupTableView(items: [ChainItem]) {

        tableHeight.constant = CGFloat(items.count * cellHeight)
        tableView.rowHeight = cellHeight.cgFloat
        tableView.register(nibWithCellClass: ChainListCell.self)

        let dataSource = Observable.just(items)
        dataSource.bind(to: tableView.rx.items(cellIdentifier: ChainListCell.className, cellType: ChainListCell.self)) { idx,item,cell in
            cell.item = item
        }.disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(ChainItem.self).subscribe(onNext: { [weak self] item in
            SwiftMessages.hide(animated: true)
            self?.confirmAction?(item)
        }).disposed(by: rx.disposeBag)

    }

    @IBAction func closeTapped(_ sender: UIButton) {

        SwiftMessages.hide(animated: false)
        closeAction?()
    }
}
