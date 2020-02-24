//
//  BaseWalletViewModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class BaseWalletViewModel: ViewModel {

}


extension BaseWalletViewModel {

    /// 调用bind接口添加默认绑定资产。
    ///
    /// - Parameter address: 传入 address
    /// - Returns: 返回结果。
    func bindDefaultAsset(address: String) -> Observable<VResult> {

        return assetProvider.requestData(.assetBind(address: address,
                                                    contractAddress: "",
                                                    isBind: true,
                                                    symbol: "ELF",
                                                    isBindAll: true,chainID: Define.defaultChainID))
    }



    /// 上传用户 tokenId，用于推送标识。
    ///
    /// - Parameters:
    ///   - address: 导入后的 address
    ///   - deviceId: device ID
    /// - Returns: 返回结果。
    func uploadDeviceInfo(address: String, deviceId: String) -> Observable<VResult> {
        return userProvider.requestData(.updateDeviceToken(address: address,
                                                           parent: "ELF",
                                                           iosNoticeToken: deviceId))
    }

    /// 上传此地址对应的用户昵称。
    ///
    /// - Parameters:
    ///   - name: 昵称。
    ///   - address: 地址。
    /// - Returns: 返回结果。
    func uploadUserName(_ name: String,address: String) -> Observable<VResult> {
        return userProvider.requestData(.identityEdit(address: address,
                                                      name: name,
                                                      img: nil))
    }
}
