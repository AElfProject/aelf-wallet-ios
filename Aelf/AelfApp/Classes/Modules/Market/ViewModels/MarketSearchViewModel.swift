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
    }
    
    struct Output {
        let items = BehaviorRelay<[MarketCoinModel]>(value: [])
    }
    
    func transform(input: MarketSearchViewModel.Input) -> MarketSearchViewModel.Output {
        
        let out = Output()
        
        //        input.searchText
        //            .throttle(0.3)
        //            .distinctUntilChanged()
        //            .asObservable()
        //            .flatMapLatest({ [weak self] text -> Observable<MarketModel> in
        //                guard let self = self else { return Observable.just(MarketModel(JSON: [:])!)}
        //                self.searchText = text
        //                self.page = 1
        //               return self.requestSearchResults()
        //                                 .trackActivity(self.headerLoading) })
        //            .map({ $0.list })
        //            .bind(to: out.items)
        //            .disposed(by: rx.disposeBag)
        //
        //        input.headerRefresh
        //            .flatMapLatest({ [weak self] () -> Observable<MarketModel> in
        //                guard let self = self else { return Observable.just(MarketModel(JSON: [:])!)}
        //                self.page = 1
        //                return self.requestSearchResults().trackActivity(self.headerLoading) })
        //            .map({ $0.list })
        //            .bind(to: out.items)
        //            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(input.searchText.throttle(0.3).distinctUntilChanged().asObservable(),
                                 input.headerRefresh)
            .flatMapLatest({ [weak self] (text,_) -> Observable<MarketModel> in
                guard let self = self else { return Observable.just(MarketModel(JSON: [:])!)}
                self.searchText = text
                self.page = 1
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
            .requestData(.markList(currency: "usd", ids: "", perPage: 20, page: 1, sparkLine: false, priceChangePercentage: ""))
            .mapObject(MarketModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
