//
//  VersionLogController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class VersionLogController: BaseTableViewController {

    let viewModel = VersionLogViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindLogViewModel()
    }

    func makeUI() {

        title = "Version Log".localized()

        tableView.estimatedRowHeight = 100
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none

        tableView.tableHeaderView = headerView()
        tableView.register(nibWithCellClass: VersionLogCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.footRefreshControl = nil
    }

    func headerView() -> UIView {

        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: screenBounds.width, height: 35))
        let titleLabel = UILabel(frame: CGRect.init(x: 13, y: 8, width: 200, height: 24))
        titleLabel.text = "Version Release".localized()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .appBlack
        headerView.addSubview(titleLabel)

        return headerView
    }

    func bindLogViewModel() {

        let input = VersionLogViewModel.Input(headerRefresh: headerRefresh())
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: VersionLogCell.className,
                                                 cellType: VersionLogCell.self))
        {(_,item,cell)  in
            cell.item = item
        }.disposed(by: rx.disposeBag)

        Observable.zip(tableView.rx.itemSelected,tableView.rx.modelSelected(AppVersionLog.self)).subscribe(onNext: { (index,item) in
            self.tableView.deselectRow(at: index, animated: true)
            logInfo(item.intro ?? [""])
        }).disposed(by: rx.disposeBag)

    }
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


}
