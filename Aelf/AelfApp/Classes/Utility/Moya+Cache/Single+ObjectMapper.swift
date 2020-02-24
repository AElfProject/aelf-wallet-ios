//
//  Single+ObjectMapper.swift
//  HPNetwork
//
//  Created by 佳林 on 2019/9/6.
//

import Moya
import RxSwift
import ObjectMapper

public extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func mapObject<T: Mappable>(_ type: T.Type, context: MapContext? = nil) -> Single<T> {
        return map { try $0.mapObject(type, context: context) }
    }
}
