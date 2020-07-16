//
//  MarketSearchModel.swift
//  AelfApp
//
//  Created by yuguo on 2020/7/6.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

class MarketCoinListModel : Mappable {
    
    var id: String?
    var symbol: String?
    var name: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        id <- map["id"]
        symbol <- map["symbol"]
        name <- map["name"]
    }
}

class MarketSearchModel : Mappable {
    var list = [MarketCoinListModel]()

    required init?(map: Map){}

    func mapping(map: Map) {
        list <- map["list"]
    }
}
