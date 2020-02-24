//
//  ImportContentController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

// 导入 Keystore/mnemonic 的 superController
class ImportContentController: BaseController {

    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    let keystoreVC = UIStoryboard.loadController(ImportKeystoreController.self, storyType: .wallet)
    let mnemonicVC = UIStoryboard.loadController(ImportMnemonicController.self, storyType: .wallet)
    let privateKeyVC = UIStoryboard.loadController(ImportPrivateKeyController.self, storyType: .wallet)

    lazy var listContainerView: JXSegmentedListContainerView = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    let dataSource = JXSegmentedNumberDataSource()


    override func viewDidLoad() {
        super.viewDidLoad()

        //addScanItem()
        makeSegmentUI()
    }

    override func languageChanged() {

        title = "Import Wallet".localized()

    }

    func addScanItem() {

        let btn = UIButton(type: .custom)
        btn.size = CGSize(width: 40, height: 40)
        btn.setImage(UIImage(named: "scan"), for: .normal)
        btn.addTarget(self, action:#selector(scanTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)

    }

    @objc func scanTapped() {
        
        guard UIApplication.isAllowCamera() else {
            SVProgressHUD.showInfo(withStatus: "Scanning QR code requires camera permissions".localized())
            return
        }

        let qr = QRScannerViewController()
        qr.scanType = segmentedView.selectedIndex == 0 ? .keystoreScan: .mnemonicScan
        self.push(controller: qr)
        qr.scanResult = { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                logInfo("扫描结果：\(result)")
                if self.segmentedView.selectedIndex == 0 {
                    self.keystoreVC.keystoreTextView.text = result
                }else {
                    self.mnemonicVC.menmonicTextView.text = result
                }
            }else {
                logDebug(error)
                
                if self.segmentedView.selectedIndex == 0 {
                    SVProgressHUD.showInfo(withStatus: "Please scan a valid Keystore".localized())
                }else {
                    SVProgressHUD.showInfo(withStatus: "Please scan a valid mnemonic".localized())
                }
            }
            qr.pop()
        }
    }


    func makeSegmentUI() {

        keystoreVC.parentVC = self
        mnemonicVC.parentVC = self
        privateKeyVC.parentVC = self

        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)
        dataSource.titles = ["Keystore", "Mnemonics","Privatekey"].map({ $0.localized() })
        dataSource.titleSelectedColor = .master
        dataSource.numbers = [0, 0,0]

        dataSource.reloadData(selectedIndex: 0)
        segmentedDataSource = dataSource
        view.backgroundColor = .white
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorColor =  UIColor.master
        indicator.indicatorWidth = screenWidth/3.0
        indicator.lineStyle = .lengthenOffset
        segmentedView.indicators = [indicator]
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        segmentedView.contentScrollView = listContainerView.scrollView
        
        view.addSubview(listContainerView)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.frame = CGRect(x: 0, y: 0, width: view.width, height: 50)
        listContainerView.frame = CGRect(x: 0,
                                         y: 50,
                                         width: view.width,
                                         height: screenBounds.height - 50 - iPHONE_NAVBAR_HEIGHT)
    }

}


extension ImportContentController: JXSegmentedViewDelegate {
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

extension ImportContentController: JXSegmentedListContainerViewDataSource {
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
            return keystoreVC
        case 1:
            return mnemonicVC
        default:
            return privateKeyVC
        }
    }
}
 
