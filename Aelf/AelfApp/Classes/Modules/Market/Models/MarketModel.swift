//
//  MarketCoinModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//
import Foundation
import ObjectMapper

//struct MarketCoinModel: Mappable {
//    
//    //    {
//    //      "market_cap_change_24h" : 3606054,
//    //      "low_24h" : 4.0999999999999996,
//    //      "price_change_percentage_24h" : 0.55947000000000002,
//    //      "image" : "https:\/\/assets.coingecko.com\/coins\/images\/2822\/large\/huobi-token-logo.png?1547036992",
//    //      "atl_date" : "2019-01-30T00:00:00.000Z",
//    //      "market_cap_rank" : 20,
//    //      "market_cap_change_percentage_24h" : 0.37309999999999999,
//    //      "market_cap" : 970121303,
//    //      "name" : "Huobi Token",
//    //      "total_supply" : 500000000,
//    //      "roi" : {
//    //        "times" : 3.2017321501971625,
//    //        "currency" : "usd",
//    //        "percentage" : 320.17321501971628
//    //      },
//    //      "id" : "huobi-token",
//    //      "symbol" : "ht",
//    //      "total_volume" : 124689463,
//    //      "price_change_24h" : 0.02314277,
//    //      "ath_change_percentage" : -31.581759999999999,
//    //      "atl" : 0.90861999999999998,
//    //      "last_updated" : "2020-07-01T16:32:30.376Z",
//    //      "circulating_supply" : 233370544.97192115,
//    //      "ath_date" : "2018-06-06T01:58:09.128Z",
//    //      "atl_change_percentage" : 357.36637999999999,
//    //      "current_price" : 4.1600000000000001,
//    //      "high_24h" : 4.1600000000000001,
//    //      "ath" : 6.0700000000000003
//    //    }
//    
//    var marketCapChange: String?
//    var low: String?
//    var priceChange: String?
//    var image: String?
//    var atlDate: String?
//    var marketCapRank: String?
//    var marketCap: String?
//    var name: String?
//    var totalSupply: Int?
//    var id: String?
//    var symbol: String?
//    var totalVolume: String?
//    var athChange: String?
//    var atl: String?
//    var currentPrice: String?
//    var ath: String?
//    var circulatingSupply: String?
//    var roi: roiModel?
//    
//    init?(map: Map) {}
//    
//    mutating func mapping(map: Map) {
//        marketCapChange <- map["market_cap_change_24h"]
//        low <- map["low_24h"]
//        priceChange <- map["price_change_percentage_24h"]
//        image <- map["image"]
//        atlDate <- map["atl_date"]
//        marketCapRank <- map["market_cap_rank"]
//        marketCapChange <- map["market_cap_change_percentage_24h"]
//        marketCap <- map["market_cap"]
//        name <- map["name"]
//        totalSupply <- map["total_supply"]
//        symbol <- map["symbol"]
//        totalVolume <- map["total_volume"]
//        priceChange <- map["price_change_24h"]
//        athChange <- map["ath_change_percentage"]
//        currentPrice <- map["current_price"]
//        ath <- map["ath"]
//        circulatingSupply <- map["circulating_supply"]
//        roi <- map["roi"]
//    }
//}

//struct roiModel: Mappable {
//    
//    var times: String?
//    var currency: String?
//    var percentage: String?
//    
//    init?(map: Map) {}
//    
//    mutating func mapping(map: Map) {
//        times <- map["times"]
//        currency <- map["currency"]
//        percentage <- map["percentage"]
//    }
//    
//}

class MarketModel: Mappable {
    var list = [MarketCoinModel]()

    required init?(map: Map){}

    func mapping(map: Map) {
        list <- map
    }

}
