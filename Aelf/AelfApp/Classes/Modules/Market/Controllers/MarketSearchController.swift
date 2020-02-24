//
//  MarketSearchController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class MarketSearchController: BaseTableViewController {

    let viewModel = MarketSearchViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindViewModel()
        
    }

    func bindViewModel() {

        let input = MarketSearchViewModel.Input(searchText: searchView.searchField.asDriver(),
                                                headerRefresh: headerRefreshTrigger,
                                                footerRefresh: footerRefreshTrigger)
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "Empty Data".localized() }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: MarketSearchCell.className,
                                                 cellType: MarketSearchCell.self)) { idx,item,cell in
            cell.item = item
        }.disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(MarketCoinModel.self))
            .subscribe(onNext: { [weak self] (index,item) in
                self?.tableView.deselectRow(at: index, animated: true)
                self?.enterDetailVC(item: item)
            }).disposed(by: rx.disposeBag)

        emptyDataSetDescription.accept("Enter Token Name".localized())

        output.items.subscribe(onNext: { [weak self] items in
            self?.emptyDataSetDescription.accept("Empty Data".localized())
        }).disposed(by: rx.disposeBag)

        tableView.headRefreshControl.beginRefreshing()
    }

    func enterDetailVC(item: MarketCoinModel) {

        let detailVC = UIStoryboard.loadController(MarketDetailController.self, storyType: .market)
        detailVC.model = item
        push(controller: detailVC)
    }

    func makeUI() {

        navigationItem.title = "Market".localized()

        view.addSubview(searchView)
        view.addSubview(topView)

        searchView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        }

        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.height.equalTo(35)
        }

        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }

        tableView.register(nibWithCellClass: MarketSearchCell.self)
        tableView.height = 55
    }

    lazy var searchView: SearchBarView = {
        let searchView = SearchBarView.loadFromNib(named: SearchBarView.className) as! SearchBarView
        searchView.cancelButton.rx.tap.subscribe(onNext: { [weak self] _ in
            searchView.searchField.resignFirstResponder()
            self?.pop()
        }).disposed(by: rx.disposeBag)
        return searchView
    }()

    lazy var topView: MarketSearchTopView = {
        let view = MarketSearchTopView.loadFromNib(named: MarketSearchTopView.className) as! MarketSearchTopView
        return view
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.searchField.becomeFirstResponder()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
}
