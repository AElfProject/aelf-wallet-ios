//
//  AssetDetailController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/25.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class AssetDetailController: BaseController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    @IBOutlet weak var transferButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var receiveBgView: UIView!
    @IBOutlet weak var receiveButton: UIButton!

    @IBOutlet weak var segmentedView: JXSegmentedView!

    var item: AssetDetailItem?

    var segmentedDataSource: JXSegmentedBaseDataSource?
    lazy var listContainerView = JXSegmentedListContainerView(dataSource: self)

    let viewModel = AssetDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegmentView()
        addWhiteBackItem()
        bindDetailViewModel()
    }

    override func configBaseInfo() {

        receiveBgView.addShadow(ofColor: UIColor.black, radius: 1, offset: CGSize.zero, opacity: 0.5)
        self.addressLabel.text = App.address.elfAddress(item?.chainID ?? Define.defaultChainID)
        titleLabel.text = nil
    }

    func bindDetailViewModel() {
        guard let item = item else { return }
        let input = AssetDetailViewModel.Input(symbol: item.symbol,
                                               address: App.address,
                                               contractAddress: item.contractAddress,
                                               chainID: item.chainID,
                                               refresh: headerRefresh())
        let output = viewModel.transform(input: input)
        output.balance.map{ $0.detailTitle() }
            .bind(to: moneyLabel.rx.attributedText).disposed(by: rx.disposeBag)
        output.balance.map({ $0.detailTitle().string.isEmpty })
            .bind(to: activityView.rx.isAnimating).disposed(by: rx.disposeBag)
    }

    override func languageChanged() {

        receiveButton.setTitle("  " + "Receive".localized(), for: .normal)
        transferButton.setTitle("  " + "Transfer".localized(), for: .normal)

        guard let item = item else { return }
        title = (item.chainID) + "-" + (item.symbol)
    }

    func setupSegmentView() {

        let dataSource = JXSegmentedNumberDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)
        let titles = [ "All","Transfer", "Receive"].map{ $0.localized() }
        dataSource.titles = titles
        dataSource.numbers = [0,0,0]
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

        segmentedView.indicators = [indicator]
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self

        segmentedView.contentScrollView = listContainerView.scrollView
        
        contentView.addSubview(listContainerView)

    }
    
    @IBAction func copyButtonTapped(_ sender: UIButton) {

        UIPasteboard.general.string = self.addressLabel.text
        SVProgressHUD.showSuccess(withStatus: "Copied".localized())
    }

    @IBAction func transferButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: AssetTransferController.className, sender: nil)
    }
    
    @IBAction func receiveButtonTapped(_ sender: UIButton) {

        performSegue(withIdentifier: AssetReceiveController.className, sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.master,
                                                                            size: CGSize(width: 10, height: 10)),for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        headerRefreshTrigger.onNext(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listContainerView.frame = contentView.bounds
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension AssetDetailController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            dotDataSource.dotStates[index] = false
            segmentedView.reloadItem(at: index)
        }
    }

    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
        listContainerView.didClickSelectedItem(at: index)
    }

    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        listContainerView.scrolling(from: leftIndex, to: rightIndex, percent: percent, selectedIndex: segmentedView.selectedIndex)
    }
}

extension AssetDetailController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView,
                           initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        let vc = AssetHistoryController()
        vc.parentVC = self
        vc.item = item
        switch index {
        case 0:
            vc.type = .all
        case 1:
            vc.type = .transfer
        case 2:
            vc.type = .receive
        default:
            vc.type = .all
        }
        vc.view.frame = contentView.bounds
        return vc
    }
}

extension AssetDetailController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let transerVC = segue.destination as? AssetTransferController {
            transerVC.item = item
        }else if let receiveVC = segue.destination as? AssetReceiveController {
            receiveVC.item = item
        }
    }
}
