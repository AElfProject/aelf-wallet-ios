//
//  AssetHistory.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct AssetHistoryData: Mappable {

    var count: Int?
    var pageCount: Int?
    var list: [AssetHistory]?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        count <- map["count"]
        pageCount <- map["pageCount"]
        list <- map["list"]
    }

}

struct AssetHistory: Mappable {

    var addressList : [AnyObject]?
    var amount = ""
    var block = 0
    var category = "" // receive接收,send转出
    var chain = ""
    var completed : Int?
    var confirmations : Int?
    var fee: String?
    var from = ""
    var gasLimit = ""
    var gasPrice = ""
    var gasUsed = ""
    var memo: String?
    var status = "" // 1成功，0处理中，-1失败
    var statusText = ""
    var symbol = ""
    var time : String?
    var timeOffset : Int?
    var to = ""
    var txid = ""
    var id = ""
    var isRead = ""
    var fromChainID = ""
    var toChainID = ""

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {

        addressList <- map["addressList"]
        amount <- (map["amount"],MapperString())
        block <- (map["block"],MapperInt())
        category <- map["category"]
        chain <- map["chain"]
        completed <- map["completed"]
        confirmations <- map["confirmations"]
        fee <- map["fee"]
        from <- map["from"]
        gasLimit <- map["gasLimit"]
        gasPrice <- map["gasPrice"]
        gasUsed <- map["gasUsed"]
        memo <- map["memo"]
        status <- (map["status"],MapperString())
        statusText <- map["statusText"]
        symbol <- map["symbol"]
        time <- (map["time"],MapperString())
        timeOffset <- map["timeOffset"]
        to <- map["to"]
        txid <- map["txid"]
        id <- map["id"]
        isRead <- map["is_read"]
        fromChainID <- map["from_chainid"]
        toChainID <- map["to_chainid"]
        
    }

    func isDidRead() -> Bool { // 0未读 1已读
        return isRead == "1"
    }

    func resultImage() -> UIImage? {

        // 1成功，0处理中，-1失败
        switch status.int {
        case 0:
            return UIImage(named: "packaging")
        case 1:
            return UIImage(named: "success")
        case -1:
            return UIImage(named: "warning")
        default:
            return UIImage(named: "packaging")
        }
    }

}


extension AssetHistory {

    func isTransfer() -> Bool {
        return self.category == "send" // == send 转出 to, receive 接收 from。
    }
}
