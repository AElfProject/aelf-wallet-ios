//
//  MarketDetailModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper
//MarketDetailModel

class MarketTradeModel: Mappable {
    var list = [MarketTradeDetailModel]()
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
    }
}

class MarketTradeDetailModel :  Mappable{
    
    var createTime = ""
    var last: Double = 0
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        createTime <- map["createTime"]
        last <- map["last"]
    }
}

class MarketDetailModel : Mappable{
    
    var circulate : String?
    var circulateRate : String?
    var community : [Community]?
    var exchangeCount : String?
    var globalRate : String?
    var highestPrice : String?
    var logo : String?
    var marketValue : String?
    var marketValueOrder = 0
    var name : String?
    var nameCn : String?
    var nameEn : String?
    var profile : String?
    var pubTime : String?
    var site = [MarketSiteModel]()
    var supply : String?
    var turnoverRate : String?
    var vol : String?
    var volTrans : String?
    
    var usdToCNY = "" // 美元兑人民币汇率：6.9
    
    required init?(map: Map){}

    func mapping(map: Map) {
        circulate <- map["circulate"]
        circulateRate <- map["circulate_rate"]
        community <- map["community"]
        exchangeCount <- map["exchange_count"]
        globalRate <- map["global_rate"]
        highestPrice <- map["highest_price"]
        logo <- map["logo"]
        marketValue <- map["market_value"]
        marketValueOrder <- map["market_value_order"]
        name <- map["name"]
        nameCn <- map["name_cn"]
        nameEn <- map["name_en"]
        profile <- map["profile"]
        pubTime <- map["pub_time"]
        site <- map["site"]
        supply <- map["supply"]
        turnoverRate <- map["turnover_rate"]
        vol <- map["vol"]
        volTrans <- map["vol_trans"]
        
        usdToCNY <- map["usd_cny"]
    }
}
class MarketSiteModel : Mappable{
    
    var name : String?
    var url : String?

    required init?(map: Map){}
    
    func mapping(map: Map) {
        name <- map["name"]
        url <- map["url"]
    }
}

class Community : Mappable{
    
    var logo : String?
    var url : String?

    required init?(map: Map){}
    
    func mapping(map: Map) {
        logo <- map["logo"]
        url <- map["url"]
    }
}
