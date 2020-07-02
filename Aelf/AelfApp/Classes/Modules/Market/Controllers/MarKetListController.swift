//
//  MarKetListController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import RxDataSources
import Schedule
import JXSegmentedView

enum MarketDataLoadType {
    case normal
    case up
    case down
}

class MarKetListController: BaseTableViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!

    var parentVC: MarketContentController?

    var priceLoadType: MarketDataLoadType = .normal
    var changeLoadType:MarketDataLoadType = .normal
    let typeArray: [MarketDataLoadType] = [.normal,.down,.up]
    let imageArray = ["sort_default","sort_up","sort_down"]
    let sortTriger = BehaviorRelay<Int>(value: -1) // =0价格倒序 =1价格正序 =2涨幅倒序 =3跌幅正序
    let viewModel = MarketViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        bindMarketViewModel()
        checkIsBackupMnemonic()
    }

    func makeUI() {

        tableView.frame = CGRect(x: 0, y: 35, width: screenBounds.width,
                                 height: screenBounds.height - iPHONE_TABBAR_HEIGHT - iPHONE_NAVBAR_HEIGHT - 35)
        tableView.register(nibWithCellClass: MarketCell.self)
        tableView.tableFooterView = UIView.init()
        tableView.rowHeight = 55
        tableView.separatorColor = .lightGray

        view.insertSubview(tableView, at: 0) //
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        tableView.y = 35
        tableView.height -= 35
    }

    override func languageChanged() {

        self.currencyLabel.text = "Market_currency".localized()

        priceButton.setTitle("Market_price".localized(), for: .normal)
        changeButton.setTitle("Market_change".localized(), for: .normal)
        priceButton.setImage(UIImage(named: "sort_default"), for: .normal)
        changeButton.setImage(UIImage(named: "sort_default"), for: .normal)

        priceButton.setTitlePosition(position: .left)
        changeButton.setTitlePosition(position: .left)
    }

    func bindMarketViewModel() {

        let input = MarketViewModel.Input(headerRefresh: headerRefreshTrigger,
                                          footerRefresh: footerRefreshTrigger,
                                          sortType: sortTriger)
        let output = viewModel.transform(input: input)

        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "Empty Data".localized() }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        emptyDataSetButtonTap.subscribe(onNext: { () in
            self.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: MarketCell.className,
                                                 cellType: MarketCell.self)) { (_, element, cell) in
                                                    cell.item = element
        }.disposed(by: rx.disposeBag)

        tableView.rx.modelSelected(MarketCoinModel.self).subscribe(onNext: { [weak self] item in
            self?.pushFromParent(model: item)
            }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.currencyDidChange).subscribe(onNext: { [weak self] notify in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)

        tableView.headRefreshControl.beginRefreshing()
    }
    
    func pushFromParent(model:MarketCoinModel) {

        let detailVC = UIStoryboard.loadController(MarketDetailController.self, storyType: .market)
        detailVC.model = model
        parentVC?.push(controller: detailVC)
    }

    
    @IBAction func priceAction(_ sender: UIButton) {
      
        for (index,type) in typeArray.enumerated() {
            if type == self.priceLoadType {
                self.priceLoadType = typeArray[(index+1)%3]
                let imageNamed = imageArray[(index+1)%3]
                sender.setImage(UIImage.init(named: imageNamed), for: .normal)
                self.changeLoadType = typeArray[0]
                self.changeButton.setImage(UIImage.init(named: imageArray[0]), for: .normal)
                if self.priceLoadType == .normal {
                    self.sortTriger.accept(-1)
                } else  if self.priceLoadType == .down {
                    self.sortTriger.accept(1)
                } else {
                    self.sortTriger.accept(0)
                }
                changeButton.setTitlePosition(position: .left)
                break
            }
        }
    }
    
    @IBAction func changeAction(_ sender: UIButton) {
        for (index,type) in typeArray.enumerated() {
            if type == self.changeLoadType {
                self.changeLoadType = typeArray[(index+1)%3]
                let imageNamed = imageArray[(index+1)%3]
                sender.setImage(UIImage(named: imageNamed), for: .normal)
                self.priceLoadType = typeArray[0]
                self.priceButton.setImage(UIImage(named: imageArray[0]), for: .normal)
                if self.changeLoadType == .normal {
                    self.sortTriger.accept(-1)
                } else if  self.changeLoadType == .up {
                    self.sortTriger.accept(2)
                } else {
                    self.sortTriger.accept(3)
                }
                priceButton.setTitlePosition(position: .left)
                break
            }
        }
    }

}

extension MarKetListController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}
