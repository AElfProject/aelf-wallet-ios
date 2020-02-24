//
//  AssetHistoryController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class AssetHistoryController: BaseTableViewController {

    var item: AssetDetailItem?
    var type = TransactionType.all
    var parentVC: UIViewController?

    fileprivate let viewModel = AssetHistoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindHistoryViewModel()
    }

    func makeUI() {
        tableView.register(nibWithCellClass: AssetHistoryCell.self)
        tableView.rowHeight = 90

    }

    func bindHistoryViewModel() {

        guard let item = item else { return }
        let input = AssetHistoryViewModel.Input(address: App.address,
                                                contractAddress: item.contractAddress,
                                                symbol: item.symbol,
                                                chainID: item.chainID,
                                                transType: type,
                                                headerRefresh: headerRefreshTrigger,
                                                footerRefresh: footerRefreshTrigger)
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        emptyDataSetButtonTap.subscribe(onNext: { [weak self] () in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)

        // 如果2个数组 txID 拼起来的字符串 完全一致，则过滤
        output.items
            .distinctUntilChanged({ $0.map({ $0.txid }) == $1.map({ $0.txid }) })
            .bind(to: tableView.rx.items(cellIdentifier: AssetHistoryCell.className,
                                                 cellType: AssetHistoryCell.self))
        { (_,model,cell) in
            cell.updateSubviews(item: model, price: item.price)
            }.disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(AssetHistory.self))
            .subscribe(onNext: { [weak self] index,item in
                guard let self = self else { return }
                self.tableView.deselectRow(at: index, animated: true)
                let recordVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
                recordVC.item = item
                self.parentVC?.push(controller: recordVC)
            }).disposed(by: rx.disposeBag)
        
        tableView.headRefreshControl.beginRefreshing()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

}

extension AssetHistoryController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
