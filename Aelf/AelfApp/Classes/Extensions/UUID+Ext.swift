//
//  UUID+Ext.swift
//  Basic_Example
//
//  Created by jinxiansen on 2019/8/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import KeychainSwift

private let keyChain = "\(String.bundleID).keyChain"

public extension UUID {

    static var keyChainUUID: String {
        let keychain = KeychainSwift()
        if let uuid = keychain.get(keyChain) {
            return uuid
        } else {
            let uuid = UUID().uuidString
            keychain.set(uuid, forKey: keyChain)
            return uuid
        }
    }
}
