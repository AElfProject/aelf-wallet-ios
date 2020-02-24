//
//  Network+Cache.swift
//  RxNetwork
//
//  Created by Pircate on 2018/7/7.
//  Copyright © 2018年 Pircate. All rights reserved.
//

import Cache
import Moya
//import RxMoyaCache

public class MoyaCache {
    
    public static let shared = MoyaCache()
    
    public var storagePolicyClosure: (Moya.Response) -> Bool = { _ in true }
    
    private init() {}
}

extension Storable where Self: TargetType {
    
    public var allowsStorage: (Response) -> Bool {
        return MoyaCache.shared.storagePolicyClosure
    }
    
    public func cachedResponse(for key: CachingKey) throws -> Response {
        return try Storage<Moya.Response>().object(forKey: key.stringValue)
    }
    
    public func storeCachedResponse(_ cachedResponse: Response, for key: CachingKey) throws {
        try Storage<Moya.Response>().setObject(cachedResponse, forKey: key.stringValue)
    }
    
    public func removeCachedResponse(for key: CachingKey) throws {
        try Storage<Moya.Response>().removeObject(forKey: key.stringValue)
    }
    
    public func removeAllCachedResponses() throws {
        try Storage<Moya.Response>().removeAll()
    }
}

private extension MoyaCache {
    
    struct DiskStorageName {
        
        static let response = "com.pircate.github.cache.response"
    }
}

private extension Storage where T == Moya.Response {
    
    convenience init() throws {
       try self.init(diskConfig: DiskConfig(name: MoyaCache.DiskStorageName.response),
                     memoryConfig: MemoryConfig(),
                     transformer: Transformer<T>(
                        toData: { $0.data },
                        fromData: { T(statusCode: 200, data: $0) }))
    }
}
