//
//  TransactionInfoItem.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/10/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

struct TransactionInfoItem {

    let amount: Double
    let symbol: String
    let fee: Double
    
    let toAddress: String
    let toChain: String
    let toNode: String
    
    let fromAddress: String
    let fromChain: String
    let fromNode: String
    
    let memo: String
    let txID: String


}
