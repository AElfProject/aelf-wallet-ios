//
//  SystemMessageModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import ObjectMapper

class SystemMessageModel: Mappable {
    var count : String?
    var list = [MessageDetaiModel]()
    var unreadCount : String?

    required init?(map: Map){}
    
    func mapping(map: Map) {
        count <- map["count"]
        list <- map["list"]
        unreadCount <- map["unread_count"]
        
    }

}
class MessageDetaiModel : Mappable{
    
    var title : String?
    var createTime : String?
    var desc : String?
    var id : String?
    var isRead : String?
    var message : String?
    var sort : String?
    var type : String?
    

    required init?(map: Map){}
    
    func mapping(map: Map) {
        title <- map["title"]
        createTime <- map["create_time"]
        desc <- map["desc"]
        id <- map["id"]
        isRead <- map["is_read"]
        message <- map["message"]
        sort <- map["sort"]
        type <- map["type"]
        
    }
    
    func isDidRead() -> Bool { // 0未读 1已读
        return isRead == "1"
    }
}
