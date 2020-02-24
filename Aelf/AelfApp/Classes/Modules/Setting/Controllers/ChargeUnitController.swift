//
//  ChargeUnitController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule

class ChargeUnitController: BaseTableViewController {

    var viewModel = ChargeUnitViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindUnitViewModel()
    }

    func makeUI() {
        tableView.rowHeight = 50
        tableView.bounces = false
        tableView.register(nibWithCellClass: ChargeUnitCell.self)
        tableView.separatorColor = .lightGray

    }

    override func languageChanged() {

        title = "Pricing Currency".localized()
    }
    
    func bindUnitViewModel() {

        let input = ChargeUnitViewModel.Input(headerRefresh: headerRefresh())
        let output = viewModel.transform(input: input)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        output.items
            .bind(to: tableView.rx.items(cellIdentifier: ChargeUnitCell.className, cellType: ChargeUnitCell.self)) { (_, item,cell) in
                cell.item = item
                cell.arrowImgView.isHidden = !(App.currency == item.id)
            }
            .disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(CurrencyItemModel.self).subscribe(onNext: { [weak self] item in
            SVProgressHUD.showSuccess(withStatus: "Set Successfully".localized())
            asyncMainDelay(duration: 0.8, block: {
                self?.pop()
            })

            if App.currency == item.id {
                return //
            }
            App.currency = item.id ?? "USD"
            NotificationCenter.post(name: NotificationName.currencyDidChange)

            }).disposed(by: rx.disposeBag)

    }

}
