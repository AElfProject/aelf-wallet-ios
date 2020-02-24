//
//  ServerErrorType.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/28.
//  Copyright © 2019 晋先森. All rights reserved.
//

import Foundation

enum ErrorType: String {
    case networkError = "Network exception, please try again later"
    case getDataFailed = "Failed to get the data. Please try again later"
    case tokenInValid = "Token invalid, please login again"
    case dataParseError = "Data parsing failed"
    case serverError = "Data return error"
    case noData = "Empty Data"
    case notFound = "Search result is empty"
    case notFoundDapp = "Unable to find DApp"
    case noNotifications = "No-Notifications"

}

enum ResultError: Swift.Error {
    case parseError(String)
    case parseResultError(VResult)
}

extension ResultError: LocalizedError {

    public var msg: String? {

        switch self {
        case .parseResultError(let result):
            return result.msg
        case .parseError(let msg):
            return msg
        }
    }

    static func error(type: ErrorType) -> ResultError {
        return ResultError.parseError(type.rawValue.localized())
    }

    //
    static var getDataFailed: ResultError {
        return error(type: .getDataFailed)
    }
    static var noData: ResultError {
        return error(type: .noData)
    }
    static var notFound: ResultError {
        return error(type: .notFound)
    }
    static var notFoundDapp: ResultError {
        return error(type: .notFoundDapp)
    }
    static var noNotifications: ResultError {
        return error(type: .noNotifications)
    }
}
