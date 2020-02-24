//
//  AssetController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import RxDataSources
import Schedule
import MarqueeLabel
import KafkaRefresh


/// 资产首页
class AssetController: BaseTableViewController {
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var noticeHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noticeLabel: MarqueeLabel!
    
    let viewModel = AssetViewModel()
    
    let unReadViewModel = MessageUnReadViewModel()
    let badgeLabel = UILabel(frame: CGRect(x: 23, y: 5, width: 16, height: 16))
    let walletAddress = BehaviorRelay<String>(value: App.address)
    let chainIDChanged = BehaviorRelay<Void>(value: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationItem()
        addNavigationTitleView()
        
        makeUI()
        checkIsBackupMnemonic()
        bindAssetViewModel()
       
    }
    
    func makeUI() {
        
        let padding: CGFloat = 25/2  // addButton.height = 25
        tableView.frame = CGRect(x: 0,
                                 y: headerView.height + padding,
                                 width: screenWidth,
                                 height: screenHeight - headerView.height - iPHONE_NAVBAR_HEIGHT - iPHONE_TABBAR_HEIGHT - padding)
        
        view.sendSubviewToBack(tableView)
        
        tableView.register(nibWithCellClass: AssetCell.self)
        tableView.rowHeight = 80
        tableView.footRefreshControl = nil
        
        updateAddressLabel(chainID: App.chainID)

        self.noticeLabel.text = ""
        self.noticeHeight.constant = 35
        
    }
    
    func updateAddressLabel(chainID: String) {
        if App.assetMode == .token {
            self.addressLabel.text = App.address.elfAddress(Define.defaultChainID)
        } else {
            self.addressLabel.text = App.address.elfAddress(chainID)
        }
    }
    
    func addNavigationTitleView() {
        
        navigationItem.titleView = titleView
    }
    
    lazy var titleView: ChainTitleView = {
        let view = ChainTitleView()
        
        view.tapClosure = {
            self.showCrossChains()
        }
        return view
    }()
    
    func addNavigationItem() {
        
        let bgView = UIView()
        bgView.isUserInteractionEnabled = true
        bgView.size = CGSize(width: 40, height: 40)
        
        let btn = UIButton(type: .custom)
        btn.size = CGSize(width: 40, height: 40)
        btn.setImage(UIImage(named: "bell"), for: .normal)
        btn.addTarget(self, action:#selector(notificationTapped), for: .touchUpInside)
        bgView.addSubview(btn)
        
        badgeLabel.backgroundColor = .red
        badgeLabel.font = .systemFont(ofSize: 10, weight: .regular)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = badgeLabel.height/2
        badgeLabel.layer.masksToBounds = true
        badgeLabel.isHidden = true
        
        bgView.addSubview(badgeLabel)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bgView)
        
        
        let rightItem = UIBarButtonItem(image: UIImage(named: "order"), style: .done, target: self, action: #selector(enterUnConfirmController))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    
    // Bind View Model
    func bindAssetViewModel() {
        
        let input = AssetViewModel.Input(address: walletAddress,chainIDChanged: chainIDChanged, headerRefresh: headerRefreshTrigger)
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        emptyDataSetButtonTap.subscribe(onNext: { [weak self] () in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)
        
        output.total.bind(to: moneyLabel.rx.attributedText).disposed(by: rx.disposeBag)
        
        // 绑定数据源到 tableView
        output.items.bind(to: tableView.rx.items(cellIdentifier: AssetCell.className,
                                                 cellType: AssetCell.self))
        { (_, element, cell) in
            cell.item = element
        }
        .disposed(by: rx.disposeBag)
        
        //点击点击事件
        Observable.zip(tableView.rx.itemSelected,tableView.rx.modelSelected(AssetItem.self))
            .subscribe(onNext: { [weak self] (indexPath,item) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.enterDetailVC(item)
                
            }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.currencyDidChange).subscribe(onNext: { [weak self] notify in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.updateAssetData).subscribe(onNext: { [weak self] notify in
            guard let self = self else { return }
            self.walletAddress <= App.address
            self.updateAddressLabel(chainID: App.chainID)
        }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(NotificationName.assetDisplayModeChange).subscribe(onNext: { [weak self] notify in
            if let mode = notify.object as? AssetDisplayMode {
                self?.updateAddressLabel(chainID: App.chainID)
                self?.titleView.displayMode(mode)
                self?.headerRefreshTrigger.onNext(())
            }
        }).disposed(by: rx.disposeBag)
        
        tableView.headRefreshControl.beginRefreshing()
    }
    
    /// 复制地址
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = self.addressLabel.text
        SVProgressHUD.showSuccess(withStatus: "Copied".localized())
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        let vc = UIStoryboard.loadController(AssetManagerController.self, storyType: .assets)
        push(controller: vc)
    }
    
    override func languageChanged() {
        
        navigationItem.title = "Assets".localized()
        titleView.displayMode(App.assetMode)
        titleLabel.text = "Total Assets in Current Account1".localized()
        
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// MARK: View Appear

extension AssetController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNoticeAndBadgeView()
        asyncMainDelay(duration: 0.2) {
            self.checkUnConfirmTransactions()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.master, size: CGSize(width: 10, height: 10)),for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
}

// MARK: 事件处理
extension AssetController {
    
    @objc func enterUnConfirmController() {
        let vc = UnConfirmTransactionController()
        self.navigationController?.pushViewController(vc)
    }
    
    func requestLinkTransaction(fromTxID: String, toTxID: String) -> Observable<VResult> {
        return  assetProvider.requestData(.linkTransactionID(fromTxID: fromTxID, toTxID: toTxID))
    }
    
    func showCrossChains(type: CrossChainType = .present, symbol: String? = nil) {
        
        let vc = CrossChainsController(type: type, symbol: symbol) { [weak self] (item) in
            guard let self = self else { return }
            let value = item.chainID
            App.chainID = value
            self.updateAddressLabel(chainID: value)
            self.titleView.setTitle(value)
            self.chainIDChanged.accept(())
        }
        
        if type == .present {
            let nav = BaseNavigationController(rootViewController: vc)
            
            if #available(iOS 13, *) {
                nav.hero.isEnabled = false // fix present bug in iOS 13
            } else {
                nav.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .down), dismissing: .slide(direction: .up))
            }
            present(nav, animated: true, completion: nil)
        }else {
            push(controller: vc)
        }
    }
    
    @objc func notificationTapped() {
        
        let notificationVC = UIStoryboard.loadStoryClass(className: NotificationsController.className, storyType: .setting)
        push(controller: notificationVC)
    }
    
    
    func updateNoticeAndBadgeView() {
        
        // 通知公告
        viewModel.noticeData().subscribe(onNext: { notice in
            let list = notice.list ?? []
            let text = list.map({ $0.desc ?? "" }).joined(separator: " ")
            self.noticeLabel.text = text
            //            self.noticeHeight.constant = 35
        }, onError: { e in
            //            self.noticeHeight.constant = 0
        }).disposed(by: rx.disposeBag)
        
        viewModel.requestUnRead(address: App.address).map({ $0.unreadCount ?? 0 }).subscribe(onNext: { [weak self] count in
            guard let self = self else { return }
            self.badgeLabel.isHidden = count == 0
            if count > 99 {
                self.badgeLabel.font = .systemFont(ofSize: 7, weight: .regular)
                self.badgeLabel.text = "99+"
            }else {
                self.badgeLabel.font = .systemFont(ofSize: 10, weight: .regular)
                self.badgeLabel.text = "\(count)"
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    
    func enterDetailVC(_ item: AssetItem) {
        if App.assetMode == .token {
            self.showCrossChains(type: .push, symbol: item.symbol)
        } else {
            let vc = UIStoryboard.loadController(AssetDetailController.self, storyType: .assets)
            vc.item = AssetDetailItem(symbol: item.symbol,
                                      chainID: item.chainID ,
                                      contractAddress: item.contractAddress ,
                                      price: item.rate?.price.double() ?? 0,
                                      logo: item.logo)
            self.push(controller: vc)
        }
    }
    
    func checkUnConfirmTransactions() {
//        return
        if !isCanShowOtherMessageViews || !SecurityWarnView.isCanShow() { return } // 如果 SecurityWarnView 的视图在显示，则终止
        viewModel.requestUnconfirmTransaction(address: App.address).subscribe(onNext: { [weak self] result in
            
            if result.list.count > 0 {
                let title = "you are %@ pending transaction to be confirmed".localizedFormat(result.list.count.string)
                SecurityWarnView.show(title: title,
                                      centerTitle: true,
                                      body: nil,
                                      interactive: true,
                                      confirmTitle: "Confirm".localized()) {
                                        self?.enterUnConfirmController()
                }
            }
            
            }, onError: { e in
                logError("请求失败：\(e)")
        }).disposed(by: rx.disposeBag)
    }
}
