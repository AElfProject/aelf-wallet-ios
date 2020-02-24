//
//  MarketCoinModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 legenddigital. All rights reserved.
//
import Foundation
import ObjectMapper

class MarketModel: Mappable {
    var list = [MarketCoinModel]()
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
    }
    
}
