//
//  TransationNoteModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper


class TransationNoteModel :Mappable{
    var count : Int?
    var list = [AssetHistory]()
    var unreadCount : Int?

    required init?(map: Map){}
    
    func mapping(map: Map) {
        count <- map["count"]
        list <- map["list"]
        unreadCount <- map["unread_count"]
    }
}
