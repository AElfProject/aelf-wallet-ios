//
//  AssetTransferController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import Schedule
import LTMorphingLabel

class AssetTransferController: BaseController {
    
    @IBOutlet weak var titleLabel: LTMorphingLabel!
    
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var notesField: UITextField!
    @IBOutlet weak var noteHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var howToUseButton: UIButton!
    
    let viewModel = AssetTransferViewModel()
    
    let fetchChainsTripper = PublishSubject<Void>()
    let fetchAllChainsTripper = PublishSubject<Void>()

    let chains = BehaviorRelay<[ChainItem]>(value: [])
    let allChains = BehaviorRelay<[AssetItem]>(value: [])

    var item: AssetDetailItem?
    var balance: Double = 0
    var fee: Double = 0
    var task: Task?
    var mainID: String = ""
    var issueID: String = ""

    var fromItem: ChainItem?
    var toItem: ChainItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationItem()
        bindTransferViewModel()
        #if DEBUG
        addressField.text = "QDDLWzuvSYhYR18KeF7AHZNpJdtrTCh2G8MprXF4rGx8x9Fpm" // kite magnet
        #endif
    }
    
    override func languageChanged() {
        
        howToUseButton.setTitle("Help_cross_transaction".localized(), for: .normal)
        howToUseButton.setTitlePosition(position: .right, spacing: 15)
        
        guard let item = item else { return }
        title = (item.chainID) + "-" + "%@ Transfer".localizedFormat(item.symbol)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountField.becomeFirstResponder()
    }
    
    func bindTransferViewModel() {
        
        // 限制输入
        amountField.rx.text.orEmpty.map({ $0.setFloat() }).bind(to: amountField.rx.text).disposed(by: rx.disposeBag)
        
        guard let item = item else { return }
        
        let input = AssetTransferViewModel.Input(symbol: item.symbol,
                                                 address: App.address,
                                                 contractAddress: item.contractAddress,
                                                 chainID: item.chainID,
                                                 refreshData: headerRefresh(),
                                                 fetchChains: Observable.of(Observable.just(()), fetchChainsTripper).merge(),
                                              fetchAllChains:Observable.of(Observable.just(()), fetchAllChainsTripper).merge())
        let output = viewModel.transform(input: input)
        
        output.balance.subscribe(onNext: { [weak self] balance in
            guard let self = self else { return }
            self.titleLabel.attributedText = balance.balance?.headerTitle(symbolName: item.symbol,
                                                                          chainID: item.chainID)
            self.activityView.stopAnimating()
            
            if let b = balance.balance?.balance, let value = b.double() { // "33.00" 转 int 会失败，需先转为 double,再转int。
                self.balance = value
            }
            if let f = balance.fee?.first?.fee, let value = f.double() {
                print(value)
                self.fee = value
            }
            
        }).disposed(by: rx.disposeBag)
        
        output.chains.subscribe(onNext: { [weak self] (items) in
            guard let self = self else { return }
            self.chains <= items
           // print(items)
            
            items.forEach({
                print($0)
                if $0.name.lowercased() == self.item?.chainID.lowercased() {
                    self.fromItem = $0 //
                    self.toItem = $0 // 默认与发送方一致。
                }
            })
        }).disposed(by: rx.disposeBag)
        output.allChains.subscribe(onNext: { [weak self] (items) in
                guard let self = self else { return }
                self.allChains <= items
                items.forEach({
                    print($0)
                    if $0.chainID.lowercased() == self.item?.chainID.lowercased() {
                        self.issueID = $0.issueChainId
                        self.mainID = $0.chainID
                    }
                })
            }).disposed(by: rx.disposeBag)
        viewModel.parseError.subscribe(onNext: { e in
            logDebug(e)
            if let msg = e.msg {
                SVProgressHUD.showInfo(withStatus: msg)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func updateNoteLabelStatus(isShow: Bool, animated: Bool = true) {
        noteHeight.constant = isShow ? 40:0
        UIView.animate(withDuration: animated ? 0.25:0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addNavigationItem() {
        
        let btn = UIButton(type: .system)
        btn.size = CGSize(width: 40, height: 40)
        btn.setImage(UIImage(named: "scan")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action:#selector(scanTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
    }
    
    @objc func scanTapped() {
        
        guard UIApplication.isAllowCamera() else {
            SVProgressHUD.showInfo(withStatus: "Scanning QR code requires camera permissions".localized())
            return
        }
        let qr = QRScannerViewController()
        qr.scanType = .addressScan
        self.push(controller: qr)
        qr.scanResult = { result, error in
            if let address = result {
                logInfo("扫描结果：\(address)")
                self.addressField.text = address
            }else {
                logDebug(error)
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
            qr.pop()
        }
    }
    
    @IBAction func howToUseTapped(_ sender: UIButton) {
        
        SecurityWarnView.show(title: "Help_cross_transaction".localized(),
                              body: "Help_cross_transaction_info".localized(),
                              interactive: true,
                              confirmTitle: "Confirm".localized()) {
            
        }
    }
    
    @IBAction func addressButtonTapped(_ sender: UIButton) {
        let addressBookVC = UIStoryboard.loadStoryClass(className: AddressBookViewController.className,
                                                        storyType: .setting) as! AddressBookViewController
        addressBookVC.parentType = .transfer
        addressBookVC.callBackBlock { [weak self](address) in
            if let _ = address.chainID() {
                self?.addressField.text = address
            }else {
                self?.addressField.text = address.elfAddress()
            }
        }
        push(controller: addressBookVC)
    }
    
    // MARK: 下一步
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        let amount = self.amountField.text?.double() ?? 0
        let toAddress = self.addressField.text ?? ""
        
        if !AElfWallet.isAELFAddress(toAddress) {
            SVProgressHUD.showInfo(withStatus: "Invalid Address".localized())
            return
        }
        guard amount > 0 else {
            SVProgressHUD.showInfo(withStatus: "The amount is too small to transfe".localized())
            return
        }
        guard balance > 0 && balance > self.fee + amount else {
            SVProgressHUD.showInfo(withStatus: "%@ chain balance is not enough".localizedFormat(item?.chainID ?? ""))

           // SVProgressHUD.showInfo(withStatus: "Beyond amount".localized())
            return
        }
        
        checkTransferType()
    }
    
    func showPasswordAlertView(isCrossChain: Bool = false) {
        
        self.view.endEditing(true)
        
        if App.address.elfAddress(item?.chainID ?? "").lowercased() == self.addressField.text?.lowercased() {
            SVProgressHUD.showInfo(withStatus: "Do not transfer to your current address".localized())
            return
        }
        
        SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
            self.goTransferHandler(pwd: pwd, isCrossChain: isCrossChain)
        })
    }
    
    func goTransferHandler(pwd: String?,isCrossChain: Bool) {
        
        if let pwd = pwd {
            if isCrossChain { // 是跨链转账
                self.startCrossTransaction(pwd: pwd)
            } else { // 同链不允许给自己转。
                self.startAElfTransaction(pwd: pwd)
            }
        }
    }
    
    func checkTransferType() {
        
        let toAddress = self.addressField.text ?? ""
        if let toChainID = toAddress.chainID() {
            if let fromChainID = item?.chainID, toChainID.lowercased() != fromChainID.lowercased() { // toChainID 存在且不相等，提示跨链交易

                let value = isSupportCrossTransfer(chainID: toChainID)
                if !value.0 {
                    SVProgressHUD.showInfo(withStatus: "Chain ID: %@ not supported".localizedFormat(toChainID))
                    return
                }
                
                // 上面已经判断了是否支持 toChainID，如果走到这里，则能取到 item
                guard let item = value.1 else { return }
                self.toItem = item
              //  self.checkToChainFee(item: item) {
                    // 检测为跨链，提示跨链弹框
                    TransferDetectedView.show(fromChain: fromChainID, toChain: toChainID) {
                        self.showPasswordAlertView(isCrossChain: true)
                    }
              //  }
                
                
            } else { // 存在，相等 即为同链
                self.showPasswordAlertView()
            }
        } else { // 用户地址不包含 chainID，则弹出选择链界面
            if chains.value.count > 0 {
                self.showChainsList(items: chains.value)
            }else { // 网络问题，没有取到 chains 数据。
                SVProgressHUD.show()
                fetchChainsTripper.onNext(()) //
            }
        }
        
    }
    
    //MARK: 跨链转账
    func startCrossTransaction(pwd: String) {
        
        SVProgressHUD.show()
        task = Plan.after(60.seconds).do { [weak self] in
            self?.showNetworkError()
        } // 30秒未返回结果的话，提示。
        
        let toAddress = self.addressField.text ?? ""
        let amount = self.amountField.text?.double() ?? 0
        let memo = self.notesField.text ?? ""
        
        guard let fromItem = fromItem,let toItem = toItem else {
            logInfo("缺少必要参数。")
            return }
        
        // js 提供的转账规则。
        
        let fromNode = fromItem.node.removeSlash()
        let toNode = toItem.node.removeSlash()
        
        AElfWallet.transferCross(pwd: pwd,
                                 fromNode: fromNode,
                                 toNode: toNode,
                                 toAddress: toAddress.removeChainID(),
                                 mainChainID: self.mainID,
                                 issueChainID: self.issueID,
                                 fromTokenContractAddress: fromItem.contractAddress,
                                 fromCrossChainContractAddress: fromItem.crossChainContractAddress,
                                 toTokenContractAddress: toItem.contractAddress,
                                 toCrossChainContractAddress: toItem.crossChainContractAddress,
                                 fromChainName: fromItem.name,
                                 toChainName: toItem.name,
                                 symbol: currentSymbol(),
                                 memo: memo,//Define.decimalsValue
            amount: Int(amount * pow(Double(10), Double(item!.decimals)!)))
        { [weak self] result in
            guard let self = self else { return }
            self.task?.cancel()
            guard let result = result else {
                return
            }
            if result.success == 0 {
                SVProgressHUD.showInfo(withStatus: result.err)
                return
            }
            
            logInfo("跨链返回的 txID: \(result.txId)")
            
            asyncMainDelay(duration: 0.5) { // 延迟 0.5 秒查询构造结果
                // 查询交易结构
                AElfWallet.transferCrossGetTxResultCall(nodeURL: fromNode, txID: result.txId) { txResult in
                    guard let txResult = txResult else { return }

                    let item = TransactionInfoItem(amount: amount,
                                                   symbol: self.currentSymbol(),
                                                   fee: self.fee,
                                                   toAddress: toAddress.removeChainID(),
                                                   toChain: toItem.name,
                                                   toNode: toNode,
                                                   fromAddress: App.address,
                                                   fromChain: fromItem.name,
                                                   fromNode: fromNode,
                                                   memo: memo,
                                                   txID: result.txId)
                    
                    logWarn("跨链交易结果: \(txResult)")
                    if txResult.isOk {
                        self.addTransactionIndex(item: item).subscribe(onNext: { [weak self] idxResult in
                            guard let self = self else { return }
                            SVProgressHUD.dismiss()
                            if idxResult.isOk {
                                self.enterVoucherController(item: item)
                            } else {
                                if let msg = idxResult.msg {
                                    SVProgressHUD.showInfo(withStatus: msg)
                                }
                            }
                        }, onError: { e in
                            SVProgressHUD.showError(withStatus: e.localizedDescription)
                            logDebug(e)
                        }).disposed(by: self.rx.disposeBag)
                        
                    }else {
                        SVProgressHUD.showError(withStatus: txResult.err)
                    }
                }
            }
            
        }
        
    }
    
    func addTransactionIndex(item: TransactionInfoItem) -> Observable<VResult> {
        return assetProvider.requestData(.sendTransaction(txID: item.txID,
                                                          fromChain: item.fromChain,
                                                          fromAddress: item.fromAddress,
                                                          toChain: item.toChain,
                                                          toAddress: item.toAddress,
                                                          symbol: item.symbol,
                                                          amount: item.amount,
                                                          memo: item.memo))
    }
     

    
    func startAElfTransaction(pwd: String) {
        
        SVProgressHUD.show()
        task = Plan.after(60.seconds).do { [weak self] in
            self?.showNetworkError()
        } // 30秒未返回结果的话，提示。
        
        let toAddress = self.addressField.text ?? ""
        let amount = self.amountField.text?.double() ?? 0
        let memo = self.notesField.text
        
        guard let fromItem = fromItem,let contractAt = item?.contractAddress else {
            logInfo("缺少必要参数。")
            return }
        
        let fromNode = fromItem.node.removeSlash()
        AElfWallet.transferNode(pwd: pwd,
                                toAddress: toAddress.removeChainID(),
                                amount: Int(amount * pow(Double(10), Double(item!.decimals)!)),
                                symbol: currentSymbol(),
                                memo: memo,
                                nodeURL: fromNode,
                                contractAddress: contractAt)
        { [weak self] (result) in
            self?.task?.cancel()
            guard let result = result else {
                return
            }
            
            asyncMainDelay(duration: 0.5) { // 延迟 0.5 秒查询构造结果
                // 查询交易结构
                AElfWallet.transferCrossGetTxResultCall(nodeURL: fromNode, txID: result.txId) { txResult in
                    guard let txResult = txResult else { return }
                    logInfo("查询同链交易结果: \(txResult)")
                    if txResult.isOk {
                        SVProgressHUD.dismiss()
                        let recordVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
                        recordVC.txId = result.txId
                        recordVC.fromChainID = fromItem.name
                        self?.push(controller: recordVC)
                    }else {
                        SVProgressHUD.showError(withStatus: txResult.err)
                    }
                }
            }
        }
    }
    
    func enterVoucherController(item: TransactionInfoItem) {
        
        let vc = TransactionVoucherController(item: item)
        push(controller: vc)
    }
    
    func showNetworkError() {
        SVProgressHUD.showInfo(withStatus: "Network timeout, please try again later".localized())
        task?.cancel()
    }
    
    func showChainsList(items: [ChainItem]) {
        
        ChainListView.show(items: items, closeAction: {
            //
        }, confirmClosure: { (item) in
            self.setChainID(item: item)
        })
    }
    
    // 选择跨链，添加 chainID
    func setChainID(item: ChainItem) {
        toItem = item
        if let text = self.addressField.text {
            if text.components(separatedBy: "_").count == 2 {
                self.addressField.text = text + "_" + item.name
            } else {
                self.addressField.text = Define.elfPrefix + "_" + text + "_" + item.name
            }
            
            let toAddress = self.addressField.text ?? ""
            if let toChainID = toAddress.chainID() {
                
                if !isSupportCrossTransfer(chainID: toChainID).0 {
                    SVProgressHUD.showInfo(withStatus: "Chain ID: %@ not supported".localizedFormat(toChainID))
                    return
                }
                
                asyncMainDelay(duration: 0.25) { //
                    if let fromChainID = self.item?.chainID, toChainID.lowercased() != fromChainID.lowercased() { // toChainID 存在且不相等，跨链交易
                        self.checkToChainFee(item: item) {
                            self.showPasswordAlertView(isCrossChain: true)
                        }
                    }else { // 存在，相等 即为同链
                        self.showPasswordAlertView()
                    }
                }
            }
        }
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
                                                    // %@ on %@ is not enough to pay the fee
                                                    if App.languageID == "en" { // 英文，symbol 在前。
                                                        SVProgressHUD.showInfo(withStatus: "%@ on %@ is not enough to pay the fee".localizedFormat(item.symbol,item.name))
                                                    } else {
                                                        SVProgressHUD.showInfo(withStatus: "%@ on %@ is not enough to pay the fee".localizedFormat(item.name,item.symbol))
                                                    }
                                                }
                                            }else {
                                                SVProgressHUD.showInfo(withStatus: "Parsing failed".localized())
                                            }
                                            
                                        }, onError: { e in
                                            SVProgressHUD.showInfo(withStatus: e.localizedDescription)
                                        }).disposed(by: rx.disposeBag)
    }
    
}


extension AssetTransferController {
    
    private func isSupportCrossTransfer(chainID: String) -> (Bool,ChainItem?) {
        
        guard let fromItem = self.fromItem else { return (false,nil) }
        var isContainer = false
        var item: ChainItem?
//        chains.value.forEach({
//            print($0.issueID)
//        })
        chains.value.forEach({
                   if $0.name.lowercased() == chainID.lowercased() && fromItem.isSupportTransfer(toSymbol: $0.symbol) {
                       isContainer = true
                       item = $0
                       print($0.issueID)

                   }
                   
               })
        return (isContainer,item)
    }
    
    private func issueChainID(symbol: String) -> String {
        
        var id = ""
        self.chains.value.forEach({
            print($0.issueID)
            if $0.symbol.lowercased() == symbol.lowercased() {
                id = $0.issueID
                //break
            }
        })
        return id
    }
    private func issueMainChainID(type: String) -> String {
           
           var id = ""
           self.chains.value.forEach({
               print($0.issueID)
               if $0.type.lowercased() == type.lowercased() {
                   id = $0.issueID
               }
           })
           return id
       }
    func currentSymbol() -> String {
        return self.item?.symbol ?? ""
    }
}
