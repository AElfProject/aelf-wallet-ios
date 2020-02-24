//
//  AssetNotice.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/12.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct AssetNoticeList: Mappable {

    var list: [AssetNotice]?
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        list <- map["list"]
    }

}

struct AssetNotice: Mappable {

    var createTime : String?
    var desc : String?
    var id : String?
    var message : String?
    var sort : String?
    var type : String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        createTime <- map["create_time"]
        desc <- map["desc"]
        id <- map["id"]
        message <- map["message"]
        sort <- map["sort"]
        type <- map["type"]
    }

}
