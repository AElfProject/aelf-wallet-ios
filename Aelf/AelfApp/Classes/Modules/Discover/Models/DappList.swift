//
//  DappList.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/16.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct DappList: Mappable {

    var dapps = [DiscoverDapp]()

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        dapps <- map["dapps"]
    }
}
