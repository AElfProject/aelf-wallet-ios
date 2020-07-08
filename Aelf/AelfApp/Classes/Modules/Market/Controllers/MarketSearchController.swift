//
//  MarketSearchController.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import ObjectMapper
import Moya_ObjectMapper

class MarketSearchController: BaseTableViewController {

    let viewModel = MarketSearchViewModel()
//    var output = MarketSearchViewModel.Output.init()
    let fileName: String = "coinList.txt"
    let loadCoinDataTrigger = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }

    func bindViewModel() {

        let input = MarketSearchViewModel.Input(searchText: searchView.searchField.asDriver(),
                                                loadData: loadDataTrigger,
                                                loadCoinData: loadCoinDataTrigger)
        let output = viewModel.transform(input: input)
        
        let saveTime: Int = UserDefaults.standard.integer(forKey: "kSearchTime")
        if saveTime > 0 {
            //保存了时间戳 延迟一天请求接口
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            if timeStamp > (saveTime + 3600 * 24) {
                self.loadCoinDataTrigger.onNext(())
            } else {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                    let fileURL = dir.appendingPathComponent(fileName)
                    do{
                        let jsonString = try String(contentsOf: fileURL, encoding: .utf8)
                        //为了代入方法解析,拼接成字典
                        let str = "{\"list\":" + jsonString + "}"
                        let list = MarketSearchModel(JSONString: str)!.list
                        output.coinItems = BehaviorRelay<[MarketCoinListModel]>(value: list)
                        print(jsonString)
                    }catch{
                        print("cant read...")
                    }
                }
            }
        } else {
            //请求接口
            self.loadCoinDataTrigger.onNext(())
        }
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
//        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
//        viewModel.footerLoading.asObservable().bind(to: isFooterLoading).disposed(by: rx.disposeBag)
        viewModel.parseError.map{ $0.msg ?? "Empty Data".localized() }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)

        output.items.bind(to: tableView.rx.items(cellIdentifier: MarketSearchCell.className,
                                                 cellType: MarketSearchCell.self)) { idx,item,cell in
            cell.item = item
        }.disposed(by: rx.disposeBag)
        
        Observable.zip(tableView.rx.itemSelected,
                       tableView.rx.modelSelected(MarketCoinModel.self))
            .subscribe(onNext: { [weak self] (index,item) in
                self?.tableView.deselectRow(at: index, animated: true)
                self?.enterDetailVC(item: item)
            }).disposed(by: rx.disposeBag)

        emptyDataSetDescription.accept("Enter Token Name".localized())

        output.items.subscribe(onNext: { [weak self] items in
            self?.emptyDataSetDescription.accept("Empty Data".localized())
        }).disposed(by: rx.disposeBag)

//        tableView.headRefreshControl.beginRefreshing()
        //触发币种列表接口
        
        self.loadDataTrigger.onNext(())
//        self?.headerRefreshTrigger.onNext(())
        
        output.coinItems.subscribe(onNext: { [weak self] result in
            // 返回结果不影响进入首页
            print("result = \(result)")
            if result.count == 0 {
                return
            }
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            let filePath = url.path
            let fileManager = FileManager.default
            let isExists = fileManager.fileExists(atPath: filePath!)
            if isExists {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let removeFile = dir.appendingPathComponent(self!.fileName)
                    let fileManager = FileManager.default
                    do{
                        try fileManager.removeItem(at: removeFile)
                    }catch{
                        print("cant remove file...")
                    }
                }
            }
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                let fileURL = dir.appendingPathComponent(self!.fileName)
                do {
                    try output.coinItems.value.toJSONString()?.write(to: fileURL, atomically: false, encoding: .utf8)
                    //删除并保存成功 更新时间戳
                    let timeStamp = Int(NSDate().timeIntervalSince1970)
                    UserDefaults.standard.set(timeStamp, forKey: "kSearchTime")
                    UserDefaults.standard.synchronize()
                }catch{
                    print("cant write...")
                }
            }
        }).disposed(by: rx.disposeBag)
    }

    func enterDetailVC(item: MarketCoinModel) {

        let detailVC = UIStoryboard.loadController(MarketDetailController.self, storyType: .market)
        detailVC.model = item
        push(controller: detailVC)
    }

    func makeUI() {

        navigationItem.title = "Market".localized()

        view.addSubview(searchView)
        view.addSubview(topView)

        searchView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(50)
        }

        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.height.equalTo(35)
        }

        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }

        tableView.register(nibWithCellClass: MarketSearchCell.self)
        tableView.height = 55
    }

    lazy var searchView: SearchBarView = {
        let searchView = SearchBarView.loadFromNib(named: SearchBarView.className) as! SearchBarView
        searchView.cancelButton.rx.tap.subscribe(onNext: { [weak self] _ in
            searchView.searchField.resignFirstResponder()
            self?.pop()
        }).disposed(by: rx.disposeBag)
        return searchView
    }()

    lazy var topView: MarketSearchTopView = {
        let view = MarketSearchTopView.loadFromNib(named: MarketSearchTopView.className) as! MarketSearchTopView
        return view
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.searchField.becomeFirstResponder()
    }

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
}

extension String: FilePathProtocol {
    func stringPath() -> String {
        return self
    }
    func filePathUrl() -> URL {
        return URL(fileURLWithPath: self)
    }
}
