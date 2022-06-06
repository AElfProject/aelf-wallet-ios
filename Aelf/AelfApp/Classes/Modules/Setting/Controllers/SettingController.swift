//
//  SettingController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import RxDataSources

struct SettingItem {
    var title:String
    var point:NSInteger
    var className:String
}

class SettingController: BaseController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let settingViewModel = SettingViewModel()
    var dataSource = [SettingItem]()
    var unReadCount = 0
    
    let updateUserInfoTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        checkIsBackupMnemonic()
        bindSettingViewModel()
        
        updateUI(info: App.userInfo)
    }
    
    func makeUI() {
        
        tableView.register(nibWithCellClass: SettingCell.self)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        
        avatarImageView.cornerRadius = avatarImageView.height/2
        avatarImageView.borderWidth = 1
        avatarImageView.borderColor = UIColor.white
        
        avatarImageView.hero.id = "AvatarID"
        nameLabel.hero.id = "UserNameID"
    }
    
    func updateUI(info: IdentityInfo?) {
        guard let info = info else { return }
        
        self.nameLabel.text = info.name ?? (AElfWallet.walletName ?? "-")
        if let url = URL(string: info.img ?? "") {
            self.avatarImageView.setImage(with: url, placeholder: UIImage(named: "default_avatar"))
        }else {
            self.avatarImageView.image = UIImage(named: "default_avatar")
        }
    }
    
    func bindSettingViewModel() {
        
        let input = SettingViewModel.Input(address: App.address,
                                           headerRefresh: headerRefreshTrigger,
                                           updateUserInfo: updateUserInfoTrigger)
        let output = settingViewModel.transform(input: input)
        
        output.userInfo.subscribe(onNext: { info in
            self.updateUI(info: info)
        }).disposed(by: rx.disposeBag)
        
        output.unRead.subscribe(onNext: { model in
            if model.unreadCount != nil {
                self.unReadCount = model.unreadCount ?? 0
                self.tableView.reloadData()
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func languageChanged() {
        
        navigationItem.title = "My".localized()
        
        setupDataSource()
        
    }
    func setupDataSource() {
        
        dataSource.removeAll()
        
        let items = [
        SettingItem(title:"Identity Management".localized(),point: 0,className:MyAccountController.className),
        SettingItem(title:"Address Book".localized(),point:0,className:AddressBookViewController.className),
        SettingItem(title:"Messages".localized(),point:0,className:NotificationsController.className),
        SettingItem(title:"Settings".localized(),point: 0,className:SettingManagerController.className),
        SettingItem(title:"Help_title".localized(),point: 0,className:HelpManagerController.className),
        SettingItem(title:"User Agreement".localized(),point: 0,className:WebViewController.className),
        SettingItem(title:"About Us".localized(),point: 0,className:AboutUsController.className)]
        
        dataSource = items
        
        #if DEBUG
        dataSource.append(SettingItem(title:"测试页面".localized(),point: 0,className:TestPlanController.className))
        #endif
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        headerRefreshTrigger.onNext(())
        updateUserInfoTrigger.onNext(())
    }
    
    override func configBaseInfo() {
        
    }
    
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        
    }
    
}

extension SettingController:UITableViewDataSource,UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataSource[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withClass: SettingCell.self)
        cell.settingLabel.text = item.title
        
        if indexPath.row == 2 {
            cell.pointLabel.text = self.unReadCount.string
            cell.pointLabel.isHidden = self.unReadCount == 0
        } else {
            cell.pointLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = dataSource[indexPath.row]
        
        if item.className == WebViewController.className {
            push(controller: WebViewController.termsOfService())
            return
        }
        if item.className == TestPlanController.className {
            push(controller: TestPlanController())
            return
        }
        
        let languageVC = UIStoryboard.loadStoryClass(className: item.className, storyType: .setting)
        push(controller: languageVC)
    }
    
}
