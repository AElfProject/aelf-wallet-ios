//
//  HelpManagerController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/25.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

struct HelpItem {
    var title: String
    var info: String
    init(_ title:String,info:String) {
        self.title = title
        self.info = info
    }
}

struct HelpSection {
    var item: HelpItem
    var title: String
    var show: Bool
    init(_ title:String,item:HelpItem,show:Bool=true) {
        self.title = title
        self.item = item
        self.show = show
    }
}

class HelpManagerController: BaseStaticTableController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help_title".localized()
        tableView.tableFooterView = UIView.init()
        tableView.sectionHeaderHeight = 48
        tableView.register(nibWithCellClass: HelpDetailCell.self)

        addBackItem()
        addRightNavItem()
    }

    func addRightNavItem() {
        
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "email"), for: .normal)
        btn.addTarget(self, action:#selector(self.feedBackAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
    }

    var sectionModel = [
        HelpSection("Help_wallet", item: HelpItem("", info: "Help_wallet_info")),
        HelpSection("Help_search", item: HelpItem("", info: "Help_search_info")),
        HelpSection("Help_password", item: HelpItem("", info: "Help_password_info")),
        HelpSection("Help_transation", item: HelpItem("", info: "Help_transation_info")),
        HelpSection("Help_cross_transaction", item: HelpItem("", info: "Help_cross_transaction_info")),
        HelpSection("Help_backup", item: HelpItem("", info: "Help_backup_info")),
    ]

    @objc func feedBackAction() {

        let feedBackVC = UIStoryboard.loadController(FeedBackViewController.self, storyType: .setting)
        self.navigationController?.pushViewController(feedBackVC, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionModel.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = sectionModel[section]
        return item.show ? 0 : 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let sectionM = sectionModel[indexPath.section]
        tableView.cellForRow(at: indexPath)
        let cell = tableView.dequeueReusableCell(withClass: HelpDetailCell.self, for: indexPath)
        cell.desLabel.text = sectionM.item.info.localized()
        return cell
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionM = sectionModel[section]
        let headView = tableHeaderView.headViewWithTableView(tableView)
        headView.delegate = self
        headView.setLeftBottom(sectionM.show)
        headView.section = section
        headView.contentView.backgroundColor = .white
        headView.contentLabel.text = sectionM.title.localized()
      
        return headView
    }
    
    
}
extension HelpManagerController : tableHeaderViewDelegate {
    
    func tableHeaderViewDelegateClick(_ head: tableHeaderView, num: Int) {
        
        let isShow = sectionModel[num].show
        sectionModel[num].show = !isShow
        let index = IndexSet(integer:num)
        tableView.reloadSections(index, with: .fade)
        
        
        
    }
    
}
