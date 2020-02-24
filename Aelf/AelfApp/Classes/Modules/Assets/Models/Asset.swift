//
//  Asset.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/4.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct Asset: Mappable {

    var chain: [String]?
    var list = [AssetItem]()
    var fee: [AssetFee]?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        chain <- map["chain"]
        fee <- map["fee"]
        list <- map["list"]
    }

}

struct AssetFee: Mappable {

    var id: String?
    var fee: String?
    var coin: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        fee <- map["fee"]
        coin <- map["coin"]
    }

}

struct AssetItem: Mappable {

    var decimals : String?
    var expenditure : String?
    var income : String?
    
    var balance : String = ""
    var chainID : String = ""
    var contractAddress : String = ""
    var logo : String = ""
    var name : String = ""
    var rate : AssetRate?
    var symbol : String = ""
    var type : String = ""
    
    var address : String = ""
    var color: String = ""
    
    var totalAmount: Double = 0
    var totalPrice: Double = 0

    init?(map: Map) {}
    mutating func mapping(map: Map) {
        balance <- (map["balance"],MapperString())
        chainID <- map["chain_id"]
        contractAddress <- map["contractAddress"]
        decimals <- map["decimals"]
        expenditure <- map["expenditure"]
        income <- map["income"]
        logo <- map["logo"]
        name <- map["name"]
        rate <- map["rate"]
        symbol <- map["symbol"]
        type <- map["type"]
        
        address <- map["address"]
        color <- map["color"]

        totalAmount <- map["totalAmount"]
        totalPrice <- map["totalPrice"]

    }

    func total() -> Double {
        
        let aPrice = rate?.price.double() ?? 0
        let total = balanceDouble() * aPrice

        return total
    }
    
    func balanceDouble() -> Double {
        return self.balance.double() ?? 0
    }
    
    func isMain() -> Bool {
        return type == "main"
    }

}


struct AssetRate: Mappable {

    var price: String = ""
    var increace: String?
    var increace2: String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        price <- map["price"]
        increace <- map["increace"]
        increace2 <- map["increace2"]
    }
}
