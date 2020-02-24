//
//  AddressBookViewController.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/18.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import MYTableViewIndex

enum AddressBookParentType {
    case transfer
    case manager
}
class AddressBookViewController: BaseController  {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!

    typealias completeBlock = (String) -> Void
    var callBack: completeBlock?
    var parentType:AddressBookParentType = .manager

    var viewModel = AddressBookViewModel()
    let isHeaderLoading = BehaviorRelay(value: false)
    var output:AddressBookViewModel.Output = AddressBookViewModel.Output()
    let keywordTriger = BehaviorRelay<String>(value: "")
    let delTriger = BehaviorRelay<IndexPath>(value: IndexPath.init(row: 0, section: -1))

    var sectionIndexTitles = [String]()
    private var tableViewIndexController: TableViewIndexController!
    var indexDataSource  = CollationIndexDataSource.init(hasSearchIndex: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Address Book".localized()

        addRightNavItem()
        makeUI()
        bindBookViewModel()
    }

    func makeUI() {

        searchField.delegate = self
        searchField.placeholder = "Please search by keyword".localized()
        searchField.returnKeyType = .search
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource =  self
        tableView.emptyDataSetDelegate = self
        tableView.register(nibWithCellClass: AddressBookCell.self)
        tableView.rowHeight = 65

        tableViewIndexController = TableViewIndexController(scrollView: tableView)
        tableViewIndexController.tableViewIndex.delegate = self

        asyncMainDelay {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerRefreshTrigger.onNext(())
        asyncMainDelay {
            self.tableView.reloadData()
        }
        
    }

    func bindBookViewModel() {

        let input:AddressBookViewModel.Input = AddressBookViewModel.Input(keyword: keywordTriger,
                                                                          delIndexPath: delTriger,
                                                                          headerRefresh: headerRefresh())
        
        output = viewModel.transform(input: input)
        output.sections.subscribe(onNext: { [weak self](items) in

            self?.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
        
        output.indexDataSource.subscribe(onNext: { [weak self](indexs) in
            self?.sectionIndexTitles = indexs
            self?.indexDataSource = CollationIndexDataSource(hasSearchIndex: false, indexs: indexs)
            self?.tableViewIndexController.tableViewIndex.dataSource = self?.indexDataSource
            self?.tableViewIndexController.tableViewIndex.reloadData()
        }).disposed(by: rx.disposeBag)
        
        tableView.bindHeadRefreshHandler({ [weak self] in
            self?.headerRefreshTrigger.onNext(())
            }, themeColor: UIColor.master, refreshStyle: .replicatorCircle)
        
        viewModel.loading.asObservable().bind(to: isLoading).disposed(by: rx.disposeBag)
        viewModel.headerLoading.asObservable().bind(to: isHeaderLoading).disposed(by: rx.disposeBag)
        isHeaderLoading.bind(to: tableView.headRefreshControl.rx.isAnimating).disposed(by: rx.disposeBag)
        
        viewModel.parseError.subscribe(onNext: { [weak self](err) in
            logDebug(err)
            self?.isHeaderLoading.accept(false)
        }).disposed(by: rx.disposeBag)
        tableView.footRefreshControl = nil
        viewModel.parseError.map{
            $0.msg ?? "Temporary no cotacts".localized()
        }.bind(to: emptyDataSetDescription).disposed(by: rx.disposeBag)
        
        let updateEmptyDataSet = Observable.of(isLoading.mapToVoid().asObservable(),
                                               emptyDataSetImageTintColor.mapToVoid(),
                                               emptyDataButonHidden.mapToVoid(),
                                               emptyDataSetDescription.mapToVoid()).merge()
        updateEmptyDataSet.subscribe(onNext: { [weak self] () in
            self?.tableView.reloadEmptyDataSet()
        }).disposed(by: rx.disposeBag)

    }

    func addRightNavItem() {
        
        let image = UIImage(named: "address_add")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(self.addNewAddress))
    }
    
    @objc func addNewAddress() {
        enterAddressController(item: nil)
    }

    func enterAddressController(item: EditContactItem?) {
        let addVC = UIStoryboard.loadController(AddAddressController.self, storyType: .setting)
        addVC.editItem = item
        push(controller: addVC)
    }

    func callBackBlock(block: @escaping completeBlock) {
        callBack = block
    }
}

extension AddressBookViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.keywordTriger.accept((textField.text ?? ""))
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
        if text == "" {
            self.keywordTriger.accept("")
            self.isHeaderLoading.accept(true)
        }
        return true
    }
}

extension AddressBookViewController: UITableViewDelegate,UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return output.sections.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.sections.value[section].count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return output.sections.value[section].first?.fc
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  let cell  = tableView.dequeueReusableCell(withClass: AddressBookCell.self,)
        let cell = tableView.dequeueReusableCell(withClass: AddressBookCell.self, for: indexPath)
        cell.setupWithItem(output.sections.value[indexPath.section][indexPath.row])
        cell.delegate = self
        cell.editButtonArray = [UIButton(title:"tap_delete".localized())]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return NSNotFound
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addressBookItem =  output.sections.value[indexPath.section][indexPath.row]
        if parentType == .transfer {
            let address = addressBookItem.address ?? ""
            self.callBack?(address)
            self.navigationController?.popViewController(animated: true)
        }else {
            let item = EditContactItem(name: addressBookItem.name ?? "",
                                       note: addressBookItem.note,
                                       address: addressBookItem.address ?? "")
            enterAddressController(item: item)
        }
    }
}

extension AddressBookViewController: YFTableViewCellDelegate, TableViewIndexDelegate {

    func tableView(_ tableView: UITableView, didClickedEditButtonAt buttonIndex: Int, At IndexPath: IndexPath) {
        logDebug("tableview:\(tableView)\nbuttonIndex:\(buttonIndex)\nIndexPath:\(IndexPath)")

        SVProgressHUD.show()
        self.delTriger.accept(IndexPath)

        asyncMainDelay {
            SVProgressHUD.dismiss()
        }
    }

    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {

        let originalOffset = tableView.contentOffset
        let indexTitle = self.sectionIndexTitles[index]
        for i in 0..<output.sections.value.count {
            if output.sections.value[i].first?.fc == indexTitle {
                let sectionIndex = i
                let rowCount = tableView.numberOfRows(inSection: sectionIndex)
                let indexPath = IndexPath(row: rowCount > 0 ? 0 : NSNotFound, section: sectionIndex)
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                return tableView.contentOffset != originalOffset
            }
        }
        return true
    }
}
