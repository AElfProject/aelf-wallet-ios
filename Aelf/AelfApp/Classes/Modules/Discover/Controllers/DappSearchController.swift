//
//  DappSearchController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/12.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class DappSearchController: BaseController {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var items = [DiscoverDapp]()
    
    private let viewModel = DappSearchViewModel()
    
    var isShowHot = true // 默认显示热门搜索
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.hero.id = "SearchBar"
        addEmptyBackItem()
        
        setupTableView()
        bindSearchViewModel()
    }
    
    override func configBaseInfo() {
        
        title = "Search".localized()
        
    }
    
    func setupTableView() {
        
        tableView.register(nibWithCellClass: DappGameCell.self)
        tableView.register(nibWithCellClass: DappSearchHotCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.footRefreshControl = nil
        
        headerView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: screenWidth, height: 45))
        }
    }
    
    lazy var headerView: DappSearchHeaderView = {
        let v = DappSearchHeaderView.loadFromNib(named: DappSearchHeaderView.className) as! DappSearchHeaderView
        return v
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchField.becomeFirstResponder()
    }
    
    func bindSearchViewModel() {
        
        let input = DappSearchViewModel.Input(searchText: searchField.asDriver(),
                                              items: self.items,
                                              headerRefresh: headerRefresh())
        let output = viewModel.transform(input: input)
        
        output.items.subscribe(onNext: { [weak self] items in
            guard let self = self else { return }
            
            self.isShowHot = self.searchField.isEmpty
            self.headerView.isHidden = items.isEmpty
            self.headerView.titleLabel.text = "\(items == self.items ? "Popular Searchs":"Results")".localized()
            self.items = items
            self.tableView.reloadData()
            
        }).disposed(by: rx.disposeBag)
    }
    
    
    func didSelectDapp(item: DiscoverDapp) {
        
        let title = "Dapp visite info title".localizedFormat(item.name)
        let content = "Dapp visite info content".localizedFormat(item.name,item.name)
        DappConfirmView.show(title: title, content: content) { v in
            self.push(controller: DappWebController(item: DappItem(url: item.url, name: item.name)))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        searchField.resignFirstResponder()
        pop()
    }
    
}


extension DappSearchController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isShowHot ? 50:80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        if isShowHot {
            let cell = tableView.dequeueReusableCell(withClass: DappSearchHotCell.self)
            cell.updateContent(idx: indexPath.row, name: item.name)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: DappGameCell.self)
            cell.item = item
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items[indexPath.row]
        didSelectDapp(item: item)
        
    }
    
}

extension Array where Element == DiscoverDapp {
    
    static func == (lhs: [Element], rhs: [Element]) -> Bool {
        return lhs.map({ $0.name }) == rhs.map({ $0.name })
    }
}
