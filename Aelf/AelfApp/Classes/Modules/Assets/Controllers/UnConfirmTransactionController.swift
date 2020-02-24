//
//  UnConfirmTransactionController.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/1.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class UnConfirmTransactionController: BaseTableViewController {
    
    enum Const {
        static let closeCellHeight: CGFloat = 120 // 这里2条修改了， xib 上也得改。
        static let openCellHeight: CGFloat = 240
    }
    
    var cellHeights: [CGFloat] = []
    
    let viewModel = UnConfirmTransactionViewModel()
    let fetchChainsTripper = PublishSubject<Void>()
    let chains = BehaviorRelay<[ChainItem]>(value: [])
    
    var items = [UnConfirmTransactionItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        title = "To be confirmed transfer".localized()
        tableView.register(nibWithCellClass: UnConfirmTransactionCell.self)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.groupTableViewBackground
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.footRefreshControl = nil
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
 
    }
    
    func bindViewModel() {
        
        let fetchChains = Observable.of(Observable.just(()), fetchChainsTripper).merge()
        let input = UnConfirmTransactionViewModel.Input(address: App.address,
                                                        headerRefresh: headerRefresh(),fetchChains: fetchChains)
        let output = viewModel.transform(input: input)
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        emptyDataSetDescription.accept("No pending transactions".localized())
        emptyDataSetImage = UIImage(named: "success")

        output.chains.subscribe(onNext: { [weak self] (items) in
            guard let self = self else { return }
            self.chains <= items
            SVProgressHUD.dismiss()
            
        }).disposed(by: rx.disposeBag)
        
        output.items.subscribe(onNext: { [weak self] items in
            guard let self = self else { return }
            self.items = items
            self.cellHeights = Array(repeating: Const.closeCellHeight, count: items.count)
            self.tableView.reloadData()
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    
    /// 检查在 ToChain 链上，我的 fee 是否足够。
    /// - Parameters:
    ///   - contractAddress: Tochain 链的合约地址
    ///   - toChainID: ToChain 链 ID
    func checkToChainFee(item: ChainItem, confirmClosure:(() -> ())?) {
        SVProgressHUD.show()
        self.viewModel.requestMyBalance(address: App.address,
                                        contractAddress: item.contractAddress,
                                        symbol: item.symbol,
                                        chainID: item.name).subscribe(onNext: { balanceItem in
                                            
                                            let b = balanceItem.balance?.balance
                                            let f = balanceItem.fee?.first?.fee
                                            if let balance = b?.double(),let fee = f?.double() { // "33.00" 转 int 会失败，需先转为 double,再转int。
                                                if balance >= fee {
                                                    SVProgressHUD.dismiss()
                                                    confirmClosure?()
                                                } else {
                                                    SVProgressHUD.showInfo(withStatus: "%@ Balances for transfer are insufficient".localizedFormat(item.name))
                                                }
                                            }else {
                                                SVProgressHUD.showInfo(withStatus: "Parsing failed".localized())
                                            }
                                            
                                        }, onError: { e in
                                            SVProgressHUD.showInfo(withStatus: e.localizedDescription)
                                        }).disposed(by: rx.disposeBag)
    }
    
    
    
    func showPasswordAlertView(item: UnConfirmTransactionItem) {
        
        SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
            if let pwd = pwd {
                self.fetchToTxID(pwd: pwd,item: item)
            }
        })
    }
    
    func fetchToTxID(pwd: String, item: UnConfirmTransactionItem) {
        
        SVProgressHUD.show(withStatus: nil)
        SVProgressHUD.setDefaultMaskType(.none)
        
        var tempFromItem: ChainItem?
        var tempToItem: ChainItem?
        
        var mainID = "9992731" // 默认 AELF 的 id
        chains.value.forEach({
            if $0.name.lowercased() == item.fromChain.lowercased() {
                tempFromItem = $0
            }
            
            if $0.name.lowercased() == item.toChain.lowercased() {
                tempToItem = $0
            }
            
            if $0.name.lowercased() == "AELF".lowercased() {
                mainID = $0.issueID
            }
        })
        
        guard let fromItem = tempFromItem,let toItem = tempToItem else {
            SVProgressHUD.showInfo(withStatus: "No node address found for %@ or %@".localizedFormat(item.fromChain,item.toChain))
            return }
        
        AElfWallet.transferCrossReceive(pwd: pwd,
                                        fromNode: fromItem.node.removeSlash(),
                                        toNode: toItem.node.removeSlash(),
                                        mainChainID: mainID,
                                        issueChainID: fromItem.issueID,
                                        fromTokenContractAddress: fromItem.contractAddress,
                                        fromCrossChainContractAddress: fromItem.crossChainContractAddress,
                                        toTokenContractAddress: toItem.contractAddress,
                                        toCrossChainContractAddress: toItem.crossChainContractAddress,
                                        fromChainName: fromItem.name,
                                        toChainName: toItem.name,
                                        txID: item.txid)
        { [weak self] result in
            guard let self = self else { return }
            guard let res = result else {
                SVProgressHUD.showError(withStatus: "Parsing failed".localized())
                return
            }
            logInfo("跨链返回结果：\(res)")
            if res.success == 1 {
                self.linkTxID(fromTxID: item.txid, toTxID: res.txId,fromChainID: fromItem.name)
            }else {
                SVProgressHUD.showError(withStatus: res.err)
            }
        }
        
    }
    
    func linkTxID(fromTxID: String,toTxID: String,fromChainID: String) {
        
        viewModel.requestLinkTransaction(fromTxID: fromTxID, toTxID: toTxID)
            .subscribe(onNext: { [weak self] result in
                if result.isOk {
//                    SVProgressHUD.showInfo(withStatus: "Confirm success".localized())
                    self?.enterDetailController(txID: fromTxID, fromChainID: fromChainID)
                    self?.headerRefreshTrigger.onNext(())
                } else {
                    if let msg = result.msg {
                        SVProgressHUD.showInfo(withStatus: msg)
                    }
                }
                logInfo(result)
                }, onError: { e in
                    SVProgressHUD.showError(withStatus: e.localizedDescription)
                    logDebug(e)
            }).disposed(by: rx.disposeBag)
    }
    
}

// MARK: - TableView

extension UnConfirmTransactionController: UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView()
         headerView.backgroundColor = UIColor.clear
         return headerView
     }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as UnConfirmTransactionCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.section] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

        cell.item = items[indexPath.section]
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UnConfirmTransactionCell.self)
//        let durations: [TimeInterval] = [0.16, 0.1, 0.1,0.15]
        let durations: [TimeInterval] = [0,0, 0,0]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        cell.seeMoreClosure = { [weak self] item in
            guard let self = self,let item = item else { return }
            self.enterWebController(item: item)
        }
        
        cell.confirmClosure = { [weak self] item in
            guard let self = self,let item = item else { return }
            self.confirmTransfer(item: item)
        }
        
        return cell
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! UnConfirmTransactionCell

        if cell.isAnimating() {
            return
        }

        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.section] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.section] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.section] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            // fix https://github.com/Ramotion/folding-cell/issues/169
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
}

 

extension UnConfirmTransactionController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appBlack]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
}

extension UnConfirmTransactionController {
    
    func enterDetailController(txID: String, fromChainID: String) {
        
        let recordVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
        recordVC.txId = txID
        recordVC.fromChainID = fromChainID
        push(controller: recordVC)
    }
    
    func enterWebController(item: UnConfirmTransactionItem) {
        
        // https://explorer-test.aelf.io/tx/9f74c44dde052cd456216b00fd387d4e66d65e0120654055b09ec351604e69c9
        guard let chain = ChainItem.getItem(chainID: item.fromChain) else { return }
        let url = chain.explorer.removeSlash() + "/tx/\(item.txid)"
        logDebug("拼接的 TX 浏览器地址: \(url)")
        let webVC = WebViewController(urlStr: url)
        push(controller: webVC)
    }
    
    func getChainItem(chainID: String) -> ChainItem? {
        var item: ChainItem?
        self.chains.value.forEach({
            if $0.name.lowercased() == chainID.lowercased() {
                item = $0
            }
        })
        return item
    }
    
    
    func confirmTransfer(item: UnConfirmTransactionItem) {
        
        logDebug("TxID: \(item.txid)")
        
        if self.chains.value.count > 0 {
            if let chainItem = self.getChainItem(chainID: item.toChain) {
                self.checkToChainFee(item: chainItem) {
                    self.showPasswordAlertView(item: item)
                }
            }else {
                SVProgressHUD.showInfo(withStatus: "Chain ID: %@ not supported".localizedFormat(item.toChain))
            }
            
        }else { // 网络问题，没有取到 chains 数据。
            SVProgressHUD.show()
            self.fetchChainsTripper.onNext(()) //
        }
    }
    
}
