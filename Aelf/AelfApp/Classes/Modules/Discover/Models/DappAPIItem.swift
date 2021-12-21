//
//  DappAPIItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/12.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper

struct DappAPIItem: Mappable {
    var endpoint = ""
    var apiPath = ""
    var argumentsInput: [Any]?
    var timestamp = ""
    var contractMethod = ""
    var contractAddress = ""
    var address = ""
    var method = ""
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        endpoint <- map["endpoint"]
        apiPath <- map["apiPath"]
        argumentsInput <- map["arguments"]
        timestamp <- (map["timestamp"],MapperString())
        contractAddress <- map["contractAddress"]
        contractMethod <- map["contractMethod"]
        address <- map["address"]
        method <- map["method"]
    }
    
    
}
