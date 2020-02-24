//
//  AddEditController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView
import Schedule
import AVFoundation

class AddAssetController: BaseTableViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    let viewModel = AddAssetViewModel()
    
    let addTrigger = PublishSubject<AssetInfo>()
    let unbindTrigger = PublishSubject<AssetInfo>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        bindAddAssetViewModel()
    }

    override func configBaseInfo() {

        sortButton.setTitle("Popular Assets".localized(), for: .normal)
    }


    func bindAddAssetViewModel() {

        let input = AddAssetViewModel.Input(headerRefresh: headerRefreshTrigger,
                                            unbindTrigger: unbindTrigger,
                                            searchText: searchField.asDriver(),
                                            address: App.address)
        let output = viewModel.transform(input: input)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        output.results.asObservable().bind(to: tableView.rx.items(cellIdentifier: AddAssetCell.className,
                                                                  cellType: AddAssetCell.self))
        { (_, element, cell) in
            cell.item = element
            cell.balanceLabel.isHidden = true
            cell.didAddClosure = {
                if !cell.addButton.isSelected {
                    self.addAssetBindTapped(item: $0,button: cell.addButton)
                }
            }
            }.disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,tableView.rx.modelSelected(AssetInfo.self))
            .subscribe(onNext: { [weak self] (indexPath,asset) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                logDebug(asset.symbol)

            }).disposed(by: rx.disposeBag)

        tableView.headRefreshControl.beginRefreshing()
    }

    func addAssetBindTapped(item: AssetInfo,button: UIButton) {
        AudioServicesPlaySystemSound(1519) //1520
        viewModel.assetBind(address: App.address,
                            contractAddress: item.contractAddress,
                            symbol: item.symbol,
                            chainID: item.chainID)
            .subscribe(onNext: { result in
                if result.isOk {
                    button.isSelected = true
                    
                    var newItem = item
                    newItem.aIn = 1
                    self.addTrigger.onNext(newItem)
                    NotificationCenter.post(name: NotificationName.currencyDidChange)
                }else {
                    SVProgressHUD.showInfo(withStatus: result.msg ?? "")
                }
            }).disposed(by: rx.disposeBag)
    }

    func setupTableView() {

        tableView.removeFromSuperview()
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        tableView.rowHeight = 80
        tableView.register(nibWithCellClass: AddAssetCell.self)
        tableView.tableFooterView = UIView()
        tableView.footRefreshControl = nil
    }

    @IBAction func sortButtonTapped(_ sender: Any) {

    }

}

extension AddAssetController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
