//
//  String+RSA.swift
//  AelfApp
//
//  Created by jinxiansen on 2019/7/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import SwiftyRSA

extension String {

    var rsaEncode: String {
        if appEnv == 1 {
            return self
        }
        
        let pubKey = AppConfigManager.shared.config.pubKey

        let padding = 30
        let num = self.count/padding
        var result = ""
        do {
            for i in 0..<num { // 处理30整数位的
                let sub = self[i*padding..<(i+1)*padding]
                let pub = try PublicKey(base64Encoded: pubKey)
                let clear = try ClearMessage(string: sub, using: .utf8)
                let encrypted = try clear.encrypted(with: pub, padding: .PKCS1)
                result += encrypted.base64String
                result += ";"
            }

            if count % padding != 0 { // 处理30余数位
                let sub = self[num*padding..<self.count]
                let pub = try PublicKey(base64Encoded: pubKey)
                let clear = try ClearMessage(string: sub, using: .utf8)
                let encrypted = try clear.encrypted(with: pub, padding: .PKCS1)
                result += encrypted.base64String
                result += ";"
            }

        } catch {
            logInfo("参数加密出错：\(error)")
            return self
        }

        if result.count > 0 {
            result = result.subString(to: result.count - 1)
        }
        return result
    }
    
}


fileprivate extension Dictionary {
    static func contentsOf(path: URL) -> Dictionary<String, Any> {
        let data = try! Data(contentsOf: path)
        let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)

        return plist as! [String: Any]
    }
}
