//
//  MarketFavouritesViewModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class MarketFavouritesViewModel: ViewModel {

}

extension MarketFavouritesViewModel: ViewModelType {

    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
    }

    struct Output {
        let items = PublishSubject<[MarketCoinModel]>()
    }

    func transform(input: MarketFavouritesViewModel.Input) -> MarketFavouritesViewModel.Output {

        let output = Output()

        input.headerRefresh
            .flatMapLatest( { [weak self] _ -> Observable<[MarketCoinModel]> in
                guard let self = self else { return Observable.just([]) }
                return self.loadFavourites(isFirst: true).trackActivity(self.headerLoading) })
            .map({ $0 })
            .bind(to: output.items)
            .disposed(by: rx.disposeBag)
        return output
    }
}


extension MarketFavouritesViewModel {

    func loadFavourites(isFirst: Bool) -> Observable<[MarketCoinModel]> {
        let items = MarketCoinModel.getCoins() ?? []

        let idList = items.map({ $0.identifier?.lowercased() })
        // 多个 coin name 以逗号拼接
        let ids = idList.compactMap({ $0 }).joined(separator: ",")
        
        if ids.length == 0 {
            return Observable.just([])
        } else {
            return Observable.create { observer in
                let t = marketProvider
                    .requestData(.markList(currency: App.currency, ids: ids, order: -1, perPage: 10, page: self.page))
                    .mapObjects(MarketCoinModel.self)
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .subscribe(onNext: { result in
                        var marketList = result
                        marketList.sort { (c1, c2) -> Bool in
                            return !((idList.firstIndex { (id) -> Bool in
                                return id == c1.identifier?.lowercased()
                            }?.double ?? 0.0) > (idList.firstIndex { (id) -> Bool in
                                return id == c2.identifier?.lowercased()
                            }?.double ?? 0.0))
                        }
                        observer.onNext(marketList)
                        observer.onCompleted()
                    })
                return Disposables.create {
                    t.dispose()
                }
            }
        }
    }
}
