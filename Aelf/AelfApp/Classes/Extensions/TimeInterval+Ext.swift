//
//  TimeInterVal+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

private let formatter = DateFormatter()

extension TimeInterval {

    func transTime() -> String {

        let date = Date(timeIntervalSince1970: self)

        if let id = App.languageID, id.contains("zh") {
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // cn
        } else {
            formatter.dateFormat = "dd/MM/yyyy HH:mm:ss" // en
        }
        return formatter.string(from: date)
    }
}

