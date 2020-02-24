//
//  AssetBalance.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/14.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper

struct AssetBalance: Mappable {

    var status : String?
    var transactionId : String?
    var balance : AssetBalanceItem?
    var fee : [AssetFee]?
    var rate : AssetRate?
    var usdRate : AssetRate?

    init?(map: Map){}

    mutating func mapping(map: Map) {
        status <- map["Status"]
        transactionId <- map["TransactionId"]
        balance <- map["balance"]
        fee <- map["fee"]
        rate <- map["rate"]
        usdRate <- map["usd_rate"]
    }

    func detailTitle() -> NSAttributedString {

        if App.isPrivateMode {
            let att = "*****".withFont(.systemFont(ofSize: 26, weight: .semibold)).withTextColor(.white)
            let str = "*****" + " \(App.currency)"
            let balanceAtt = ("\n≈ " + str).withFont(.systemFont(ofSize: 16, weight: .semibold)).withTextColor(.white)
            att.append(balanceAtt)
            return att
        }

        let usdTotal: Double = (balance?.balance?.double() ?? 0.00)

        let totalPrice = (balance?.balance?.double() ?? 0) * (rate?.price.double() ?? 0)

        let balanceAtt = "\(usdTotal.format(maxDigits: 2))".withFont(.systemFont(ofSize: 26, weight: .semibold)).withTextColor(.white)

        let eqAtt = ("\n≈").withFont(.systemFont(ofSize: 13, weight: .semibold)).withTextColor(.white)
        let priceAtt = totalPrice.format(maxDigits: 2).withFont(.systemFont(ofSize: 18, weight: .semibold)).withTextColor(.white)
        let currencyAtt = " \(App.currency)".withFont(.systemFont(ofSize: 13, weight: .semibold)).withTextColor(.white)

        balanceAtt.append(eqAtt)
        balanceAtt.append(priceAtt)
        balanceAtt.append(currencyAtt)

        return balanceAtt
    }
}

struct AssetBalanceItem: Mappable {

    var balance : String?
    var owner : String?
    var symbol : String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        balance <- map["balance"]
        owner <- map["owner"]
        symbol <- map["symbol"]
    }

    func headerTitle(symbolName:String?, chainID: String) -> NSAttributedString {

        let str = chainID + " " + "%@ Balance:".localizedFormat(symbolName ?? "ELF")

        let titleStr = str.withFont(.systemFont(ofSize: 15)).withTextColor(.white)

        let balanceStr = ("\n" + (balance ?? "0"))
        let balanceAtt = balanceStr.withFont(.systemFont(ofSize: 25, weight: .semibold)).withTextColor(.white)
        titleStr.append(balanceAtt)

        let symbolAtt = (" " + (symbolName ?? "ELF")).withFont(.systemFont(ofSize: 18)).withTextColor(.white)
        titleStr.append(symbolAtt)

        return titleStr
    }
}
