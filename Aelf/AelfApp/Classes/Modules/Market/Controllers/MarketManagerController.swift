//
//  MarketManagerController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class MarketManagerController: BaseTableViewController {

    let viewModel = MarketManagerViewModel()

    let deleteTrigger = PublishSubject<MarketCoinModel>()
    let topTrigger = PublishSubject<MarketCoinModel>()
    let dragTrigger = PublishSubject<ItemMovedEvent>()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSubViews()
        bindViewModel()
    }

    override func languageChanged() {
        title = "Manage My Favourites".localized()
    }

    func configureSubViews() {

        tableView.register(nibWithCellClass: MarketManagerCell.self)
        tableView.tableHeaderView = topView
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }

    func bindViewModel() {

        let input = MarketManagerViewModel.Input(loadData: headerRefresh(),
                                                 delete: deleteTrigger,
                                                 top: topTrigger,
                                                 drag: dragTrigger)
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: MarketManagerCell.className,
                                                 cellType: MarketManagerCell.self)) { [weak self] index,item,cell in
                                                    cell.item = item
                                                    cell.topClosure = { mItem in
                                                        self?.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: 0, section: 0))
                                                        asyncMainDelay(duration: 0.3, block: {
                                                            self?.topTrigger.onNext(mItem)
                                                        })
                                                    }
        }.disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(MarketCoinModel.self))
            .subscribe(onNext: { [weak self] (idx,item) in
            self?.tableView.deselectRow(at: idx, animated: false)

        }).disposed(by: rx.disposeBag)

        // 移动操作
        tableView.rx.itemMoved.bind(to: dragTrigger).disposed(by: rx.disposeBag)

        // 删除操作
        tableView.rx.modelDeleted(MarketCoinModel.self).bind(to: deleteTrigger).disposed(by: rx.disposeBag)

        asyncMainDelay(duration: 0.5) {
            self.tableView.setEditing(true, animated: true)
        }
    }

    lazy var topView: MarketManagerTopView = {
        let view = MarketManagerTopView.loadFromNib(named: MarketManagerTopView.className) as! MarketManagerTopView
        view.size = CGSize(width: screenWidth, height: 30)
        return view
    }()

}


