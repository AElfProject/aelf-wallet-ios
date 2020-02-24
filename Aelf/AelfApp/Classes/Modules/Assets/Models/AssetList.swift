//
//  AssetInfo.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/13.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper

struct AssetInfo: Mappable {

    var blockHash : String?
    var chainID = ""
    var contractAddress = ""
    var decimals : Int?
    var aIn : Int?
    var name : String?
    var symbol = ""
    var totalSupply : Int?
    var txId : String?
    var logo: String?
    var balance: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        blockHash <- map["block_hash"]
        chainID <- map["chain_id"]
        contractAddress <- map["contract_address"]
        decimals <- map["decimals"]
        aIn <- map["in"]
        name <- map["name"]
        symbol <- map["symbol"]
        totalSupply <- map["total_supply"]
        txId <- map["tx_id"]
        logo <- map["logo"]
        balance <- map["balance"]
    }
    
    func isEqual(item: AssetInfo) -> Bool {
        return chainID == item.chainID && symbol == item.symbol && contractAddress == item.contractAddress
    }
    
    /// 是否允许解绑
    var isAllowUnBind: Bool {
        return blockHash != "inner" // block_hash=inner 的代币不允许解除绑定
    }
    

    static func transformFromJSON(_ value: Any?) -> [String: [AssetInfo]] {

        guard let dict = value as? [String: Any] else { return [:] }
        var result = [String: [AssetInfo]]()
        for (key,value) in dict {

            if let listDict = value as? [[String:Any]] {
                var coinList = [AssetInfo]()
                for v in listDict {
                    if let item = AssetInfo(JSON: v) {
                        coinList.append(item)
                    }
                }
                result[key] = coinList
            }
        }
        return result
    }
}
