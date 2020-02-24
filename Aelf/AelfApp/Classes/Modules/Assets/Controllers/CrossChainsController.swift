//
//  CrossChainsController.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/25.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

enum CrossChainType {
    case push
    case present
}

class CrossChainsController: BaseTableViewController {

    let type: CrossChainType
    let symbol: String?
    let closure: ((AssetItem) -> ())?
    init(type: CrossChainType,symbol: String? = nil, closure: ((AssetItem) -> ())?) {
        self.type = type
        self.symbol = symbol
        self.closure = closure
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let viewModel = CrossChainsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
    }

    func setupUI() {

        view.addSubview(headerView)

        if type == .present {
            navigationItem.titleView = titleView
            addEmptyBackItem()
        } else {
            navigationItem.title = "Select Chain".localized()

        }

        headerView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(headerView.contentHeight())
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }

        tableView.register(nibWithCellClass: ChooseChainCell.self)
        tableView.rowHeight = 90
        tableView.footRefreshControl = nil
    }
    

    func bindViewModel() {

        let input = CrossChainsViewModel.Input(search: headerView.searchField.asDriver(), symbol: self.symbol, headerRefresh: headerRefreshTrigger)
        let output = viewModel.transform(input: input)

        output.items.bind(to: tableView.rx.items(cellIdentifier: ChooseChainCell.className, cellType: ChooseChainCell.self)) { index,item,cell in
            cell.item = item
        }.disposed(by: rx.disposeBag)

        Observable.combineLatest(output.totalAmount,output.totalPrice).subscribe(onNext: { [weak self] (total,price) in
            self?.headerView.updateSubViews(totalAmount: total, totalPrice: price)
        }).disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(AssetItem.self).subscribe(onNext: { [weak self] item in
            self?.enterDetailController(item)
        }).disposed(by: rx.disposeBag)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map({ $0.msg ?? "" }).bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        tableView.headRefreshControl.beginRefreshing()

    }

    func enterDetailController(_ item: AssetItem) {

        if type == .present {
            closure?(item)
            back()
        }else {
            App.chainID = item.chainID
            let vc = UIStoryboard.loadController(AssetDetailController.self, storyType: .assets)
            vc.item = AssetDetailItem(symbol: item.symbol,
                                      chainID: item.chainID,
                                      contractAddress: item.contractAddress,
                                      price: item.rate?.price.double() ?? 0,
                                      logo: item.logo)
            push(controller: vc)
        }

    }

    lazy var headerView: CrossChainsHeaderView = {
        let header = CrossChainsHeaderView.instance(type: self.type, symbol: self.symbol)
        return header
    }()

    lazy var titleView: ChainTitleView = {
        let view = ChainTitleView()
        view.masterStyle()
        
        view.tapClosure = { [weak self] in
            self?.back()
        }
        return view
    }()

    func back() {
        view.endEditing(true)
        if type == .present {
            dismiss(animated: true, completion: nil)
        } else {
            pop()
        }
    }
}


extension CrossChainsController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appBlack]
    }
}


