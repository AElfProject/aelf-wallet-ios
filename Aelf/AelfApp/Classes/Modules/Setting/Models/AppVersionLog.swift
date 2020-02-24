//
//  AppUpgradeModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/19.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper

struct AppVersionList: Mappable {

    var list: [AppVersionLog]?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        list <- map["list"]
    }
}

struct AppVersionLog: Mappable{
    
    var createTime : String?
    var id : String?
    var intro : [String]?
    var isForce : String?
    var key : String?
    var minVersion : String?
    var status : String?
    var updateTime : String?
    var upgradeTime : String?
    var verNo : String?

    
    init?(map: Map){}

    mutating func mapping(map: Map) {
        createTime <- map["create_time"]
        id <- map["id"]
        intro <- map["intro"]
        isForce <- map["is_force"]
        key <- map["key"]
        minVersion <- map["min_version"]
        status <- map["status"]
        updateTime <- map["update_time"]
        upgradeTime <- map["upgrade_time"]
        verNo <- map["verNo"]
    }

}

struct AppVersionUpdate: Mappable{
    
    var appUrl = ""
    var id : String?
    var intro : [String]?
    var isForce : String?
    var status : String?
    var verNo = ""
 
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        appUrl <- map["appUrl"]
        id <- map["id"]
        intro <- map["intro"]
        isForce <- map["is_force"]
        status <- map["status"]
        verNo <- map["verNo"]

    }
    
}

