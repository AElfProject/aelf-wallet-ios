//
//  DappTransactionView.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/16.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages
import SwiftyAttributes

private let cellHeight:CGFloat = 35

class DappTransactionView: MessageView {
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var joinDescLabel: UILabel!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    var dataSource = [DappTransactionItem]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinButton.setTitle("Dapp join White list".localized(), for: .normal)
        joinButton.setTitlePosition(position: .right, spacing: 10)
        
        configureTableView()
    }
    
    func configureTableView() {
        
        tableView.register(nibWithCellClass: DappTransactionCell.self)
        tableView.rowHeight = cellHeight
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    var confirmAction: (() -> Void)?
    
    class func show(body: AELFTransactionBody,isJoined: Bool,confirmClosure: ((DappTransactionView) -> Void)?) {
        
        guard let view = DappTransactionView.loadFromNib(named: DappTransactionView.className) as? DappTransactionView else { return }
        view.updateSubViews(body: body)
        view.joinButton.isSelected = isJoined
        view.confirmAction = { confirmClosure?(view) }
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)
        
    }
    
    var isJoined: Bool {
        return joinButton.isSelected
    }
    
    func hide() {
        self.endEditing(true)
        SwiftMessages.hide(animated: false)
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        hide()
        confirmAction?()
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
 

extension DappTransactionView {
    
    func updateSubViews(body: AELFTransactionBody) {
        dataSource.removeAll()
        dataSource.append(DappTransactionItem.init(title: "Amount".localized(), value: amountAttribute(body), enableCopy: false, enableLines: false))
        dataSource.append(DappTransactionItem.init(title: "From".localized(), value: fromAttribute(body), enableCopy: true, enableLines: false))
        dataSource.append(DappTransactionItem.init(title: "To".localized(), value: toAttribute(body), enableCopy: true, enableLines: false))
        dataSource.append(DappTransactionItem.init(title: "TxID".localized(), value: txIDAttribute(body), enableCopy: true, enableLines: false))
        dataSource.append(DappTransactionItem.init(title: "Block".localized(), value: blockNumberAttribute(body), enableCopy: false, enableLines: false))
        
        tableView.reloadData()
        
        tableHeight.constant = CGFloat(dataSource.count) * cellHeight
        layoutIfNeeded()
    }
    
    private func amountAttribute(_ body: AELFTransactionBody) -> NSAttributedString {
        guard let json = body.transaction?.params else { return NSAttributedString() }
        guard let params = AELFTransactionParams(JSONString: json) else { return NSAttributedString() }
        
        let amount = (params.amount.double() ?? 0) / Define.decimalsValue
        let symbol = params.symbol
        let attribute = (amount.string + " " + symbol).withFont(.systemFont(ofSize: 16, weight: .bold)).withTextColor(.black)
        return attribute
    }
    
    private func fromAttribute(_ body: AELFTransactionBody) -> NSAttributedString {
        
        let attribute = (body.transaction?.from ?? "").withFont(.systemFont(ofSize: 15)).withTextColor(.c78)
        return attribute + " " + copyAttributed()
    }
    
    private func toAttribute(_ body: AELFTransactionBody) -> NSAttributedString {
        
        guard let json = body.transaction?.params else { return NSAttributedString() }
        guard let params = AELFTransactionParams(JSONString: json) else { return NSAttributedString() }
        let attribute = (params.to).withFont(.systemFont(ofSize: 15)).withTextColor(.c78)
        return attribute + " " + copyAttributed()
    }
    
    private func txIDAttribute(_ body: AELFTransactionBody) -> NSAttributedString {
        
        let attribute = (body.transactionId).withFont(.systemFont(ofSize: 15)).withTextColor(.c78)
        return attribute + " " + copyAttributed()
    }
    
    private func blockNumberAttribute(_ body: AELFTransactionBody) -> NSAttributedString {
        guard let blockNumber = body.transaction?.refBlockNumber.string else { return NSAttributedString() }
        let attribute = blockNumber.withFont(.systemFont(ofSize: 15)).withTextColor(.c78)
        return attribute
    }
    
    private func copyAttributed() -> NSAttributedString {
        let ach = NSTextAttachment()
        ach.image = UIImage(named: "address_copy")
        ach.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        return NSAttributedString(attachment: ach)
    }
    
}


extension DappTransactionView: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withClass: DappTransactionCell.self)
        cell.item = item
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }


}
