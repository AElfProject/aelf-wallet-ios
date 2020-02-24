//
//  MessageUnReadModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/17.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageUnReadModel: Mappable {
    
    var unreadCount: Int?
    var messageUnreadCount: Int?
    var noticeUnreadCount: Int?
    
    required init?(map: Map){}
    
    func mapping(map: Map) {
        unreadCount <- map["unread_count"]
        messageUnreadCount <- map["message_unread_count"]
        noticeUnreadCount <- map["notice_unread_count"]

        //  isDefault <- false
    }
    
    
}
