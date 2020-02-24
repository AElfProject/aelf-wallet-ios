//
//  TestPlanController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/9.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

struct TestItem {
    
    let title: String
    let closure: (() -> Void)?
}

// `Debug` 下的测试页面。
class TestPlanController: BaseController {
    
    var dataSource = [TestItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "测试页面"
        view.addSubview(tableView)
        
        addBarButtonItem()
        loadTestData()
        
    }
    
    func loadTestData() {
        
        
        dataSource.append(TestItem(title: "创建/导入钱包👛", closure: {
            let vc = UIStoryboard.loadController(BaseNavigationController.self, storyType: .wallet)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }))
        
        dataSource.append(TestItem(title: "多语言选择", closure: {
            let vc = UIStoryboard.loadController(LanguageController.self, storyType: .setting)
            self.push(controller: vc)
        }))
        
        dataSource.append(TestItem(title: "确认密码弹框", closure: {
            InputAlertView.show(inputType: .confirmPassword) { v in
                if v.pwdField.text?.count ?? 0 > 5 {
                    v.hide()
                } else {
                    v.showHint()
                    SVProgressHUD.showInfo(withStatus: "长度不足5位")
                }
            }
        }))
        
        dataSource.append(TestItem(title: "安全提示弹框", closure: {
            SecurityWarnView.show(title: "Security Warning".localized(),
                                  body: "You have not backed up".localized(),
                                  confirmTitle: "Backup Now".localized()) {
                                    
                                    logInfo("Done ...")
            }
        }))
        
        dataSource.append(TestItem(title: "地址排序弹框", closure: {
            AssetSortView.show(selectedResult: { (index) in
                logDebug(index)
            })
        }))
        
        dataSource.append(TestItem(title: "选择Chain弹框", closure: {
            let vc = CrossChainsController(type: arc4random() % 2 == 0 ? .push:.present,closure: nil)
            self.present(vc, animated: true, completion: nil)
        }))
        
        dataSource.append(.init(title: "分享内容弹框", closure: {
            ShareAlertView.show(type: .wechat,selectedResult: { type in
                logInfo(type.link)
            })
        }))
        
        dataSource.append(TestItem(title: "跨链检测弹框", closure: {
            TransferDetectedView.show(fromChain: "AAA", toChain: "BBB", confirmClosure: {
                logInfo("点击")
            })
        }))
        
        dataSource.append(TestItem(title: ">>> Dapp 拦截测试", closure: {
            let vc = DappWebController(item: DappItem(url: "http://0.0.0.0:9527/dapp.html",name: "Test"))
            //            let vc = DappWebController(item: DappItem(url: "http://0.0.0.0:9527/dapp.html",name: "Test"))
            
            self.navigationController?.pushViewController(vc)
        }))
        
        dataSource.append(TestItem(title: ">>> Dapp 转账", closure: {
            //
            let vc = DappWebController(item: DappItem(url: "http://0.0.0.0:9527/transfer.html",name: "Test Transfer"))
            //            let vc = DappWebController(item: DappItem(url: "http://54.249.197.246:9876/transfer.html",name: "Test Transfer"))
            self.navigationController?.pushViewController(vc)
        }))
        
        dataSource.append(TestItem(title: ">>> Dapp 投票", closure: {
            let vc = DappWebController(item: DappItem(url: "http://0.0.0.0:9527/vote.html",name: "Test Vote"))
            self.navigationController?.pushViewController(vc)
        }))
        
        dataSource.append(TestItem(title: "Dapp Login 弹框", closure: {
            DappLoginView.show(content: "现在dapp默认以POST MESSAGE方式进行通信。如你们后续有需要，我可以加上选择通信方式的按钮。选择SOCKE.IO方式可以通过aelf-command的子命令dapp-server启动的服务进行通信。") { (v) in
                logInfo("xxx")
            }
        }))
        
        dataSource.append(TestItem(title: "Dapp Sign 弹框", closure: {
            let title = "现在dapp默认以POST MESSAGE方式进行通信。如你们后续有需要，我可以加上选择通信方式的按钮。选择SOCKE.IO方式可以通过aelf-command的子命令dapp-server启动的服务进行通信。"
            DappSignConfirmView.show(content: title, confirmClosure: { view in
                let pwd = view.pwdField.text ?? ""
                if let _ = AElfWallet.getPrivateKey(pwd: pwd) {
                    view.pwdField.resignFirstResponder()
                    view.hide()
                    logInfo("密码输入正确：\(pwd)")
                } else {
                    view.showHint()
                    SVProgressHUD.showError(withStatus: "Password Error".localized())
                }
            }) {
                logInfo("User cancelled".localized())
            }
        }))
        
        dataSource.append(TestItem(title: "生物识别支付验证", closure: {

            SecurityVerifyManager.verifyPaymentPassword(completion: { (pwd) in
                logInfo("支付密码：\(pwd ?? "")")
            })
        }))
        
        dataSource.append(TestItem(title: "拷贝地址：ELF_yAHruQaJ5XvJ6n7ghXDex93YhssrtorQeGB2MApp16SLinv8H_AELF", closure: {
            UIPasteboard.general.string = "ELF_yAHruQaJ5XvJ6n7ghXDex93YhssrtorQeGB2MApp16SLinv8H_AELF"
            SVProgressHUD.showSuccess(withStatus: "拷了。")
        }))
        
        
        tableView.reloadData()
        
    }
    
    func addBarButtonItem() {
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "DoKit",
        //                                                            style: .plain,
        //                                                            target: self,
        //                                                            action: #selector(showDoKit))
    }
    
    @objc func showDoKit() {
        
        
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: self.view.bounds)
        table.register(cellWithClass: BaseTableCell.self)
        table.tableFooterView = UIView()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 45
        return table
    }()
    
}

extension TestPlanController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: BaseTableCell.self)
        let item = dataSource[indexPath.row]
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = dataSource[indexPath.row]
        item.closure?()
    }
    
}
