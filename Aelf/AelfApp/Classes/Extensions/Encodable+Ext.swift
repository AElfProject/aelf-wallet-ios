//
//  Encodable+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension Encodable {

    static var className: String {
        return String(describing: self)
    }
}
