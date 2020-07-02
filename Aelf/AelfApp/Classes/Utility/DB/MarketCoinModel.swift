//
//  MarketCoinModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/7.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import WCDBSwift
import ObjectMapper

class MarketCoinModel : Mappable,TableCodable {

    var identifier: String?

    var amount : Float?
    var amountTrans : String?
    var arrow : Int?
    var date : String?
    var increase : String?
    var isAdd : Int?
    var lastPrice : String?
    var lastUpdate : String?
    var logo : String?
    var marketValue : Float?
    var marketValueTrans : String?
    var maxPrice : String?
    var minPrice : String?
    var name : String?
    var nameCn : String?
    var nameEn : String?
    var type : Int?
    var vol : String?
    var volTrans : String?

    var favouriteIndex = 0

    required init?(map: Map){}

    func mapping(map: Map) {
        identifier <- map["id"]
        amount <- map["amount"]
        amountTrans <- map["amount_trans"]
        arrow <- map["arrow"]
        date <- map["date"]
        increase <- (map["price_change_percentage_24h"],MapperString())
        isAdd <- map["isAdd"]
        lastPrice <- (map["current_price"],MapperString())
        lastUpdate <- map["last_update"]
        logo <- map["logo"]
        marketValue <- map["market_value"]
        marketValueTrans <- map["market_value_trans"]
        maxPrice <- map["high_24h"]
        minPrice <- map["low_24h"]
        name <- map["symbol"]
        nameCn <- map["name_cn"]
        nameEn <- map["name_en"]
        type <- map["type"]
        vol <- map["vol"]
        volTrans <- map["vol_trans"]
    }
    
//    {
//      "market_cap_change_24h" : 1994104293,
//      "low_24h" : 9127.6499999999996,
//      "price_change_percentage_24h" : 1.1950499999999999,
//      "image" : "https:\/\/assets.coingecko.com\/coins\/images\/1\/large\/bitcoin.png?1547033579",
//      "atl_date" : "2013-07-06T00:00:00.000Z",
//      "market_cap_rank" : 1,
//      "market_cap_change_percentage_24h" : 1.1858900000000001,
//      "market_cap" : 170146572695,
//      "name" : "Bitcoin",
//      "total_supply" : 21000000,
//      "roi" : null,
//      "id" : "bitcoin",
//      "symbol" : "btc",
//      "total_volume" : 17986466524,
//      "price_change_24h" : 109.08,
//      "ath_change_percentage" : -53.031889999999997,
//      "atl" : 67.810000000000002,
//      "last_updated" : "2020-07-02T03:50:07.432Z",
//      "circulating_supply" : 18420506,
//      "ath_date" : "2017-12-16T00:00:00.000Z",
//      "atl_change_percentage" : 13521.295040000001,
//      "current_price" : 9236.7299999999996,
//      "high_24h" : 9287.1100000000006,
//      "ath" : 19665.389999999999
//    }

    enum CodingKeys :String,CodingTableKey {

        typealias Root = MarketCoinModel
        case identifier

        case amount
        case amountTrans
        case arrow
        case date
        case increase
        case isAdd
        case lastPrice
        case lastUpdate
        case logo
        case marketValue
        case marketValueTrans
        case maxPrice
        case minPrice
        case name
        case nameCn
        case nameEn
        case type
        case vol
        case volTrans

        case favouriteIndex

        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        static var columnConstraintBindings:[CodingKeys:ColumnConstraintBinding]?{
            return [
                .identifier : ColumnConstraintBinding(isPrimary:true,isAutoIncrement:true),
            ]
        }
    }

    
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
    
}

extension MarketCoinModel {

    /// 根据传入 page，获取 coins 数量，若 page = nil,则获取全部数据。
    ///
    /// - Parameter page: 页码，从 1 开始，每页固定 10 条。
    /// - Returns: 返回获取结果。
    static func getCoins(page: UInt? = nil) -> [MarketCoinModel]? {

        var limit:Limit? = nil
        var offset: Offset? = nil
        if let page = page {
            limit = 10
            offset = (page - 1) * 10
        }

        let order = [(MarketCoinModel.Properties.favouriteIndex).asOrder(by: .descending)]
        let items: [MarketCoinModel]? = DBManager.getObjects(table: MarketCoinModel.className,
                                                             where: nil,
                                                             orderBy: order,
                                                             limit: limit,  // 一页10条
            offset: offset) // 从第几条开始。

        return items
    }

    func exist() -> Bool {
        let items: [MarketCoinModel] = DBManager.getObjects(table: MarketCoinModel.className,
                                                            where: MarketCoinModel.Properties.name == self.name ?? "") ?? []
        return items.first != nil
    }

    func save() {
        self.favouriteIndex = (MarketCoinModel.getCoins() ?? []).count
        DBManager.insert(object: self)
    }

    func delete() {
        DBManager.delete(table: MarketCoinModel.className,
                         where: MarketCoinModel.Properties.name == self.name ?? "")
    }
    
    static func deleteAll() {
        DBManager.delete(table: MarketCoinModel.className)
    }

    func updateFavouriteIndex(_ index: Int = -1) {

        guard let name = self.name else { return }
        self.favouriteIndex = index

        let error = DBManager.update(table: MarketCoinModel.className,
                                     on: [MarketCoinModel.Properties.favouriteIndex],
                                     with: self, where: MarketCoinModel.Properties.name == name)
        if let e = error {
            logDebug("更新失败：\(e)")
        } else {
            //            logInfo("更新成功！")
        }
    }
}
