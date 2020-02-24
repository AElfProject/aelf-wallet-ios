//
//  AssetSortView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import SwiftMessages

enum ShareType {
    case wechat
    case telegram
    case twitter
    case facebook

    var localized: String {
        switch self {
        case .wechat: return "WeChat ID".localized()
        case .telegram: return "Telegram"
        case .twitter: return "Twitter"
        case .facebook: return "FaceBook"
        }
    }

    var link: String {
        switch self {
        case .wechat: return "aelf社区"
        case .telegram: return "https://t.me/aelfblockchain"
        case .twitter: return "https://twitter.com/aelfblockchain"
        case .facebook: return "https://www.facebook.com/aelfofficial/"
        }
    }
}

class ShareAlertView: MessageView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    var confirmAction: (() -> Void)?

    var didSelectedClosure:((ShareType) -> Void)?

    var dataSource = [ShareType]()

    override func awakeFromNib() {
        confirmButton.cornerRadius = 15
        buttonBottom.constant = isIphoneX ? 34:0

        tableView.register(nibWithCellClass: ShareTableCell.self)

    }

    func reloadView(type: ShareType) {

        dataSource = [type]

        let height: CGFloat = 55
        tableView.rowHeight = height
        tableHeight.constant = height * CGFloat(self.dataSource.count)
        tableView.reloadData()
    }

    class func show(type: ShareType,selectedResult: ((ShareType) -> Void)?) {

        guard let view = ShareAlertView.loadFromNib(named: ShareAlertView.className) as? ShareAlertView else { return }
        view.didSelectedClosure = selectedResult
        view.reloadView(type: type)

        view.confirmAction = { SwiftMessages.hide() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .bottom

        config.dimMode = .gray(interactive: true)
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)


    }


    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        confirmAction?()
    }


}


extension ShareAlertView: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: ShareTableCell.self)
        let item = dataSource[indexPath.row]
        cell.item = item
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = dataSource[indexPath.row]
        didSelectedClosure?(item)

        confirmAction?() // hide
    }

}
