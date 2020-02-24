//
//  TargetType+Cache.swift
//  RxNetwork
//
//  Created by Pircate on 2018/7/7.
//  Copyright © 2018年 Pircate. All rights reserved.
//

import Moya
import RxSwift

public extension TargetType where Self: Cacheable {
    
    func cachedResponse() throws -> Moya.Response {
        return try cachedResponse(for: self)
    }
    
    func storeCachedResponse(_ cachedResponse: Moya.Response) throws {
        try storeCachedResponse(cachedResponse, for: self)
    }
    
    func removeCachedResponse() throws {
        try removeCachedResponse(for: self)
    }
}
