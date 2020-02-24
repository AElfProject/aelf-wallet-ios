//
//  AssetSortView.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/9.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import SwiftMessages

class AssetSortView: MessageView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var buttonBottom: NSLayoutConstraint!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    var confirmAction: (() -> Void)?

    var didSelectedClosure:((AssetSortType) -> Void)?

    var dataSource = [AssetSortType]()

    override func awakeFromNib() {
        confirmButton.cornerRadius = 15
        buttonBottom.constant = isIphoneX ? 34:0

    }

    func setupTableView() {

        self.dataSource = [.byValueSmallestToLargest,
                           .byValueLargestToSmallest,
                           .byNameAToZ,
                           .byNameZToA]

        tableView.register(nibWithCellClass: AssetSortCell.self)
        
        let height: CGFloat = 50
        tableView.rowHeight = height
        tableHeight.constant = height * CGFloat(self.dataSource.count)
        tableView.reloadData()

    }

    class func show(selectedResult: ((AssetSortType) -> Void)?) {

        guard let view = AssetSortView.loadFromNib(named: AssetSortView.className) as? AssetSortView else { return }
        view.didSelectedClosure = selectedResult
        view.setupTableView()

        view.confirmAction = { SwiftMessages.hide() }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .bottom

        config.dimMode = .gray(interactive: false)
        config.keyboardTrackingView = KeyboardTrackingView()
        config.interactiveHide = false
        SwiftMessages.show(config: config, view: view)


    }


    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        confirmAction?()
    }


}


extension AssetSortView: UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withClass: AssetSortCell.self)
        cell.title = dataSource[indexPath.row].localized
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = dataSource[indexPath.row]
        didSelectedClosure?(item)

        confirmAction?() // hide
    }

}
