//
//  AssetManagerController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView
import Schedule

class AssetManagerController: BaseController {

    @IBOutlet weak var segmentView: JXSegmentedView!
    @IBOutlet weak var contentView: UIView!

    private var segmentedDataSource: JXSegmentedBaseDataSource?
    private lazy var listContainerView: JXSegmentedListContainerView? = {
        return JXSegmentedListContainerView(dataSource: self as JXSegmentedListContainerViewDataSource)
    }()

    private let addAssetVC = UIStoryboard.loadController(AddAssetController.self, storyType: .assets)
    private let editAssetVC = UIStoryboard.loadController(EditAssetController.self, storyType: .assets)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentView()
        bindManagerViewModel()
    }

    func bindManagerViewModel() {

        // 添加资产变化通知 编辑资产

        editAssetVC.unbindToTrigger.bind(to: addAssetVC.unbindTrigger).disposed(by: rx.disposeBag)
        addAssetVC.addTrigger.bind(to: editAssetVC.addTrigger).disposed(by: rx.disposeBag)
    }

    override func configBaseInfo() {

    }

    override func languageChanged() {

        title = "Asset Management".localized()
    }

    func setupSegmentView() {
        
        let dataSource = JXSegmentedNumberDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)

        let titles = ["Add Assets","Edit Assets"].map { $0.localized() }
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
        segmentView.indicators = [indicator]

        segmentView.dataSource = segmentedDataSource
        segmentView.delegate = self


        if let con = listContainerView {
            segmentView.contentScrollView = con.scrollView
            
            contentView.addSubview(con)
        }

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listContainerView?.frame = contentView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.post(name: NotificationName.currencyDidChange)
    }

    @IBAction func sortButtonTapped(_ sender: UIButton) {

    }

}

extension AssetManagerController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        view.endEditing(true)
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            dotDataSource.dotStates[index] = false
            segmentedView.reloadItem(at: index)
        }
    }

    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        listContainerView?.didClickSelectedItem(at: index)
    }

    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        listContainerView?.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}

extension AssetManagerController: JXSegmentedListContainerViewDataSource {

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView,
                           initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        switch index {
        case 0:
            return addAssetVC
        default:
            return editAssetVC
        }
    }
}
