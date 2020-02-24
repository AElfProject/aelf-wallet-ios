//
//  DappWallet.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/12.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

struct DappWallet {
    
    public typealias WalletCallback = (_ wallet:DappWallet?) -> Void
    
    let privateKey: String
    let publicKey: String
    
    // 记录在 connect 时候，从 dapp 的公钥，用于后面校验签名
    var dappPublicKey = ""
}

// TODO: func
extension DappWallet {
    
    /// 通过私钥，对 message 进行签名，返回签名后的数据 (signature )
    /// - Parameter message: 要签名的数据。
    func sign(message: String, callback: @escaping ((String?) -> ())) {
        AElfWallet.keyPairSign(message: message, privateKey: privateKey) { result in
            guard let result = result else {
                return callback(nil)
            }
            guard let params = result.params as? [String: String] else {
                return callback(nil)
            }
            
            guard let signature = params["signature"] else {
                return callback(nil)
            }
            
            callback(signature)
        }
    }
}

// TODO: Static func
extension DappWallet {
    
    /// 生成 Wallet 。
    static func generalDappWallet(_ callback: @escaping WalletCallback) {
        
        AElfWallet.generalKeyPair { result in
            
            guard let result = result else {
                return callback(nil)
            }
            
            guard let params = result.params as? [String: String] else {
                return callback(nil)
            }
            
            guard let privateKey = params["privateKey"],let publicKey = params["publicKey"] else {
                return callback(nil)
            }
            
            let wallet = DappWallet(privateKey: privateKey, publicKey: publicKey)
            callback(wallet)
        }
        
    }
    
    /// 通过公钥，验证原始数据是否为签名后的数据。
    /// - Parameters:
    ///   - signature: message 签名后的数据
    ///   - message: 原始数据
    ///   - publicKey: 公钥
    static func verify(signature: String, message: String,dappPublicKey: String, callback: @escaping ((Bool) -> ())) {
        
        AElfWallet.keyPairVerify(signature: signature, message: message, publicKey: dappPublicKey) { result in
            guard let result = result else {
                return callback(false)
            }
            
            guard let params = result.params as? [String: Any] else {
                return callback(false)
            }
            guard let resultValue = params["result"] as? Int else {
                return callback(false)
            }
            callback(resultValue == 1)
        }
    }
}
