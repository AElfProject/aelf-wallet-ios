//
//  Response+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/29.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import Moya
//import Moya_ObjectMapper

extension Response {

    func toResult() -> VResult {
        guard let r = try? mapObject(VResult.self) else {
            return VResult.parseError()
        }
        return r
    }
}
