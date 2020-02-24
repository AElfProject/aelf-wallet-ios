//
//  AssetApi.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/4.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import Moya

#if DEBUG
let assetProvider = MoyaProvider<AssetAPI>(endpointClosure:MoyaProvider.JSONEndpointMapping,
                                           manager: BaseConfig.manager,
                                           plugins: [NetworkLoggerPlugin(verbose: true,
                                                                         responseDataFormatter: BaseConfig.jsonFormatter),
                                                     BaseConfig.networkActivityPlugin])
#else

let assetProvider = MoyaProvider<AssetAPI>(endpointClosure:MoyaProvider.JSONEndpointMapping,
                                           manager: BaseConfig.manager,
                                           plugins: [BaseConfig.networkActivityPlugin])
#endif


enum TransactionType: Int {
    case all = 0    // 全部
    case transfer   // 转账
    case receive    // 收款
}

enum AssetAPI {
    
    /// 资产首页接口
    case home(address: String)
    /// 交易记录列表
    case transactionList(address: String,contractAddress: String,symbol: String,chainID: String,transType: TransactionType,page: Int)
    /// 资产管理列表
    case assetList(address: String)
    /// 资产绑定/解绑操作 isBind true绑定 false解绑
    case assetBind(address: String,contractAddress: String,isBind: Bool,symbol: String,isBindAll: Bool,chainID: String)
    /// 首页公告
    case notice
    /// 转账
    case transfer(address:String,amount: CGFloat,note:String?)
    /// 获取用户余额
    case getMyBanlance(address:String,contractAddress: String,symbol:String,chainID: String)
    /// 转账
    case transferDetail(address:String, txid: String, fromChainID: String?)
    
    /// 获取跨链列表
    case crossChains
    
    case allChains(address: String, type: Int) // type = 0 平铺展现；1 合并token

    case sendTransaction(txID: String,fromChain: String,fromAddress: String,
        toChain: String,toAddress: String,symbol: String,amount: Double,memo: String)
    
    case checkUnConfirmedTransaction(address: String)
    case linkTransactionID(fromTxID: String, toTxID: String)
}

extension AssetAPI: TargetType, Cacheable {
    
    var baseURL: URL {
        return BaseConfig.BaseURL
    }
    
    var path: String {
        var path = ""
        switch self {
        case .home:
            path = "app/elf/coin_by_address"
        case .transactionList:
            path = "app/elf/address"
        case .assetList:
            path = "app/elf/assets"
        case .assetBind:
            path = "app/elf/bind"
        case .notice:
            path = "app/public/notice_message"
        case .transfer:
            path = "app/elf/send"
        case .getMyBanlance:
            path = "app/elf/balance"
        case .transferDetail:
            path = "app/elf/transaction"
        case .crossChains:
            path = "app/elf/cross_chains"
        case .allChains:
            path = "app/elf/concurrent_address"
        case .sendTransaction:
            path = "app/elf/add_index"
        case .checkUnConfirmedTransaction:
            path = "app/elf/waiting_cross_trans"
        case .linkTransactionID:
            path = "app/elf/rcv_txid"
        }
        path += "?lang=\(App.languageID ?? "")"
        return path
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post // 默认 post
        }
    }
    
    var sampleData: Data { // 单元测试用
        return Data()
    }
    
    var task: Task {
        var parameters = [String:String]()
        switch self {
        case let .home(address):
            parameters["address"] = address
        case let .transactionList(address,contractAddress,symbol,chainID,transType,page):
            parameters["address"] = address
            parameters["contractAddress"] = contractAddress
            parameters["symbol"] = symbol
            parameters["chain_id"] = chainID
            parameters["type"] = "\(transType.rawValue)"
            parameters["p"] = page.string
        case let .assetList(address):
            parameters["address"] = address
        case let .assetBind(address, contractAddress, isBind, symbol,isBindAll,chainID):
            parameters["address"] = address
            parameters["contract_address"] = contractAddress
            parameters["flag"] = isBind ? "1":"2"
            parameters["symbol"] = symbol
            parameters["signed_address"] = AElfWallet.walletAccount().signedAddress
            parameters["public_key"] = AElfWallet.walletAccount().publicKey
            parameters["init"] = isBindAll ? "1":"0" // 默认0，单链绑定； = 1全部绑定。
            parameters["chainid"] = chainID
        case .notice:
            break
        case let .transfer(address, amount, note):
            parameters["address"] = address
            parameters["amount"] = "\(amount)"
            parameters["note"] = note
        case let .getMyBanlance(address, contractAddress, symbol, chainID):
            parameters["address"] = address
            parameters["contractAddress"] = contractAddress
            parameters["symbol"] = symbol
            parameters["chainid"] = chainID
        case let .transferDetail(address, txid, fromChainID):
            parameters["address"] = address
            parameters["txid"] = txid
            if let fromChainID = fromChainID {
                parameters["chainid_c"] = fromChainID
            }
        case .crossChains:
            break
        case let .allChains(address,type):
            parameters["address"] = address
            parameters["type"] = type.string
        case let .sendTransaction(txID, fromChain, fromAddress, toChain, toAddress, symbol, amount, memo):
            parameters["txid"] = txID
            parameters["from_chain"] = fromChain
            parameters["from_address"] = fromAddress
            parameters["to_chain"] = toChain
            parameters["to_address"] = toAddress
            parameters["symbol"] = symbol
            parameters["amount"] = amount.string
            parameters["memo"] = memo
        case let .checkUnConfirmedTransaction(address):
            parameters = ["address": address]
        case let .linkTransactionID(fromTxID,toTxID):
            parameters = ["txid_from": fromTxID,"txid_to":toTxID]
        }
        
        logInfo("\n \(self.path)\n请求参数：\(parameters)\n")
        parameters.rsaEncode()
        
        parameters.addIfNotExist(dict: BaseConfig.baseParameters())
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return BaseConfig.headers
    }
    
    
}
