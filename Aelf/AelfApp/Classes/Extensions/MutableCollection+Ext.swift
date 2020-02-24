//
//  MutableCollection+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension MutableCollection {
    /// 打乱集合里的元素
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}
