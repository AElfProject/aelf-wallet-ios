//
//  EditAssetController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class EditAssetController: BaseTableViewController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    var sortType = BehaviorSubject<AssetSortType>(value: App.sortAsset)
    let viewModel = EditAssetViewModel()
    
    let addTrigger = PublishSubject<AssetInfo>()
    private let unbindTrigger = PublishSubject<AssetInfo>()
    let unbindToTrigger = PublishSubject<AssetInfo>() // 外部接收
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        bindEditViewModel()
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
        tableView.delegate = self
        
        tableView.setEditing(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let value = try? sortType.value() {
            sortButton.setTitle(value.localized, for: .normal)
            sortButton.setTitlePosition(position: .left, spacing: 5)
        }
    }
    
    func bindEditViewModel() {
        
        let input = EditAssetViewModel.Input(address: App.address,
                                             searchText: searchField.asDriver(),
                                             sortType: sortType,
                                             headerRefresh: headerRefresh(),
                                             unbindTrigger: unbindTrigger,
                                             addTrigger: addTrigger)
        
        let output = viewModel.transform(input: input)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        output.results.asObservable().bind(to: tableView.rx.items(cellIdentifier: AddAssetCell.className, cellType: AddAssetCell.self))
        { (_, element, cell) in
            cell.item = element
            cell.addButton.isHidden = true
        }.disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected,tableView.rx.modelSelected(AssetInfo.self))
            .subscribe(onNext: { [weak self] (indexPath,asset) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                logDebug(asset.symbol)
            }).disposed(by: rx.disposeBag)
        
        tableView.rx.modelDeleted(AssetInfo.self).subscribe(onNext: { [weak self] asset in
            self?.bindAsset(asset)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindAsset(_ asset: AssetInfo) {
        
        guard asset.isAllowUnBind == true else {
            SVProgressHUD.showInfo(withStatus: "Main chain coins are not allowed to unbind".localized())
            return
        }
        SVProgressHUD.show()
        logDebug("删除：\(asset.symbol)")
        self.viewModel.cancelBind(address: App.address,
                                  contractAddress: asset.contractAddress,
                                  symbol: asset.symbol,
                                  chainID: asset.chainID)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                
                if result.isOk {
                    SVProgressHUD.dismiss()
                    // self.headerRefreshTrigger.onNext(())
                    // self.reloadTrigger.onNext(())
                    self.unbindTrigger.onNext(asset)
                    asyncMainDelay {
                        self.unbindToTrigger.onNext(asset)
                    }
                }else if (result.status == 500) {
                    self.unbindTrigger.onNext(asset)  //
                    asyncMainDelay {
                        self.unbindToTrigger.onNext(asset)
                    }
                }else {
                    SVProgressHUD.showInfo(withStatus: result.msg ?? "error")
                }}, onError: { e in
                    if let r = e as? ResultError {
                        SVProgressHUD.showError(withStatus: r.msg)
                    }
            }).disposed(by: self.rx.disposeBag)
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        
        AssetSortView.show { type in
            self.sortType.onNext(type)
            self.sortButton.setTitle(type.localized, for: .normal)
            self.sortButton.setTitlePosition(position: .left, spacing: 5)
            App.sortAsset = type
        }
    }
    
    
    
}

extension EditAssetController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localized()
    }
}

extension EditAssetController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
