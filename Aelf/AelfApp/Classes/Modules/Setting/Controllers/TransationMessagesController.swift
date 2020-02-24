//
//  TransationMessagesController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class TransationMessagesController: BaseTableViewController {

    var parentVC: NotificationsController?

    let viewModel = TransationViewModel()
    let readTrigger = PublishSubject<String>()
    let removeAllItems = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(nibWithCellClass: TransationCell.self)
        tableView.rowHeight = 100
        tableView.separatorColor = .lightGray

        bindMessagesViewModel()
    }

    func bindMessagesViewModel() {

        guard let parentVC = parentVC else { return }
        let input = TransationViewModel.Input(address: App.address,
                                              headerRefresh: headerRefresh(),
                                              footerRefresh: footerRefreshTrigger,
                                              readMessage: readTrigger.asObservable(),
                                              removeAll:removeAllItems)
        let output = viewModel.transform(input: input)

        output.clearResult.mapToVoid().bind(to: parentVC.fetchAllUnReadTrigger).disposed(by: rx.disposeBag)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        emptyDataSetDescription.accept("No trading info".localized())

        output.items.bind(to: tableView.rx.items(cellIdentifier: TransationCell.className,
                                                 cellType: TransationCell.self)) {(_, element, cell) in
                                                    cell.item = element
            }
            .disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.modelSelected(AssetHistory.self),tableView.rx.itemSelected)
            .subscribe(onNext: { [weak self] (item,idx) in
                let cell = self?.tableView.cellForRow(at: idx) as? TransationCell
                asyncMainDelay {
                    cell?.didRead()
                }
                self?.pushFromParent(model: item)
                self?.readTrigger.onNext(item.id)
            }).disposed(by: rx.disposeBag)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = "Transaction Record".localized()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func pushFromParent(model:AssetHistory) {
         let recordVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
        recordVC.item = model
        parentVC?.navigationController?.pushViewController(recordVC, animated: true)
    }

}

extension TransationMessagesController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
