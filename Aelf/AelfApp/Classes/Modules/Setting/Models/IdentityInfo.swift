//
//  IdentityInfo.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/18.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper

struct IdentityInfo: Mappable {

    var address : String?
    var createTime : String?
    var id : String?
    var img : String?
    var name : String?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        address <- map["address"]
        createTime <- map["create_time"]
        id <- map["id"]
        img <- map["img"]
        name <- map["name"]
    }

}
