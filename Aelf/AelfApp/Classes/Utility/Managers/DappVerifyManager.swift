//
//  DappVerifyManager.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/14.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class DappVerifyManager {
    
    static let shared = DappVerifyManager()
    
    private var privateKey: String?
    
    private var whiteList = [String:String]()
    
    private init() {
        
    }
    
}


extension DappVerifyManager {
    
    static func addWhiteList(url: String,privateKey: String) {
        shared.whiteList[url] = privateKey
    }
    
    static func getPrivateKey(url: String) -> String? {
        return shared.whiteList[url]
    }
}
