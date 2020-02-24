//
//  Double+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/7/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension Double {

    func format(maxDigits: Int = 8, mixDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.positiveFormat = "###,###.##"
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxDigits // 小数点最多8位
        formatter.minimumFractionDigits = mixDigits // 小数点最少2位
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
