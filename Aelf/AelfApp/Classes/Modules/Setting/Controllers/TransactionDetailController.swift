//
//  TransactionDetailController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/4.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import Schedule

class TransactionDetailController: BaseStaticTableController {
    
    var item: AssetHistory?
    var txId: String?
    var fromChainID: String?
    
    @IBOutlet var detailLabelArray: [UILabel]!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet var tipsLabelArray: [UILabel]!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var transStatusLabel: UILabel!
    @IBOutlet weak var transImageView: UIImageView!
    @IBOutlet weak var failedInfoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var failedBgView: UIView!
    @IBOutlet weak var failedInfoLabel: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    
    var viewModel = TransationDetailViewModel()
    
    var refreshTrigger = PublishSubject<Void>()
    
    private var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        addBackItem()
        
        bindViewModel()
        startScheduler()
    }
    
    func makeUI() {
        
        title = "Transaction Details".localized()
        tableView.backgroundColor = .white
        
        tableView.addSubview(loadingView)
        loadingView.startLoading()
    }
    
    override func pop()  {
        if self.txId == "" || self.txId == nil {
            self.navigationController?.popViewController()
            return
        }
        
        if let controllers = navigationController?.viewControllers {
            for vc in controllers {
                if vc.isKind(of: AssetDetailController.self){
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }
        
        self.navigationController?.popViewController()
    }
    
    func updateTableSubViews(_ isHidden: Bool) {
        tableView.subviews.forEach({ $0.isHidden = isHidden })
    }
    
    func bindViewModel() {
        
        var txId = ""
        if let id = self.txId {
            txId = id
        } else if let item = self.item {
            txId = item.txid
            fromChainID = item.chain
        }
        
        let input = TransationDetailViewModel.Input(address: App.address,
                                                    txId: txId,
                                                    fromChainID:fromChainID,
                                                    fetchDetail: refreshTrigger)
        let output = viewModel.transform(input: input)
        
        output.item.subscribe(onNext: { [weak self] item in
            self?.item = item
            self?.reloadSubViews(item: item)
            }, onError: { e in
                logInfo("获取交易详情失败：\(e)")
        }).disposed(by: rx.disposeBag)
        
    }
    
    func startScheduler() {
        
        task = Plan.now.concat(Plan.every(3.second)).do { [weak self] in
            self?.refreshAction()
            logDebug("重新请求数据。")
        }
    }
    
    @objc func refreshAction() {
        refreshTrigger.onNext(())
    }
    
    @IBAction func copyAction(_ sender: UIButton) {
        
        switch sender.tag {
        case 1002: // to
            guard let item = item else { return }
            copyId(id: item.from.elfAddress(item.fromChainID))
        case 1003: // from
            guard let item = item else { return }
            copyId(id: item.to.elfAddress(item.toChainID))
        default:
            if let id = item?.txid {
                copyId(id: id)
            }else if let id = txId {
                copyId(id: id)
            }
        }
    }
    
    func copyId(id: String) {
        UIPasteboard.general.string = id
        SVProgressHUD.showSuccess(withStatus: "Copied".localized())
    }
    
    @IBAction func goDetailTapped(_ sender: UIButton) {
        
        guard let item = item else { return }
        
        guard let chain = ChainItem.getItem(chainID: item.chain) else { return }
        let url = chain.explorer.removeSlash() + "/tx/\(item.txid)"
        logDebug("拼接的 TX 浏览器地址: \(url)")
        
        let webVC = WebViewController(urlStr: url)
        push(controller: webVC)
    }
    
    
    lazy var loadingView: TransferLoadingView = {
        let view = TransferLoadingView(frame: self.tableView.bounds)
        return view
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func reloadSubViews(item: AssetHistory) {
        
        loadingView.stopLoading()
        
        transImageView.image = item.resultImage()
        transStatusLabel.text = item.statusText
        
        if item.status.int == -1 { // failed
            footerView.height = 0
            failedBgView.isHidden = false
            if item.to.lowercased() == App.address.lowercased() { // 我是收款方
                failedInfoHeight.constant = 0
                failedBgView.isHidden = true
            } else {
                failedInfoLabel.text = "You need to re-sign transaction to initiate a transfer".localized()
                failedInfoHeight.constant = 65
            }
            timeLabel.text = nil
        }else {
            footerView.height = 60
            failedInfoHeight.constant = 0
            failedBgView.isHidden = true
            timeLabel.text = TimeInterval(item.time?.int ?? 0).transTime()
            
            if item.status.int == 1 { // 成功
                task?.cancel()
            }
            
        }
        
        let tipsArray = ["Amount",
                         "Miner Fee",
                         "From",
                         "To",
                         "Memo",
                         "TxID",
                         "Block"].map { $0.localized() }
        for i in 0..<tipsLabelArray.count {
            let label = tipsLabelArray[i]
            label.text = tipsArray[i]
        }
        
        let detailsArray = [item.amount,
                            item.fee ?? "0.00",
                            item.from.elfAddress(item.fromChainID),
                            item.to.elfAddress(item.toChainID),
                            item.memo ?? "",
                            item.txid,
                            "\(item.block)"].map { $0.localized() }
        for i  in 0..<detailLabelArray.count {
            let label = detailLabelArray[i]
            
            switch i {
            case 0: // Balance
                label.attributedText = getAttri(pre: item.amount,
                                                preFont: .systemFont(ofSize: 16),
                                                next: " \(item.symbol.uppercased())", nextFont: .systemFont(ofSize: 12))
            case 1: // Fee
                label.attributedText = getAttri(pre: item.fee ?? "0.00",
                                                preFont: .systemFont(ofSize: 16),
                                                next: " \(item.symbol.uppercased())",
                    nextFont: .systemFont(ofSize: 12))
                
            default:
                label.text = detailsArray[i]
            }
        }
        
        if item.txid.length > 0 {
            QRCodeUtil.setQRCodeToImageView(qrImageView, item.txid)
        }else {
            qrImageView.image = nil
        }
        
        tableView.reloadData()
    }
    
    func getAttri(pre : String,preFont:UIFont, next :String,nextFont:UIFont) -> NSAttributedString {
        
        let color = UIColor(red: 0.04,green: 0.09,blue: 0.18,alpha:1)
        let attri = NSMutableAttributedString(string: pre,
                                              attributes: [.font: preFont,
                                                           .foregroundColor: color])
        let nextAttri = NSAttributedString(string: next,
                                           attributes: [.font: nextFont,
                                                        .foregroundColor: color])
        attri.append(nextAttri)
        
        return attri
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if item != nil {
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        //        if item?.status.int == -1 && indexPath.row == 6 { // 失败隐藏
        //            return 0
        //        }
        return UITableView.automaticDimension
    }
    
}
