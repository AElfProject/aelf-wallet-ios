//
//  TransactionVoucherController.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class TransactionVoucherController: BaseTableViewController {

    var item: TransactionInfoItem

    init(item: TransactionInfoItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var dataSource = [TransactionVoucherItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupDataSource()
    }

    override func configBaseInfo() {

        title = "Transaction Voucher".localized()
    }

    func setupTableView() {
        tableView.footRefreshControl = nil
        tableView.headRefreshControl = nil
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: TransactionVoucherCell.self)
        tableView.register(nibWithCellClass: TransactionVoucherHeaderCell.self)
        tableView.register(nibWithCellClass: TransactionVoucherFooterCell.self)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 40
    }

    func setupDataSource() {

        var dataSource = [TransactionVoucherItem]()

        // header
        let header = TransactionVoucherItem(title: "Transaction Header Info".localized())
        dataSource.append(header)

        let amount = TransactionVoucherItem(title: "Amount".localized(), value: amountAttributed())
        dataSource.append(amount)
        
        let fee = TransactionVoucherItem(title: "Miner Fee".localized(), value: feeAttributed())
        dataSource.append(fee)
        
        let from = TransactionVoucherItem(title: "From".localized(), value: fromAttributed(), enableCopy: true, enableLines: true)
        dataSource.append(from)
        
        let to = TransactionVoucherItem(title: "To".localized(), value: toAttributed(), enableCopy: true, enableLines: true)
        dataSource.append(to)
        
        let memo = TransactionVoucherItem(title: "Memo".localized(), value: memoAttributed(), enableCopy: false, enableLines: true)
        dataSource.append(memo)
        
        let txID = TransactionVoucherItem(title: "TxID".localized(), value: txIDAttributed(), enableCopy: true, enableLines: false)
        dataSource.append(txID)

        // footer
        let footer = TransactionVoucherItem(title: "")
        dataSource.append(footer)

        self.dataSource = dataSource
        tableView.reloadData()
    }

    func amountAttributed() -> NSAttributedString {
        let amountAttr = item.amount.string.withFont(.systemFont(ofSize: 18, weight: .medium)).withTextColor(.appBlack)
        let symbolAttr = item.symbol.withFont(.systemFont(ofSize: 12, weight: .medium)).withTextColor(.appBlack)
        return amountAttr + " " + symbolAttr
    }

    func feeAttributed() -> NSAttributedString {
        let feeAttr = item.fee.string.withFont(.systemFont(ofSize: 18, weight: .regular)).withTextColor(.appBlack)
        let symbolAttr = item.symbol.withFont(.systemFont(ofSize: 12, weight: .medium)).withTextColor(.appBlack)
        return feeAttr + " " + symbolAttr
    }

    func toAttributed() -> NSAttributedString {
//        let chainAttr = item.toChain.withFont(.systemFont(ofSize: 15, weight: .regular)).withTextColor(UIColor.init(hexString: "F4A11C")!)
        let addressAttr = item.toAddress.elfAddress(item.toChain).withFont(.systemFont(ofSize: 14, weight: .regular)).withTextColor(.appBlack)
//        return chainAttr + addressAttr + " " + copyAttributed()
        return addressAttr + " " + copyAttributed()
    }

    func fromAttributed() -> NSAttributedString {
//        let chainAttr = item.fromChain.withFont(.systemFont(ofSize: 15, weight: .regular)).withTextColor(UIColor.init(hexString: "641EB0")!)
        let addressAttr = item.fromAddress.elfAddress(item.fromChain).withFont(.systemFont(ofSize: 14, weight: .regular)).withTextColor(.appBlack)
//        return chainAttr + " " + addressAttr + " " + copyAttributed()
        return addressAttr + " " + copyAttributed()
    }

    func memoAttributed() -> NSAttributedString {
        let memoAttr = item.memo.withFont(.systemFont(ofSize: 13, weight: .regular)).withTextColor(.appBlack)
        return memoAttr
    }

    func txIDAttributed() -> NSAttributedString {
        let txIDAttr = item.txID.withFont(.systemFont(ofSize: 15, weight: .regular)).withTextColor(.appBlack)
        return txIDAttr + " " + copyAttributed()
    }

    func copyAttributed() -> NSAttributedString {
        let ach = NSTextAttachment()
        ach.image = UIImage(named: "address_copy")
        ach.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        return NSAttributedString(attachment: ach)
    }
}

extension TransactionVoucherController: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = dataSource[indexPath.row]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withClass: TransactionVoucherHeaderCell.self)
            cell.item = item
            return cell
        }

        if indexPath.row == dataSource.count - 1 {
            let cell = tableView.dequeueReusableCell(withClass: TransactionVoucherFooterCell.self)
            cell.confirmClosure = { [weak self] in
                self?.enterTransactionDetailController()
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withClass: TransactionVoucherCell.self)
        cell.item = item
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }


}


extension TransactionVoucherController {
    
    

    func enterTransactionDetailController() {

        let recordVC = UIStoryboard.loadController(TransactionDetailController.self, storyType: .setting)
        recordVC.txId = self.item.txID
        recordVC.fromChainID = item.fromChain
        push(controller: recordVC)
    }
}
