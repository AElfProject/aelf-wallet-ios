//
//  BaseModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya_ObjectMapper

struct VResult: Mappable {

    var status: Int = -1
    var msg: String?
    var data: Any?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        status <- map["status"]
        msg <- map["msg"]
        data <- map["data"]
    }

    static func netError() -> VResult {
        return VResult(JSON: ["status":"-1","msg":ResultError.error(type: .networkError)])!
    }
    static func getDataFailed() -> VResult {
        return VResult(JSON: ["status":"-2","msg":ResultError.error(type: .getDataFailed)])!
    }

    static func parseError() -> VResult {
        return VResult(JSON: ["status":"-3","msg":ResultError.error(type: .dataParseError)])!
    }

    var isOk: Bool {
        return status == 200
    }
}

extension VResult {

    func mapObjects<T: Mappable>(_ map: T.Type,context: MapContext? = nil) throws -> [T] {
        guard self.isOk else { // 接口返回状态错误。
            #if DEUBG // 产品不希望用户看到 `Error`，所以只在 DEBUG 展示方便调试😌。
            throw ResultError.parseError(self.msg ?? ErrorType.serverError.rawValue.localized())
            #else
            throw ResultError.parseError(self.msg ?? ErrorType.noData.rawValue.localized())
            #endif
        }
        guard let objects = Mapper<T>(context: context).mapArray(JSONObject: self.data) else {
            logInfo("接口数据类型无法解析：\(self)") // 接口返回数据类型错误。
            #if DEUBG
            throw ResultError.parseError(self.msg ?? ErrorType.dataParseError.rawValue.localized())
            #else
            throw ResultError.parseError(self.msg ?? ErrorType.noData.rawValue.localized())
            #endif
        }

        return objects
    }

    func mapObject<T: Mappable>(_ map: T.Type,context: MapContext? = nil) throws -> T {
        guard self.isOk else {
            #if DEUBG
            throw ResultError.parseError(self.msg ?? ErrorType.serverError.rawValue.localized())
            #else
            throw ResultError.parseError(self.msg ?? ErrorType.noData.rawValue.localized())
            #endif
        }
        guard let object = Mapper<T>(context: context).map(JSONObject: self.data) else {
            logInfo("接口数据无法解析：\(self)")
            #if DEUBG
            throw ResultError.parseError(self.msg ?? ErrorType.dataParseError.rawValue.localized())
            #else
            throw ResultError.parseError(self.msg ?? ErrorType.noData.rawValue.localized())
            #endif
        }
        return object
    }

}


/// --- convet to string
class MapperString: TransformType {
    typealias Object = String
    typealias JSON = Any

    func transformFromJSON(_ value: Any?) -> String? {
        if let v = value as? Int {
            return String(v)
        }
        if let v = value as? Double {
            return String(v)
        }
        if let v = value as? String {
            return v
        }
        return nil
    }

    func transformToJSON(_ value: String?) -> Any? {
        return value
    }

}


class MapperInt: TransformType {

    typealias Object = Int
    typealias JSON = Any
    
    func transformToJSON(_ value: Int?) -> Any? {
        return value
    }
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let v = value as? String {
            return Int(v)
        }
        if let v = value as? Int {
            return v
        }
        if let v = value as? Double {
            return Int(v)
        }
        return nil
    }
}
