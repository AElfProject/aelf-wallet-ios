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
    var symbol: String?
    var amount : Float?
    var amountTrans : String?
    var arrow : Int?
    var date : String?
    var increase : String?
    var isAdd : Int?
    var lastPrice : String?
    var lastUpdate : String?
    var logo : String?
    var marketValue: String?
    var marketValueTrans : String?
    var maxPrice : String?
    var minPrice : String?
    var name : String?
    var type : Int?
    var volTrans : String?
    var marketCapChange: String?
    var favouriteIndex = 0

    required init?(map: Map){}

    func mapping(map: Map) {
        identifier <- map["id"]
        symbol <- map["symbol"]
        amount <- map["amount"]
        amountTrans <- (map["total_supply"],MapperString())
        arrow <- map["arrow"]
        date <- map["date"]
        increase <- (map["price_change_percentage_24h"],MapperString())
        isAdd <- map["isAdd"]
        lastPrice <- (map["current_price"],MapperString())
        lastUpdate <- map["last_update"]
        logo <- map["logo"]
        marketValue <- (map["market_cap"],MapperString())
        marketValueTrans <- (map["market_cap_rank"],MapperString())
        maxPrice <- map["high_24h"]
        minPrice <- map["low_24h"]
        name <- map["name"]
        type <- map["type"]
        volTrans <- map["vol_trans"]
        marketCapChange <- (map["market_cap_change_24h"],MapperString())
    }

    enum CodingKeys :String,CodingTableKey {
        typealias Root = MarketCoinModel
        case identifier
        case symbol
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
        case type
        case volTrans
        case marketCapChange

        case favouriteIndex

        static let objectRelationalMapping = TableBinding(CodingKeys.self)

        static var columnConstraintBindings:[CodingKeys:ColumnConstraintBinding]?{
            return [
                .identifier : ColumnConstraintBinding(isPrimary:true,isAutoIncrement:false),
            ]
        }
    }
    
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
        
        let order = [(MarketCoinModel.Properties.favouriteIndex).asOrder(by: .ascending)]
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
