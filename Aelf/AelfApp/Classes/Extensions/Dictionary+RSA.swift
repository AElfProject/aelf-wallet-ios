//
//  Dictionary+RSA.swift
//  AelfApp
//
//  Created by jinxiansen on 2019/7/10.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension Dictionary where Key == String,Value == String {

    mutating func rsaEncode() {
        forEach { (key,value) in
            self[key] = value.rsaEncode
        }
    }
}
