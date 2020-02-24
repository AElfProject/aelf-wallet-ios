//
//  AssetDetailViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/22.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class AssetDetailViewModel: ViewModel {

}


extension AssetDetailViewModel: ViewModelType {

    struct Input {
        let symbol: String
        let address: String
        let contractAddress: String
        let chainID: String
        let refresh: Observable<Void>
    }

    struct Output {
        let balance = PublishSubject<AssetBalance>()
    }

    func transform(input: AssetDetailViewModel.Input) -> AssetDetailViewModel.Output {
        let out = Output()
        input.refresh
            .flatMapLatest({[weak self] _ -> Observable<AssetBalance> in
                guard let self = self else { return Observable.just(AssetBalance(JSON: [:])!)}
               return self.request(address: input.address,
                                          contractAddress: input.contractAddress,
                                          symbol: input.symbol,
            chainID: input.chainID) })
            .catchErrorJustReturn(AssetBalance(JSON: [:])!)
            .subscribe(onNext: { balance in
                out.balance <= balance
            }).disposed(by: rx.disposeBag)

        return out
    }
}

extension AssetDetailViewModel {

    func request(address: String,contractAddress: String,symbol: String,chainID: String) -> Observable<AssetBalance> {
        return assetProvider.requestData(.getMyBanlance(address: address,
                                                        contractAddress: contractAddress,
                                                        symbol: symbol,
                                                        chainID: chainID))
            .mapObject(AssetBalance.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
