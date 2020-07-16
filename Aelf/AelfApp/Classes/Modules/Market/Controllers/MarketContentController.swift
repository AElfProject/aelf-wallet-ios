//
//  MarketContentController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class MarketContentController: BaseController {

    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    let marketVC = UIStoryboard.loadController(MarKetListController.self, storyType: .market)
    let favoriteVC = MarketFavouritesController()

    lazy var listContainerView: JXSegmentedListContainerView = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    let dataSource = JXSegmentedNumberDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSegmentViews()

        addNavigationItem()

        bindViewModel()
    }

    override func languageChanged() {
        navigationItem.title = "Market".localized()

        guard let _ = segmentedDataSource else { return }

        let idx = segmentedView.selectedIndex
        dataSource.titles = ["Favourites", "All"].map({ $0.localized() })
        dataSource.reloadData(selectedIndex: 0)

        segmentedView.defaultSelectedIndex = idx
        segmentedView.reloadData()

        listContainerView.defaultSelectedIndex = idx
        listContainerView.reloadData()
    }

    func bindViewModel() {

        favoriteVC.emptyDataSetButtonTap.subscribe(onNext: { [weak self] _ in
            self?.searchTapped()
        }).disposed(by: rx.disposeBag)

    }

    func addNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
    }

    @objc func searchTapped() {
        SVProgressHUD.show()
        push(controller: MarketSearchController())
    }

    func addSegmentViews() {

        marketVC.parentVC = self
        favoriteVC.parentVC = self

        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)

        dataSource.titles = ["Favourites", "All"].map({ $0.localized() })
        dataSource.titleSelectedColor = .master
        dataSource.numbers = [0, 0]

        dataSource.reloadData(selectedIndex: 0)
        segmentedDataSource = dataSource

        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.master
        indicator.indicatorWidth = screenWidth/2.0
        indicator.lineStyle = .lengthenOffset
        segmentedView.indicators = [indicator]
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        segmentedView.contentScrollView = listContainerView.scrollView
        
        view.addSubview(listContainerView)

    }

    lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.size = CGSize(width: 40, height: 40)
        btn.setImage(UIImage(named: "address_search")?.original, for: .normal)
        btn.addTarget(self, action:#selector(searchTapped), for: .touchUpInside)

        return btn
    }()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
        let height = screenBounds.height - 50 - iPHONE_NAVBAR_HEIGHT - iPHONE_TABBAR_HEIGHT
        listContainerView.frame = CGRect(x: 0,
                                         y: 50,
                                         width: view.width,
                                         height: height)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        favoriteVC.headerRefreshTrigger.onNext(())
    }

}


extension MarketContentController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            dotDataSource.dotStates[index] = false
            segmentedView.reloadItem(at: index)
        }
    }

    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        listContainerView.didClickSelectedItem(at: index)
    }

    func segmentedView(_ segmentedView: JXSegmentedView,
                       scrollingFrom leftIndex: Int,
                       to rightIndex: Int,
                       percent: CGFloat) {
        listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}

extension MarketContentController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView,
                           initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        switch index {
        case 0:
            return favoriteVC
        default:
            return marketVC
        }
    }
}

