//
//  BaseStaticTableController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/24.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class BaseStaticTableController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        logDebug("进入：\(self.className)")
        setTitleAttributes()
        
        // 监听语言改变通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: NSNotification.language,
                                               object: nil)
        languageChanged()
    }

    //语言改变后回调重新设置
    @objc public func languageChanged() {}

    deinit {
        NotificationCenter.default.removeObserver(self)
        logDebug("释放：\(String(describing: Mirror(reflecting: self).subjectType))\n")
    }
}
