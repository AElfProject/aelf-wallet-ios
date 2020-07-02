//
//  NetworkModel.swift
//  AelfApp
//
//  Created by yuguo on 2020/6/29.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper

struct NetworkModel: Mappable {
    
    var name: String?
    var nameEn: String?
    var nodeApi: String?
    var walletServer: String?
    var canDelete: Bool?
    var selected: Bool = false
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        name <- map["name"]
        nameEn <- map["nameEn"]
        nodeApi <- map["nodeApi"]
        walletServer <- map["walletServer"]
        canDelete <- map["canDelete"]
        selected <- map["selected"]
    }
}
