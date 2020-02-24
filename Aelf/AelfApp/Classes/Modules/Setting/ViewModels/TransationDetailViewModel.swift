//
//  TransationDetailViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/24.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class TransationDetailViewModel: ViewModel {
    
}

extension TransationDetailViewModel: ViewModelType {
    
    struct Input {
        let address : String
        let txId: String
        let fromChainID: String?
        let fetchDetail: Observable<Void>
    }
    
    struct Output {
        let item = PublishSubject<AssetHistory>()
    }
    
    func transform(input: TransationDetailViewModel.Input) -> TransationDetailViewModel.Output {
        
        let out = Output()
        
        input.fetchDetail.flatMapLatest({ [weak self] _ -> Observable<AssetHistory> in
            guard let self = self else { return Observable.just(AssetHistory(JSON: [:])!)}
            return self.requestTransactionDetail(address: input.address,
                                                 txid: input.txId,
                                                 fromChainID: input.fromChainID)
                .trackActivity(self.headerLoading)
        }).bind(to: out.item).disposed(by: rx.disposeBag)
        
        return out
    }
    
}


extension TransationDetailViewModel {
    
    func requestTransactionDetail(address: String,
                                  txid:String,
                                  fromChainID: String?) -> Observable<AssetHistory> {
        return assetProvider
            .requestData(.transferDetail(address: address,
                                         txid: txid,
                                         fromChainID: fromChainID))
            .mapObject(AssetHistory.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
    
}
