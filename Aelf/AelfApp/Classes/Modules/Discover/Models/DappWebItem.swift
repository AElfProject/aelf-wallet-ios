//
//  DappResponse.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/9.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct DappWebItem: Mappable {
    
    var action = ""
    var appId = ""
    var id = ""
    var params : DappParam?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map)
    {
        action <- map["action"]
        appId <- map["appId"]
        id <- map["id"]
        params <- map["params"]
        
    }
    
}


struct DappParam : Mappable {
    
    var encryptAlgorithm : String?
    var publicKey : String?
    var signature : String?
    var timestamp : String?
    var originalParams: String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        encryptAlgorithm <- map["encryptAlgorithm"]
        publicKey <- map["publicKey"]
        signature <- map["signature"]
        timestamp <- (map["timestamp"],MapperString())
        
        originalParams <- map["originalParams"]
    }
    
    
    func parseParams(dappPublicKey: String,callback: @escaping ((DappError?,String) -> ())) {
        
        guard let signature = signature, let originalParams = originalParams else {
            return callback(DappError.message("缺少参数".localized()), "")
        }
        
        DappWallet.verify(signature: signature, message: originalParams.base64Decoded!, dappPublicKey: dappPublicKey) { result in
            
            guard result else {
                return callback(DappError.message("签名校验失败".localized()), "")
            }
            guard let decodeJson = originalParams.base64Decoded?.urlDecoded else {
                return callback(DappError.message("解码失败".localized()), "")
            }
            logInfo("解析出的 Params: \(decodeJson)")
            return callback(nil,decodeJson)
        }
    }
    
}

