//
//  ChainItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/25.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import ObjectMapper
import WCDBSwift


struct ChainItem: Mappable,TableCodable {

    var identifier:Int?
    var decimals:Int?
    var symbol = ""
    var logo = ""
    var color = ""
    var node = ""
    var type = ""
    var name = "" // chainID
    var contractAddress = ""
    var explorer = ""
    var issueID = ""
    var issueChainId = ""
    var crossChainContractAddress = ""
    var transferCoins = "" // 支持的交易币种

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        symbol <- map["symbol"]
        decimals <- map["decimals"]
        logo <- map["logo"]
        color <- map["color"]
        node <- map["node"]
        type <- map["type"]
        name <- map["name"]
        contractAddress <- map["contract_address"]
        explorer <- map["explorer"]
        issueID <- map["issueid"]
        issueChainId <- map["issue_chain_id"]

        crossChainContractAddress <- map["crossChainContractAddress"]
        transferCoins <- map["transferCoins"]
    }
    
    enum CodingKeys :String,CodingTableKey {
        
        typealias Root = ChainItem
        case identifier
        case symbol
        case logo
        case color
        case node
        case type
        case name
        case contractAddress
        case explorer
        case issueID
        case crossChainContractAddress
        case transferCoins

        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        static var columnConstraintBindings:[CodingKeys:ColumnConstraintBinding]?{
            return [
                .identifier : ColumnConstraintBinding(isPrimary:true,isAutoIncrement:true),
            ]
        }
    }
    
}


extension ChainItem {
    
    static func getItem(chainID: String) -> ChainItem? {
        let items: [ChainItem]? = DBManager.getObjects(table: ChainItem.className, where: ChainItem.Properties.name == chainID)
        return items?.first
    }
    
    static func getMainItem() -> ChainItem? {
        let items: [ChainItem]? = DBManager.getObjects(table: ChainItem.className, where: ChainItem.Properties.type == "main")
        return items?.first
    }
    
    static func getItems() -> [ChainItem] {
        let items: [ChainItem] = DBManager.getObjects(table: ChainItem.className) ?? []
        return items
    }
    
    @discardableResult
    static func clearAndInsertNew(items:[ChainItem]) -> Bool {
        guard items.count > 0 else {
            return false
        }
        
        if let _ = DBManager.delete(table: ChainItem.className) {
            return false
        }
        
        // inserts
        let e = DBManager.insert(objects: items)
        return e == nil
    }
}

extension ChainItem {
    func isMain() -> Bool {
        return type == "main"
    }
    
    
    /// 是否支持跨链转账。
    /// - Parameter toSymbol: 接收链的 Symbol
    func isSupportTransfer(toSymbol: String) -> Bool {
        if transferCoins == "*" { return true } //
        if transferCoins.lowercased().contains(toSymbol.lowercased()) { return true }
        return false
    }
}
