//
//  MarketFavouritesController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView


class MarketFavouritesController: BaseTableViewController {

    var parentVC: MarketContentController?

    let viewModel = MarketFavouritesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }

    func makeUI() {
        view.addSubview(topView)
        view.addSubview(footerView)

        tableView.register(nibWithCellClass: MarketCell.self)
        tableView.rowHeight = 55
        tableView.separatorStyle = .none
        tableView.footRefreshControl = nil

    }

    override func languageChanged() {
        footerView.button.setTitle("Manage My Favourites".localized(), for: .normal)
        topView.languageChanged()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let footerHeight: CGFloat = 50
        topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 35)
        tableView.frame = CGRect(x: 0, y: topView.bottom, width: screenWidth,
                                 height: view.height - topView.height - footerHeight)
        footerView.frame = CGRect(x: 0, y: tableView.bottom, width: screenWidth, height: footerHeight)

    }

    lazy var topView: FavouritesTopView = {
        let v = FavouritesTopView.loadFromNib(named: FavouritesTopView.className) as! FavouritesTopView
        return v
    }()

    lazy var footerView: FavouritesFooterView = {
        let footer = FavouritesFooterView.loadFromNib(named: FavouritesFooterView.className) as! FavouritesFooterView
        footer.button.addTarget(self, action: #selector(managerButtonTapped), for: .touchUpInside)
        footer.size = CGSize(width: screenWidth, height: 50)
        return footer
    }()

    @objc func managerButtonTapped() {

        parentVC?.push(controller: MarketManagerController())
    }

    func bindViewModel() {

        let input = MarketFavouritesViewModel.Input(headerRefresh: headerRefreshTrigger, footerRefresh: footerRefreshTrigger)
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "No Favourites".localized() }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: MarketCell.className,
                                                 cellType: MarketCell.self)) { idx,item,cell in
          cell.item = item
        }.disposed(by: rx.disposeBag)
        output.items.subscribe(onNext: { items in
            self.footerView.isHidden = items.isEmpty
        }).disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(MarketCoinModel.self))
            .subscribe(onNext: { [weak self] (index,item) in
                self?.tableView.deselectRow(at: index, animated: true)
                self?.enterDetailVC(item: item)
        }).disposed(by: rx.disposeBag)

        emptyDataSetImage = UIImage(named: "favour_emptystate")
        emptyDataSetDescription.accept("No Favourites".localized())

        NotificationCenter.default.rx.notification(NotificationName.currencyDidChange).subscribe(onNext: { [weak self] notify in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)

        tableView.headRefreshControl.beginRefreshing()

    }

    func enterDetailVC(item: MarketCoinModel) {
        let detailVC = UIStoryboard.loadController(MarketDetailController.self, storyType: .market)
        detailVC.model = item
        parentVC?.push(controller: detailVC)
    }
 
}



extension MarketFavouritesController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
