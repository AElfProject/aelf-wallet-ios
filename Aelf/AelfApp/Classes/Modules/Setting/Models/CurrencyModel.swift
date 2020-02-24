//
//  CurrencyModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/14.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

import ObjectMapper

class CurrencyModel: Mappable {
    var list = [CurrencyItemModel]()
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
    }
    
}
class CurrencyItemModel : Mappable{
    
    var name : String?
    var id : String?
    var isDefault : Bool = false
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
      //  isDefault <- false
    }
    
    
}
