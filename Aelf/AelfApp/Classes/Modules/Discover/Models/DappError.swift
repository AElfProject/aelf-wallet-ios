//
//  DappError.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

enum DappErrorType: String {
    case networkError = "Network exception, please try again later"
    case getDataFailed = "Failed to get the data. Please try again later"
    case tokenInValid = "Token invalid, please login again"
    case dataParseError = "Data parsing failed"
    case serverError = "Data return error"
    case noData = "Empty Data"
    case notFound = "Search result is empty"
    case notFoundDapp = "Unable to find DApp"

}

enum DappError: Swift.Error {
    case message(String)
    case error(Swift.Error)
}

extension DappError: LocalizedError {

    public var msg: String {
        switch self {
        case .message(let msg):
            return msg
        case .error(let e):
            return e.localizedDescription
        }
    }

    static func error(type: ErrorType) -> DappError {
        return DappError.message(type.rawValue.localized())
    }

    //
    static var getDataFailed: DappError {
        return error(type: .getDataFailed)
    }
    static var noData: DappError {
        return error(type: .noData)
    }
    static var notFound: DappError {
        return error(type: .notFound)
    }
    static var notFoundDapp: DappError {
        return error(type: .notFoundDapp)
    }
 
}
