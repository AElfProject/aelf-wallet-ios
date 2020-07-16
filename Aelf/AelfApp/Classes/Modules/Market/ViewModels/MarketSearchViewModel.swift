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
//        let headerRefresh: Observable<Void>
//        let footerRefresh: Observable<Void>
        let loadData: Observable<Void>
        let loadCoinData: Observable<Void>
    }
    
    class Output {
        let items = BehaviorRelay<[MarketCoinModel]>(value: [])
        var coinItems = BehaviorRelay<[MarketCoinListModel]>(value: [])
    }
    
    func transform(input: MarketSearchViewModel.Input) -> MarketSearchViewModel.Output {
        
        let out = Output()
        var totalIds:String = ""
        
        Observable.merge(input.loadCoinData)
            .flatMapLatest({ [weak self] _ -> Observable<[MarketCoinListModel]> in
                guard let self = self else { return Observable.just([]) }
                
                let list: Observable<[MarketCoinListModel]> = self.requestSearchResults()
                .trackActivity(self.headerLoading)
                
                return list
            })
            .bind(to: out.coinItems)
            .disposed(by: rx.disposeBag)
        
//        Observable.merge(input.loadData)
//            .flatMapLatest({ [weak self] _ -> Observable<[MarketCoinModel]> in
//                guard let self = self else { return Observable.just([]) }
//
//                return self.loadSearchCoinResult(ids: )
//                    .trackActivity(self.headerLoading)
//            })
//            .map({ $0 })
//            .bind(to: out.items)
//            .disposed(by: rx.disposeBag)

        input.searchText
            .throttle(1)
            .map({ [weak self] value -> String? in
                guard self != nil else {return ""}
                
                var ids: String = ""
                if value.length > 1 {
                    for model:MarketCoinListModel in out.coinItems.value {
                        if (model.symbol!.lowercased().hasPrefix(value.lowercased())) && !(model.name.isBlank) {
                            ids = ids + model.name! + ","
                            print(ids)
                        }
                    }
                }
                totalIds = ids
                print(totalIds)
                return ids
            })
            .asObservable()
            .flatMapLatest({ [weak self] _ -> Observable<[MarketCoinModel]> in
                guard self != nil else { return Observable.just([]) }
//                if totalIds.length > 0 { totalIds.remove(at: totalIds.index(before: totalIds.endIndex)) }
                return self!.loadSearchCoinResult(ids: totalIds)
                    .trackActivity(self!.headerLoading)
            })
            .bind(to: out.items)
            .disposed(by: rx.disposeBag)
            
//        input.footerRefresh
//            .flatMapLatest({ () -> Observable<MarketModel> in
//                self.page += 1
//                return self.requestSearchResults().trackActivity(self.footerLoading) })
//            .subscribe(onNext: { result in
//                out.items <= out.items.value + result.list
//            }).disposed(by: rx.disposeBag)
        
        return out
    }
}

extension String{
    
    /// check string cellection is whiteSpace
    var isBlank : Bool{
        return allSatisfy({$0.isWhitespace})
    }
}


extension Optional where Wrapped == String{
    var isBlank : Bool{
        return self?.isBlank ?? true
    }
}

extension MarketSearchViewModel {
    
    func requestSearchResults() -> Observable<[MarketCoinListModel]> {
        return marketProvider
            .requestData(.coinList)
            .mapObjects(MarketCoinListModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
    
    func loadSearchCoinResult(ids: String) -> Observable<[MarketCoinModel]> {
//        let items = MarketCoinModel.getCoins() ?? []
        
        // 多个 coin name 以逗号拼接
//        let ids = items.map({ $0.identifier?.lowercased() }).compactMap({ $0 }).joined(separator: ",")
        
        if ids.length == 0 {
            return Observable.just([])
        } else {
            return marketProvider
                .requestData(.markList(currency: App.currency, ids: ids, order: 1, perPage: 100, page: self.page))
                .mapObjects(MarketCoinModel.self)
                .trackError(self.error)
                .trackActivity(self.loading)
        }
    }
}
