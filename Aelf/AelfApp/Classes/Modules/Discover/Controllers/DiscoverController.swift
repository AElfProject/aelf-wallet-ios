//
//  DiscoverController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

//private let dappApplyURL = "http://aelfaelf1616.mikecrm.com/Z8EMGWN"

class DiscoverController: BaseTableViewController {
    
    var dappSource = [DiscoverDapp]()
    var listSource = [DiscoverListDapp]()
    
    let viewModel = DiscoverViewModel()
    
    var dappLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubViews()
        checkIsBackupMnemonic()
        bindDiscoverViewModel()
    }
    
    override func languageChanged() {
        
        navigationItem.title = "Discover".localized()
        headerView.searchButton.setTitle("Enter DApp Name".localized(), for: .normal)
        footerView.applyButton.setTitle("DApp listing application".localized(), for: .normal)
    }
    
    func bindDiscoverViewModel() {
        
        let input = DiscoverViewModel.Input(headerRefresh: headerRefreshTrigger)
        let output = viewModel.transform(input: input)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "" }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        emptyDataSetButtonTap.subscribe(onNext: { [weak self] () in
            self?.headerRefreshTrigger.onNext(())
        }).disposed(by: rx.disposeBag)
        
        output.discover.subscribe(onNext: { [weak self] discover in
            guard let self = self else { return }
            self.dappLink = discover.dappLink
            self.headerView.bannerSource = discover.banner ?? []
            self.dappSource = discover.dapp
//            self.listSource = discover.tool
            self.listSource = discover.list
            self.tableView.reloadData()
            self.updateLayouts()
            }, onError: { e in
                logDebug(e)
        }).disposed(by: rx.disposeBag)
        
        tableView.headRefreshControl.beginRefreshing()
        
    }
    
    func setupSubViews() {
        
        tableView.register(nibWithCellClass: DiscoverRecommendCell.self)
        tableView.register(nibWithCellClass: DappGameCell.self)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.footRefreshControl = nil
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        headerView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: screenWidth, height: DiscoverHeaderView.headerHeight()))
        }
        footerView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: screenWidth, height: 50))
            make.top.equalTo(tableView.contentSize.height)
        }
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
    }
    
    func updateLayouts() {
        footerView.snp.updateConstraints { (make) in
            make.top.equalTo(tableView.contentSize.height - 50)
        }
    }
    
    lazy var headerView: DiscoverHeaderView = {
        let header = DiscoverHeaderView.loadView(tapBanner: { [weak self] banner in
            self?.enterWebController(url: banner.url)
        })
        
        header.searchButton.hero.id = "SearchBar"
        header.searchButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.enterSearchController()
        }).disposed(by: rx.disposeBag)
        
        return header
    }()
    
    lazy var footerView: DiscoverFooterView = {
        let v = DiscoverFooterView.loadFromNib(named: DiscoverFooterView.className, bundle: nil) as! DiscoverFooterView
        v.tapDapply = {
            self.dappApplyTapped()
        }
        return v
    }()
    
    func enterSearchController() {
        let searchVC = UIStoryboard.loadController(DappSearchController.self, storyType: .discover)
        self.push(controller: searchVC)
    }
    
    func dappApplyTapped() {
        
        enterWebController(url: self.dappLink)
    }
    
    func enterWebController(url: String) {
        let vc = WebViewController(urlStr: url)
        push(controller: vc)
    }
    
    @objc func moreButtonTapped(_ button: UIButton) {
        
        self.performSegue(withIdentifier: DappListController.className, sender: nil)
    }
    
    override func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return false
    }
}


extension DiscoverController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if dappSource.isEmpty {
            footerView.isHidden = true
            return 0
        } else {
            footerView.isHidden = false
            return listSource.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return self.listSource[section - 1].data.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if dappSource.count > 4 {
                return 240
            }else if dappSource.count > 0 {
                return 130
            }else {
                return 0
            }
        default:
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let view = DiscoverSectionView.loadFromNib(named: DiscoverSectionView.className) as? DiscoverSectionView else {
            return nil
        }
        view.sectionButton.setTitle("More".localized(), for: .normal)
        
        if section == 0 {
            view.titleLabel.text = "Recommend".localized()
        } else {
            view.titleLabel.text = listSource[section - 1].categoryTitle
        }
        view.sectionButton.tag = section
        view.sectionButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withClass: DiscoverRecommendCell.self)
            cell.dataSource = self.dappSource
            cell.didSelectClosure = {
                self.didSelectDapp(name: $0.name, url: $0.url)
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withClass: DappGameCell.self)
            cell.item = listSource[indexPath.section - 1].data[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            logInfo("\(indexPath)")
        default:
            let item = listSource[indexPath.section - 1].data[indexPath.row]
            didSelectDapp(name: item.name, url: item.url)
        }
    }
    
}

extension DiscoverController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        logInfo("Header: \(headerView.frame)")
        logInfo("Footer: \(footerView.frame)")
    }
}

extension DiscoverController {
    
    func didSelectDapp(name: String, url: String) {
        
        let title = "Dapp visite info title".localizedFormat(name)
        let content = "Dapp visite info content".localizedFormat(name,name)
        DappConfirmView.show(title: title, content: content) { v in
            self.push(controller: DappWebController(item: DappItem(url: url, name: name)))
        }
    }
}
