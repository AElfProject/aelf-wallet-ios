//
//  NotificationsController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import JXSegmentedView

class NotificationsController: BaseController {
    
    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    let recordVC = TransationMessagesController()
    let systemVC = SystemMessagesController()
    
    let dataSource = JXSegmentedNumberDataSource()
    
    let viewModel = NotificationViewModel()
    let fetchAllUnReadTrigger = PublishSubject<Void>()
    let clearAllTransactionTrigger = PublishSubject<Void>()
    let clearAllSystemTrigger = PublishSubject<Void>()
    
    lazy var listContainerView = JXSegmentedListContainerView(dataSource: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        addRightNavItem()
        bindNotificationsViewModel()
    }
    
    func bindNotificationsViewModel() {
        
        let fetchUnRead = Observable.of(Observable.just(()), fetchAllUnReadTrigger).merge()
        let input = NotificationViewModel.Input(address: App.address,
                                                fetchAllUnRead: fetchUnRead,
                                                clearAllTransactionUnRead: clearAllTransactionTrigger,
                                                clearAllSystemUnRead: clearAllSystemTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.unReadModel.subscribe(onNext: { model in
            
            let numbers = [model.noticeUnreadCount ?? 0, model.messageUnreadCount ?? 0]
            self.dataSource.numbers = numbers
            self.dataSource.reloadData(selectedIndex: self.segmentedView.selectedIndex)
            self.segmentedView.reloadData()
            
        }).disposed(by: rx.disposeBag)
        
        // 清除交易/系统消息后，然后发信号拉最新总消息数据，触发上面 output.unReadModel 操作。
        output.clearAllTransactionMessageResult.subscribe(onNext: { _ in
            self.fetchAllUnReadTrigger.onNext(())
            self.recordVC.removeAllItems.onNext(()) // 清空
        }).disposed(by: rx.disposeBag)
        output.clearAllSystemMessageResult.subscribe(onNext: { _ in
            self.fetchAllUnReadTrigger.onNext(())
            self.systemVC.removeAllItems.onNext(()) //
        }).disposed(by: rx.disposeBag)
        
    }
    
    func makeUI() {
        
        recordVC.parentVC = self
        systemVC.parentVC = self
        
        title = "Notifications".localized()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.numberOffset = CGPoint.init(x: 4, y: -2)
        let titles = ["Transaction Notice", "System Messages"].map({ $0.localized() })
        dataSource.titles = titles
        dataSource.titleSelectedColor = .master
        dataSource.numbers = [0, 0]
        dataSource.numberStringFormatterClosure = {(number) -> String in
            if number > 999 {
                return "999+"
            }
            return "\(number)"
        }
        dataSource.reloadData(selectedIndex: 0)
        segmentedDataSource = dataSource
        view.backgroundColor = .white
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
    
    
    func addRightNavItem() {
        
        let btn = UIButton(type: .system)
        btn.setTitle("Clear".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        //        btn.isEnabled = false
        btn.setTitleColor(.master, for: .normal)
        btn.addTarget(self, action:#selector(self.clearAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: btn)
        
    }
    @objc func clearAction() {
        let selectedIndex = segmentedView.selectedIndex
        if selectedIndex == 0 {
            showClearAlert(title: "Clear all transaction notifications".localized()) {
                self.clearAllTransactionTrigger.onNext(())
            }
        } else {
            showClearAlert(title: "Clear all system messages".localized()) {
                self.clearAllSystemTrigger.onNext(())
            }
        }
    }
    
    func showClearAlert(title: String, closure:(() -> Void)?) {
        let alert = UIAlertController(title: "\(title)", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(.init(title: "Confirm".localized(), style: .destructive, handler: { a in
            closure?()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

extension NotificationsController: JXSegmentedViewDelegate {
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

extension NotificationsController: JXSegmentedListContainerViewDataSource {
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
            return recordVC
        default:
            return systemVC
        }
    }
}
