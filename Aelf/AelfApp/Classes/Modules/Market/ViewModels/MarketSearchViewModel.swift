//
//  MarketSearchViewModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/6.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class MarketSearchViewModel: ViewModel {
    
    private var searchText: String?
}

extension MarketSearchViewModel: ViewModelType {
    
    struct Input {
        let searchText: Driver<String>
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let loadData: Observable<Void>
    }
    
    struct Output {
        let items = BehaviorRelay<[MarketCoinModel]>(value: [])
    }
    
    func transform(input: MarketSearchViewModel.Input) -> MarketSearchViewModel.Output {
        
        let out = Output()
        
        Observable.merge(input.loadData)
            .flatMapLatest({ [weak self] _ -> Observable<MarketModel> in
                guard let self = self else { return Observable.just(MarketModel(JSON: [:])!)}
                return self.requestSearchResults()
                    .trackActivity(self.headerLoading) })
            .map({ $0.list })
            .bind(to: out.items)
            .disposed(by: rx.disposeBag)
        
        input.footerRefresh
            .flatMapLatest({ () -> Observable<MarketModel> in
                self.page += 1
                return self.requestSearchResults().trackActivity(self.footerLoading) })
            .subscribe(onNext: { result in
                out.items <= out.items.value + result.list
            }).disposed(by: rx.disposeBag)
        
        return out
    }
}

extension MarketSearchViewModel {
    
    func requestSearchResults() -> Observable<MarketModel> {
        return marketProvider
            .requestData(.coinList)
            .mapObject(MarketModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
