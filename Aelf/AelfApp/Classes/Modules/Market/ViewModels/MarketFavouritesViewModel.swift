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

#warning("TODO")
//extension MarketFavouritesViewModel: ViewModelType {
//
//    struct Input {
//        let headerRefresh: Observable<Void>
////        let footerRefresh: Observable<Void>
//    }
//
//    struct Output {
//        let items = PublishSubject<[MarketCoinModel]>()
//    }

//    func transform(input: MarketFavouritesViewModel.Input) -> MarketFavouritesViewModel.Output {
//
//        let output = Output()
//        input.headerRefresh
//            .flatMapLatest( { [weak self] _ -> Observable<MarketModel> in
//                guard let self = self else { return Observable.just(MarketModel(JSON: [:])!) }
//               return self.loadFavourites(isFirst: true).trackActivity(self.headerLoading) })
//            .map({ $0.list })
//            .bind(to: output.items).disposed(by: rx.disposeBag)
//
//        return output
//    }

//}


#warning("TODO")
extension MarketFavouritesViewModel {

//    func loadFavourites(isFirst: Bool) -> Observable<MarketModel> {
//        let items = MarketCoinModel.getCoins() ?? []
//
//        // 多个 coin name 以逗号拼接
//        let coins = items.map({ $0.name?.lowercased() }).compactMap({ $0 }).joined(separator: ",")
//
//        return marketProvider
//            .requestData(.favouriteMarket(currency: App.currency,
//                                          coins: coins))
//            .mapObject(MarketModel.self)
//            .trackError(error)
//            .trackActivity(loading)
//    }
}
