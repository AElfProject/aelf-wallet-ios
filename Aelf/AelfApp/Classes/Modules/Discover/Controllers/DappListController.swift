//
//  DappListController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class DappListController: BaseController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var segmentView: JXSegmentedView!
    var moreType: Int?
    

    var segmentedDataSource: JXSegmentedBaseDataSource?
    lazy var listContainerView = JXSegmentedListContainerView(dataSource: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentView()
        addNavigationItem()
    }

    func addNavigationItem() {

        let btn = UIButton(type: .custom)
        btn.size = CGSize(width: 40, height: 40)
        btn.setImage(UIImage(named: "address_search"), for: .normal)
        btn.addTarget(self, action:#selector(searchTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }

    @objc func searchTapped() {
        let searchVC = UIStoryboard.loadController(DappSearchController.self, storyType: .discover)
        
        push(controller: searchVC)
    }
    
    
    override func languageChanged() {
        
        title = "Dapp List".localized()
    }

    func setupSegmentView() {

        let dataSource = JXSegmentedNumberDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)
        let titles = [ "All","Games", "Others"].map({ $0.localized() })
        dataSource.titles = titles
        dataSource.numbers = titles.map({_ in 0 })
        dataSource.titleSelectedColor = .master

        dataSource.numberStringFormatterClosure = {(number) -> String in
            return "\(number)"
        }

        dataSource.reloadData(selectedIndex: 0)
        segmentedDataSource = dataSource

        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.master
        indicator.indicatorWidth = screenBounds.width/CGFloat(titles.count)
        indicator.lineStyle = .lengthenOffset
        segmentView.defaultSelectedIndex = moreType ?? 0
        segmentView.indicators = [indicator]
        segmentView.dataSource = segmentedDataSource
        segmentView.delegate = self

        let lineWidth = 2/UIScreen.main.scale
        let lineLayer = CALayer()
        lineLayer.backgroundColor = UIColor.lightGray.cgColor
        lineLayer.frame = CGRect(x: 0,
                                 y: segmentView.height - lineWidth,
                                 width: segmentView.width,
                                 height: lineWidth)
        segmentView.layer.addSublayer(lineLayer)

        segmentView.contentScrollView = listContainerView.scrollView
        
        listContainerView.defaultSelectedIndex = moreType ?? 0
        
        contentView.addSubview(listContainerView)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listContainerView.frame = contentView.bounds
    }
}

extension DappListController: JXSegmentedViewDelegate {
    
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

extension DappListController: JXSegmentedListContainerViewDataSource {

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView,
                           initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        let vc = DappGameController()
        vc.parentVC = self
        switch index {
        case 0:
            vc.type = .all
        case 1:
            vc.type = .games
        case 2:
            vc.type = .others
        default:
            vc.type = .all
        }

        return vc
    }
}
