//
//  NSNotification+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension NSNotification {

    static func name(_ raw: String) -> NSNotification.Name {
        return NSNotification.Name(rawValue: raw)
    }

    static var language: NSNotification.Name {
        return NSNotification.name(LCLLanguageChangeNotification)
    }
}

extension NotificationCenter {

    static func post(name: String, object: Any? = nil) {
        NotificationCenter.default.post(name: NSNotification.name(name), object: object)
    }

    static func post(name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.post(name: name, object: object)
    }
}
