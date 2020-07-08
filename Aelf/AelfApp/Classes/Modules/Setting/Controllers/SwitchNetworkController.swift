//
//  SwitchNetworkController.swift
//  AelfApp
//
//  Created by yuguo on 2020/6/28.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper
import AVFoundation

class SwitchNetworkController: BaseTableViewController {

    var dataSource = [NetworkModel]()
    var isCustom: Bool = true
    var ipString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Switch Network".localized()
        
        guard let path = Bundle.main.path(forResource: "network", ofType: "json") else {
            SVProgressHUD.showError(withStatus: "暂无配置地址信息");
            return
        }
        
        do {
            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            var nets:[NetworkModel] = Mapper<NetworkModel>().mapArray(JSONString: jsonString)!
            let network: String = UserDefaults.standard.string(forKey: "kNetwork") ?? ""
            
            if network.length > 0 {
                for (index,var model) in nets.enumerated() {
                    if model.url == network {
                        isCustom = false
                        model.selected = true
                    }
                    nets[index] = model
                }
            }
            
            if isCustom {
                ipString = network
            }
            
            dataSource = nets
        } catch {
            print("json decode error")
        }
        
        self.markUI()
    }
    
    func markUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 45
        tableView.bounces = false
        tableView.register(nibWithCellClass: SwitchNetworkTableCell.self)
        tableView.register(nibWithCellClass: CustomNetworkCell.self)
        tableView.separatorColor = .clear
        tableView.reloadData()
    }
}

extension SwitchNetworkController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataSource.count
        } else {
            return 1
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let zeroView = UIView.init()
            let titleLabel = UILabel.init()
            titleLabel.textColor = UIColor(hexString: "101829")
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.text = "Mainnet address"
            zeroView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(20)
            }
            return zeroView
        } else {
            let oneView = UIView.init()
            let titleLabel = UILabel.init()
            titleLabel.textColor = UIColor(hexString: "101829")
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.text = "Custom address"
            oneView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(20)
            }
            return oneView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView.init()
            view.backgroundColor = .white
            let lineView = UIView.init()
            lineView.backgroundColor = UIColor(hexString: "E5E5E5")
            view.addSubview(lineView)
            lineView.snp_makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(1)
            }
            
            let confirmBtn = UIButton.init(type: .custom)
            confirmBtn.setTitle("Confirm".localized(), for: .normal)
            confirmBtn.setTitleColor(.white, for: .normal)
            confirmBtn.layer.cornerRadius = 22.5
            confirmBtn.layer.masksToBounds = true
            confirmBtn.backgroundColor = UIColor(hexString: "410F8A")
            
//            earchView.cancelButton.rx.tap.subscribe(onNext: { [weak self] _ in
//                searchView.searchField.resignFirstResponder()
//                self?.pop()
//            }).disposed(by: rx.disposeBag)
            
//            confirmBtn.addTarget(self, action:#selector(comfirmClick(sender:)), for:.touchUpInside)
            confirmBtn.rx.tap.subscribe(onNext: { [weak self] _ in
                
                if self!.isCustom == true {
                    if (self?.ipString.length)! <= 0 {
                        SVProgressHUD.showInfo(withStatus:"请输入自定义地址")
                        return
                    }
                    if (self?.ipString.hasPrefix("http"))! {
                        if Validate.URL(self!.ipString).isRight {
                            UserDefaults.standard.setValue(self!.ipString, forKey: "kNetwork")
                            UserDefaults.standard.synchronize()
                            self?.navigationController?.popViewController()
                        } else {
                            SVProgressHUD.showInfo(withStatus:"输入错误，请重新输入")
                        }
                    } else {
                        SVProgressHUD.showInfo(withStatus:"请输入以http开头的地址")
                        return
                    }
                } else {
                    for model in self!.dataSource {
                        if model.selected == true {
                            UserDefaults.standard.setValue(model.url!, forKey: "kNetwork")
                            UserDefaults.standard.synchronize()
                            self?.navigationController?.popViewController()
                            break;
                        }
                    }
                }
                
            }).disposed(by: rx.disposeBag)
            view.addSubview(confirmBtn)
            confirmBtn.snp_makeConstraints { (make) in
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
                make.bottom.equalToSuperview().offset(0)
                make.height.equalTo(45)
            }
            
            return view
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.5 : 90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let item = dataSource[indexPath.row]
            let cell = tableView.dequeueReusableCell(withClass: SwitchNetworkTableCell.self)
            cell.item = item
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: CustomNetworkCell.self)
            cell.isChoose = isCustom
            cell.customTF.text = self.ipString
            cell.confirmAction = {(ipStr:String) -> (Void) in
                self.ipString = ipStr
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            for (index,var model) in dataSource.enumerated() {
                model.selected = index == indexPath.row ? true : false
                dataSource[index] = model
            }
            isCustom = false
        } else {
            for (index,var model) in dataSource.enumerated() {
                model.selected = false
                dataSource[index] = model
            }
            isCustom = true
        }
        tableView.reloadData()
    }
}

enum Validate {
    case email(_: String)
    case phoneNum(_: String)
    case carNum(_: String)
    case username(_: String)
    case password(_: String)
    case nickname(_: String)

    case URL(_: String)
    case IP(_: String)


    var isRight: Bool {
        var predicateStr:String!
        var currObject:String!
        switch self {
        case let .email(str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case let .phoneNum(str):
            predicateStr = "^((13[0-9])|(15[^4,\\D]) |(17[0,0-9])|(18[0,0-9]))\\d{8}$"
            currObject = str
        case let .carNum(str):
            predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
            currObject = str
        case let .username(str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case let .password(str):
            predicateStr = "^[a-zA-Z0-9]{6,20}+$"
            currObject = str
        case let .nickname(str):
            predicateStr = "^[\\u4e00-\\u9fa5]{4,8}$"
            currObject = str
        case let .URL(str):
            predicateStr = "^(http?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$"
            currObject = str
        case let .IP(str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        }

        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }
}
