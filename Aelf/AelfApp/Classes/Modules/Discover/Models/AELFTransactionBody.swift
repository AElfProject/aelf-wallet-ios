//
//  AELFTransactionBody.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper

struct AELFTransactionBody: Mappable {
    
    var blockHash = ""
    var blockNumber = 0
    var bloom = ""
//    var error : Any?
//    var logs : [Log]?
    var readableReturnValue = ""
    var returnValue = ""
    var status = ""
    var transaction : AELFTransaction?
//    var transactionFee : TransactionFee?
    var transactionId = ""

    init?(map: Map) {
    }
    
    mutating func mapping(map: Map)
    {
        blockHash <- map["BlockHash"]
        blockNumber <- map["BlockNumber"]
        bloom <- map["Bloom"]
//        error <- map["Error"]
//        logs <- map["Logs"]
        readableReturnValue <- map["ReadableReturnValue"]
        returnValue <- map["ReturnValue"]
        status <- map["Status"]
        transaction <- map["Transaction"]
//        transactionFee <- map["TransactionFee"]
        transactionId <- map["TransactionId"]
        
    }
}


struct AELFTransaction: Mappable {

    var from = ""
    var methodName = ""
    var params = ""
    var refBlockNumber = 0
    var refBlockPrefix = ""
    var signature = ""
    var to = ""
        
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        from <- map["From"]
        methodName <- map["MethodName"]
        params <- map["Params"]
        refBlockNumber <- map["RefBlockNumber"]
        refBlockPrefix <- map["RefBlockPrefix"]
        signature <- map["Signature"]
        to <- map["To"]
    }
}

struct AELFTransactionParams: Mappable {

    var symbol = ""
    var amount = ""
    var memo = ""
    var to = ""
//    var from = ""
        
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
//        from <- map["From"]
        symbol <- map["symbol"]
        amount <- map["amount"]
        memo <- map["memo"]
        to <- map["to"]
    }
}


/**
 
 {"code":0,"msg":"success","error":[],"data":{"BlockHash":"589665d3074f6fa3c4a36a586815049367f656f58603b172b2463904f75f9156","TransactionFee":{"Value":{"ELF":10214000}},"Status":"MINED","Bloom":"AAAAAAAAACAAAAAAAAAAAAAIAAQAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAQAAAAAAAAQAAAAAAACQAAAAAAAAAAAABAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==","ReadableReturnValue":"{ }","ReturnValue":"","BlockNumber":5485591,"Error":null,"Transaction":{"RefBlockNumber":5485584,"Params":"{ \"to\": \"2YRjTJgE9qziwngfYHQTpMSzjVkY5Bq5sY1LqsZKxyhMZjErQb\", \"symbol\": \"ELF\", \"amount\": \"100000000\", \"memo\": \"21\" }","MethodName":"Transfer","RefBlockPrefix":"z/dZuA==","To":"25CecrU94dmMdbhC3LWMKxtoaL4Wv8PChGvVJM6PxkHAyvXEhB","Signature":"g4PXr4uGoxQ/qqm/xLj+UNVvfKNzdNTogMDovk/4Fi58Ux6KnHvb6foaHaS6Rc+59OkPXSbY+ss5sKzPndSg0wA=","From":"QDDLWzuvSYhYR18KeF7AHZNpJdtrTCh2G8MprXF4rGx8x9Fpm"},"Logs":[{"NonIndexed":"IICEr18qAjIx","Address":"25CecrU94dmMdbhC3LWMKxtoaL4Wv8PChGvVJM6PxkHAyvXEhB","Name":"Transferred","Indexed":["CiIKIDSz0hanvfyQzKHvnca6ouY+6UoUlxw0I1nK+w+/LEb1","EiIKIMsNuW2LTTcVKiJF8gvXSkXuaiLp5oS+PHFZocI6rwVT","GgNFTEY="]}],"TransactionId":"a02e1b58deab5e28298c09e47a9ee4031eb56bcf4a1cc01c393c88351c1dd6b3"}}
 
 
 */
