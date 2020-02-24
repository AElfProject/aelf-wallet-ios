//
//  MoyaProviderType+Rx.swift
//  RxMoyaCache
//
//  Created by Pircate on 2018/4/18.
//  Copyright © 2018年 Pircate. All rights reserved.
//

import RxSwift
import Moya
import ObjectMapper

extension Reactive where Base: MoyaProviderType, Base.Target: Cacheable {
    
    public var cache: CacheProvider<Base> {
        return CacheProvider(provider: base)
    }
    
    public func onCache<T: Mappable>(
        _ target: Base.Target,
        type: T.Type,
        context: MapContext? = nil,
        _ closure: (T) -> Void)
        -> OnCacheProvider<Base, T>
    {
  
        if let object = try? target.cachedResponse()
            .mapObject(type, context: context) {
            closure(object)
        }
        
        return OnCacheProvider(target: target, provider: base, context: context)
    }
}
