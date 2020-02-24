//
//  WalletAccount.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/12.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper

struct KeyStoreResult: Mappable {
    
    var keyStore : String = ""
    var success : Int = 0
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        keyStore <- map["keystore"]
        success <- map["success"]
    }

    var isOk: Bool {
        return success == 1
    }
}

struct TransferResult: Mappable {
    
    var txId : String = ""
    var success : Int  = 0
    var err : String = ""
    var params: Any?
    var data: Any?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        txId <- map["txId"]
        err <- map["err"]
        success <- map["success"]
        params <- map["params"] // getTxResult 方法用到
        data <- map["data"]
    }
    
    var isOk: Bool {
        return success == 1
    }
}

struct DappResult: Mappable {
    
    var id : String = ""
    var success : Int  = 0
    var err : String = ""
    var data: Any?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        err <- map["err"]
        success <- map["success"]
        data <- map["data"]
    }
    
    var isOk: Bool {
        return success == 1
    }
}

struct KeyPairResult: Mappable {
    
    var success : Int  = 0
    var err : String = ""
    var params: Any?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        err <- map["err"]
        success <- map["success"]
        params <- map["params"]
    }
    
    var isOk: Bool {
        return success == 1
    }
}


struct WalletResult: Mappable {

    var publicKey : String = ""
    var signedAddress : String = ""
    var privateKey : String = ""
    var address : String = ""

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        privateKey <- map["privateKey"]
        address <- map["address"]
        publicKey <- map["publicKey"]
        signedAddress <- map["signedAddress"]
    }
    
}

class WalletAccount : NSObject,NSCoding{
    var accoutName : String
    var address : String
    var privateKey : String
    var mnemonic : String
    var keyStore : String
    var pwd : String

    var hint : String
    var publicKey : String
    var signedAddress : String
    required override init() {
        address = ""
        privateKey = ""
        mnemonic = ""
        keyStore = ""
        pwd = ""
        accoutName = ""
        hint = ""
        publicKey = ""
        signedAddress = ""
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        publicKey = aDecoder.decodeObject(forKey: "publicKey") as? String ?? ""
        signedAddress = aDecoder.decodeObject(forKey: "signedAddress") as? String ?? ""
        address = aDecoder.decodeObject(forKey: "address") as? String ?? ""
        privateKey = aDecoder.decodeObject(forKey: "privateKey") as? String ?? ""
        mnemonic = aDecoder.decodeObject(forKey: "mnemonic") as? String ?? ""
        keyStore = aDecoder.decodeObject(forKey: "keyStore") as? String ?? ""
        pwd = aDecoder.decodeObject(forKey: "pwd") as? String ?? ""
        accoutName = aDecoder.decodeObject(forKey: "accoutName") as? String ?? ""
        hint = aDecoder.decodeObject(forKey: "hint") as? String ?? ""
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    @objc func encode(with aCoder: NSCoder)
    {
        aCoder.encode(publicKey, forKey: "publicKey")
        aCoder.encode(signedAddress, forKey: "signedAddress")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(mnemonic, forKey: "mnemonic")
        aCoder.encode(keyStore, forKey: "keyStore")
        aCoder.encode(pwd, forKey: "pwd")
        aCoder.encode(accoutName, forKey: "accoutName")
        aCoder.encode(hint, forKey: "hint")
    }

    
}
