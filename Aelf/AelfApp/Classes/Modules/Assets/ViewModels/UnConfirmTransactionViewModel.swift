//
//  UnConfirmTransactionViewModel.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/1.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class UnConfirmTransactionViewModel: ViewModel {
    
}


extension UnConfirmTransactionViewModel: ViewModelType {

    struct Input {
        let address: String
        let headerRefresh: Observable<Void>
        let fetchChains: Observable<Void>

    }

    struct Output {
        let items = BehaviorRelay<[UnConfirmTransactionItem]>(value: [])
        let chains = BehaviorRelay<[ChainItem]>(value: [])
    }

    func transform(input: UnConfirmTransactionViewModel.Input) -> UnConfirmTransactionViewModel.Output {

        let out = Output()

        input.headerRefresh
            .flatMapFirst { [weak self] v -> Observable<UnConfirmTransaction> in
                guard let self = self else { return Observable.just(UnConfirmTransaction(JSON: [:])!)}
                return self.requestUnConfirmItems(address: input.address).trackActivity(self.headerLoading)
        }.subscribe(onNext: { item in
            out.items <= item.list
        }).disposed(by: rx.disposeBag)
        
        input.fetchChains.flatMapLatest { [weak self] _ -> Observable<[ChainItem]> in
               guard let self = self else { return  Observable.just([]) }
               return self.requestChains()
        }.subscribe(onNext: { items in
            out.chains <= items
        }).disposed(by: rx.disposeBag)


        return out
    }
}

extension UnConfirmTransactionViewModel {
    
    private func requestUnConfirmItems(address: String) -> Observable<UnConfirmTransaction> {
        return  assetProvider.requestData(.checkUnConfirmedTransaction(address: address))
            .mapObject(UnConfirmTransaction.self)
            .trackActivity(loading)
            .trackError(error)
    }
    
    private func requestChains() -> Observable<[ChainItem]> {
        return assetProvider
            .requestData(.crossChains)
            .trackError(error)
            .trackActivity(loading)
            .mapObjects(ChainItem.self)
    }

    func requestLinkTransaction(fromTxID: String, toTxID: String) -> Observable<VResult> {
        return  assetProvider.requestData(.linkTransactionID(fromTxID: fromTxID, toTxID: toTxID))
            .trackActivity(loading)
            .trackError(error)
    }

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
    
}
