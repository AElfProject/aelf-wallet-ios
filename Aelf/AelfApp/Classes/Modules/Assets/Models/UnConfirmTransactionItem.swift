//
//  UnConfirmItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/1.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct UnConfirmTransaction: Mappable {
    
    var list = [UnConfirmTransactionItem]()
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        list <- map["list"]
    }
}

struct UnConfirmTransactionItem: Mappable {

    var amount = ""
    var fromAddress = ""
    var fromChain = ""
    var symbol = ""
    var time = 0
    var toAddress = ""
    var toChain = ""
    var txid = ""
    var memo = ""
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map)
    {
        amount <- map["amount"]
        fromAddress <- map["from_address"]
        fromChain <- map["from_chain"]
        symbol <- map["symbol"]
        time <- (map["time"],MapperInt())

        toAddress <- map["to_address"]
        toChain <- map["to_chain"]
        txid <- map["txid"]
        memo <- map["memo"]
    }
    
}
