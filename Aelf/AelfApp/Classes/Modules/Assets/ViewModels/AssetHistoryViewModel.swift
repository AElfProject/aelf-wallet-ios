//
//  AssetHistoryViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class AssetHistoryViewModel: ViewModel {
    
}

extension AssetHistoryViewModel: ViewModelType {
    
    struct Input {
        let address: String
        let contractAddress: String
        let symbol: String
        let chainID: String
        let transType: TransactionType
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }
    
    struct Output {
        let items = BehaviorRelay<[AssetHistory]>(value: [])
    }
    
    func transform(input: AssetHistoryViewModel.Input) -> AssetHistoryViewModel.Output {
        
        let out = Output()
        input.headerRefresh
            .flatMapLatest { [weak self] v -> Observable<[AssetHistory]> in
                guard let self = self else { return Observable.just([]) }
                self.page = 1
                return self.request(input: input).trackActivity(self.headerLoading)
        }.bind(to: out.items).disposed(by: rx.disposeBag)
        
        input.footerRefresh
            .flatMapLatest { [weak self] v -> Observable<[AssetHistory]> in
                guard let self = self else { return Observable.just([]) }
                self.page += 1
                return self.request(input: input).trackActivity(self.footerLoading)
        }.subscribe(onNext: { results in
            out.items.accept(out.items.value + results)
            logInfo("获取到了\(results.count)条数据，总共：\(out.items.value.count)条")
        }).disposed(by: rx.disposeBag)
        
        return out
    }
}

extension AssetHistoryViewModel {
    
    func request(input: Input) -> Observable<[AssetHistory]> {
        return assetProvider.requestData(.transactionList(address: input.address,
                                                          contractAddress: input.contractAddress,
                                                          symbol: input.symbol,
                                                          chainID: input.chainID,
                                                          transType: input.transType,
                                                          page: page))
            .mapObject(AssetHistoryData.self)
            .map({ $0.list ?? [] })
            .trackActivity(loading)
            .trackError(error)
    }
    
    //    func filterData(type: TransactionType, results: [AssetHistory]?) -> [AssetHistory] {
    //        guard let results = results else { return [] }
    //        switch type { // 根据 type 筛选
    //        case .all:
    //            return results
    //        case .receive:
    //            return results.filter { !$0.isTransfer() }
    //        case .transfer:
    //            return results.filter { $0.isTransfer() }
    //        }
    //    }
}
