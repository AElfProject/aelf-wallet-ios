//
//  AddressBookModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/18.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper

class AddressBookModel:Mappable{
    
    var list = [AddressBookItemModel]()
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        list <- map["list"]
    }
}
class AddressBookItemModel : Mappable{
    
    var id:String?
    var name: String?
    var note: String? // 备注
    var address: String?
    var fc : String?
    var createTime : String?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        name <- map["name"]
        note <- map["note"]
        address <- map["address"]
        fc <- map["fc"]
        id <- map["id"]
        createTime <- map["create_time"]
        //  isDefault <- false
    }
    
    
}

