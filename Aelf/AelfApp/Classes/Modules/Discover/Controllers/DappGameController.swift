//
//  DappGameController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

enum DappGameType: Int {
    case all = 0
    case games = 1
    case others = 4
}

class DappGameController: BaseTableViewController {
    
    var parentVC: UIViewController?
    var type = DappGameType.all
    
    fileprivate let viewModel = DappGameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(nibWithCellClass: DappGameCell.self)
        tableView.rowHeight = 95
        
        bindGameViewModel()
    }
    
    func bindGameViewModel() {
        
        let input = DappGameViewModel.Input(type: type,
                                            headerRefresh: headerRefresh(),
                                            footerRefresh: footerRefreshTrigger)
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        output.items.bind(to: tableView.rx.items(cellIdentifier: DappGameCell.className,
                                                 cellType: DappGameCell.self))
        { (_,item,cell) in
            cell.item = item
        }.disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(DiscoverDapp.self))
            .subscribe(onNext: { [weak self] index,item in
                self?.tableView.deselectRow(at: index, animated: true)
                self?.didSelectDapp(item: item)
                
            }).disposed(by: rx.disposeBag)
    }
    
    func didSelectDapp(item: DiscoverDapp) {
        
        let title = "Dapp visite info title".localizedFormat(item.name)
        let content = "Dapp visite info content".localizedFormat(item.name,item.name)
        
        DappConfirmView.show(title: title, content: content) { [weak self] v in
            self?.parentVC?.push(controller: DappWebController(item: DappItem(url: item.url, name: item.name)))
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        tableView.frame = self.view.bounds
        logDebug(tableView.frame)
    }
}


extension DappGameController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
