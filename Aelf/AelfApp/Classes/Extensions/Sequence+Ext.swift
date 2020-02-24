//
//  Sequence+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

extension Sequence {
    /// 返回序列乱序的数组
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
