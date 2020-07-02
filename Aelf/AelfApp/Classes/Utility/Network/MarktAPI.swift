//
//  MarktAPI.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

import Moya

let marketProvider = MoyaProvider<MarktAPI>(endpointClosure:MoyaProvider.JSONEndpointMapping,
                                            manager: BaseConfig.manager,
                                            plugins: [NetworkLoggerPlugin(verbose: true,
                                                                          responseDataFormatter: BaseConfig.jsonFormatter),
                                                      BaseConfig.networkActivityPlugin])

enum MarktAPI{
    //市场数据
    case markList(currency: String, ids: String, perPage: Int, page: Int, sparkLine: Bool, priceChangePercentage: String)
    //币详情
    case coinDetail(id: String)
    //K线数据
    case tradeKline(id: String,currency: String,days: String)
}

extension MarktAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return NSURL.init(string: "https://api.coingecko.com/api/v3/")! as URL
    }
    
    var path: String {
        var path = ""
        switch self {
        case .markList:
            path = "coins/markets"
        case .coinDetail:
            path = "coins/{id}"
        case .tradeKline:
            path = "coins/{id}/market_chart"
            break
            path += "?lang=\(App.languageID ?? "")"
        }
        return path
    }
    var method: Moya.Method {
        switch self {
        default:
            return .get // 默认 get
        }
    }
    
    var sampleData: Data { // 单元测试用
        return Data()
    }
    
    var task: Task {
        var parameters = [String:String]()
        switch self {
        case let .markList(currency, ids, perPage, page, sparkLine, priceChangePercentage):
            parameters = ["vs_currency":currency,
                          "ids":ids,
                          "order":"market_cap_desc",
                          "per_page":perPage.string,
                          "page":page.string,
                          "sparkline":sparkLine.string,
                          "price_change_percentage":priceChangePercentage]
        case let .coinDetail(id):
            parameters = ["id":id]
        case let .tradeKline(id, currency, days):
            parameters = ["id":id,
                          "vs_currency":currency,
                          "days":days]
        }
        
        logInfo("\n \(self.path)\n请求参数：\(parameters)\n")
        
//        parameters.addIfNotExist(dict: BaseConfig.baseParameters())
        
        var headers: [String : String]? {
            return nil
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
}


#warning("老版本接口设置")
//enum MarktAPI{
//    case markList(currency: String,sortType: Int,p: Int,coinName: String?)
//    case coinDetail(currency: String,name: String)
//    case tradeKline(currency: String,name: String,time: Int,type: Int)
//
//    // 获取收藏的币种的行情，多个币种以英文逗号分隔，传给 coins
//    case favouriteMarket(currency: String,coins: String)
//}

//extension MarktAPI: TargetType {
//
//    var baseURL: URL {
//        return BaseConfig.BaseURL
//    }
//
//    var path: String {
//        var path = ""
//        switch self {
//        case .markList:
////            path = "app/market/list"
//            path = "coins/markets"
//        case .coinDetail:
//            path = "app/market/coin_detail"
//        case .tradeKline:
//            path = "app/market/trade_kline"
//        case .favouriteMarket:
//            path = "app/market/my"
//        }
//        path += "?lang=\(App.languageID ?? "")"
//        return path
//    }
//
//    var method: Moya.Method {
//        switch self {
//        default:
//            return .post // 默认 post
//        }
//    }
//
//    var sampleData: Data { // 单元测试用
//        return Data()
//    }
//
//    var task: Task {
//        var parameters = [String:String]()
//        switch self {
//        case let .markList(currency, sortType, p, coinName):
//            parameters = ["currency":currency,"sort":sortType.string,"p":p.string,"time":"\(3)"]
//            if let coinName = coinName { // 搜索用
//                parameters["coinName"] = coinName
//            }
//        case let .coinDetail(currency, name):
//            parameters = ["currency":currency,"name":name]
//        case let .tradeKline(currency, name, time, type):
//            parameters = ["currency":currency,"name":name,"time":time.string,"type":type.string]
//        case let .favouriteMarket(currency, coins):
//            parameters = ["currency":currency,"customCoin":coins]
//        }
//
//        logInfo("\n \(self.path)\n请求参数：\(parameters)\n")
//        parameters.rsaEncode()
//
//        parameters.addIfNotExist(dict: BaseConfig.baseParameters())
//
//        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
//    }
//
//    var headers: [String : String]? {
//        return BaseConfig.headers
//    }
//}
