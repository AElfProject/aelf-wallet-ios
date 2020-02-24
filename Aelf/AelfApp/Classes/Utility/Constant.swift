//
//  AppConst.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 AELF. All rights reserved.
//

// 屏幕宽高
let screenBounds = UIScreen.main.bounds
let screenWidth = screenBounds.width
let screenHeight = screenBounds.height

let isIphoneX = UIApplication.shared.statusBarFrame.height == 44

let iPHONE_NAVBAR_HEIGHT :CGFloat = isIphoneX ? 88:64
let iPHONE_TABBAR_HEIGHT :CGFloat = isIphoneX ? 83:49
let iPHONE_STATUS_HEIGHT :CGFloat = isIphoneX ? 44:20
let iPHONE_BOTTOM_HEIGHT :CGFloat = isIphoneX ? 34:0

//let itunesURLString = "https://itunes.apple.com/cn/app/id\(appStoreID)"

struct Define {
    static let decimals = 8 // AElf  精度8位
    static let decimalsValue = Double(1e8) // AELF 精度8位
    static let defaultChainID = "AELF"
    static let elfPrefix = "ELF"
}

let enableDeBugKit = true

struct NotificationName {
    static let updateAssetData = NSNotification.name("updateAssetData") // 导入/创建钱包成功调用
    static let currencyDidChange = NSNotification.name("currencyDidChange") // 展示币种发生变化调用
    static let assetDisplayModeChange = NSNotification.name("assetDisplayModeChange") // 资产展示方式发生变化调用, by token/chain
}
