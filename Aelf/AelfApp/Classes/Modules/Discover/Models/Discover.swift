//
//  DiscoverModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/10.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper

struct Discover: Mappable {

    var banner : [DiscoverBanner]?
    var dapp = [DiscoverDapp]()
    var group = [DiscoverItem]()
    var tool = [DiscoverDapp]()

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        banner <- map["banner"]
        dapp <- map["dapp"]
        group <- map["group"]
        tool <- map["tool"]
    }

}

struct DiscoverDapp: Mappable {

    var cat = ""
    var coin = ""
    var desc = ""
    var ico = ""
    var id = ""
    var isindex = ""
    var logo = ""
    var name = ""
    var tag : [DiscoverTag]?
    var type = ""
    var url = ""
    var website = ""

    init?(map: Map){}

    mutating func mapping(map: Map) {
        cat <- map["cat"]
        coin <- map["coin"]
        desc <- map["desc"]
        ico <- map["ico"]
        id <- map["id"]
        isindex <- map["isindex"]
        logo <- map["logo"]
        name <- map["name"]
        tag <- map["tag"]
        type <- map["type"]
        url <- map["url"]
        website <- map["website"]

    }
}

struct DiscoverTag: Mappable {

    var val = ""
    var hex = ""

    init?(map: Map) {}
    mutating func mapping(map: Map) {
        val <- map["val"]
        hex <- map["hex"]
    }
}

//struct DiscoverGroup: Mappable {
//
//    var group : [DiscoverItem]?
//    var tag : Int?
//    var title = ""
//
//    init?(map: Map) {}
//    mutating func mapping(map: Map) {
//        group <- map["group"]
//        tag <- map["tag"]
//        title <- map["title"]
//
//    }
//}

struct DiscoverItem: Mappable {

    var name = ""
    var fullName = ""
    var logo = ""
    var website = ""

    init?(map: Map) {}
    mutating func mapping(map: Map) {
        name <- map["name"]
        fullName <- map["fullName"]
        logo <- map["logo"]
        website <- map["website"]
    }
}



struct DiscoverBanner: Mappable {

    var desc = ""
    var flag = ""
    var gid = ""
    var img = ""
    var logo = ""
    var name = ""
    var title = ""
    var url = ""

    init(map: Map) {}
    mutating func mapping(map: Map) {
        desc <- map["desc"]
        flag <- map["flag"]
        gid <- map["gid"]
        img <- map["img"]
        logo <- map["logo"]
        name <- map["name"]
        title <- map["title"]
        url <- map["url"]

    }
}
