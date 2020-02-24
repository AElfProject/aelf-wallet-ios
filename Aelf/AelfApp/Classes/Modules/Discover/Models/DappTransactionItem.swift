//
//  DappTransactionItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

struct DappTransactionItem {

    var title: String
    var value: Any?

    var enableCopy: Bool // 是否允许拷贝(展示拷贝图标)
    var enableLines: Bool // 是否允许多行展示

    init(title: String, value: Any? = nil, enableCopy: Bool = false, enableLines: Bool = false) {
        self.title = title
        self.value = value
        self.enableCopy = enableCopy
        self.enableLines = enableLines
    }
}
