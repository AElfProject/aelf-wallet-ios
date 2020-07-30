//
//  AssetDetailItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/27.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

struct AssetDetailItem {
    var symbol: String
    var chainID: String
    var contractAddress: String
    var decimals: String

    //
    var price: Double
    var logo: String?

    init(symbol: String, chainID: String, contractAddress: String, price: Double = 0, logo: String? = nil, decimals: String) {
        self.symbol = symbol
        self.chainID = chainID
        self.contractAddress = contractAddress
        self.price = price
        self.logo = logo
        self.decimals = decimals
    }
}
