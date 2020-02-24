//
//  AssetTransferViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import Validator

class AssetTransferViewModel: ViewModel {
    
}

extension AssetTransferViewModel: ViewModelType {
    
    struct Input {
        let symbol: String
        let address: String
        let contractAddress: String
        let chainID: String
        let refreshData: Observable<Void>
        let fetchChains: Observable<Void>
    }
    
    struct Output {
        let balance = PublishSubject<AssetBalance>()
        let chains = BehaviorRelay<[ChainItem]>(value: [])
        
    }
    
    func transform(input: AssetTransferViewModel.Input) -> AssetTransferViewModel.Output {
        let out = Output()
        
        input.refreshData.flatMapFirst({ [weak self] _ -> Observable<AssetBalance> in
            guard let self = self else { return Observable.just(AssetBalance(JSON: [:])!) }
            return self.requestMyBalance(address: input.address,
                                contractAddress: input.contractAddress,
                                symbol: input.symbol,chainID: input.chainID)
        }).bind(to: out.balance).disposed(by: rx.disposeBag)
        
        input.fetchChains.flatMapLatest { [weak self] _ -> Observable<[ChainItem]> in
            guard let self = self else { return  Observable.just([]) }
            return self.requestChains()
        }.bind(to: out.chains).disposed(by: rx.disposeBag)
        
        return out
    }
    
}


extension AssetTransferViewModel {
    
    func requestMyBalance(address: String,
                          contractAddress: String,
                          symbol: String,
                          chainID: String) -> Observable<AssetBalance> {
        return assetProvider
            .requestData(.getMyBanlance(address: address,
                                        contractAddress: contractAddress,
                                        symbol: symbol,
                                        chainID: chainID))
            .trackError(error)
            .trackActivity(loading)
            .mapObject(AssetBalance.self)
    }
    
    private func requestChains() -> Observable<[ChainItem]> {
        
        return assetProvider
            .requestData(.crossChains)
            .trackError(error)
            .trackActivity(loading)
            .mapObjects(ChainItem.self)
    }
}
