//
//  DappSearchViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/16.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class DappSearchViewModel: ViewModel {
    
}


extension DappSearchViewModel: ViewModelType {
    
    struct Input {
        let searchText: Driver<String>
        let items: [DiscoverDapp]
        let headerRefresh: Observable<()>
    }
    
    struct Output {
        let items = BehaviorRelay<[DiscoverDapp]>(value: [])
    }
    
    func transform(input: DappSearchViewModel.Input) -> DappSearchViewModel.Output {
        
        let out = Output()
        
        out.items.accept(input.items)
        
        Observable.combineLatest(input.searchText.asObservable(), input.headerRefresh)
            //            .filter({ $0.0.count > 0 })
            .throttle(0.25, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] (text,_) -> Observable<[DiscoverDapp]> in
                guard let self = self else { return Observable.just([]) }
                return self.requestSearchGames(name: text).trackActivity(self.headerLoading)
        }.subscribe(onNext: { items in
            out.items <= items
        }).disposed(by: rx.disposeBag)
        
        
        return out
    }
    
}

extension DappSearchViewModel {
    
    func requestSearchGames(name: String) -> Observable<[DiscoverDapp]> {
        return discoverProvider
            .requestData(.gamelist(page: page,
                                   cat: "0",
                                   coin: nil,
                                   name: name,
                                   isPopular: false,
                                   isRecommand: nil))
            .trackError(self.error)
            .trackActivity(self.loading)
            .mapObject(DappList.self).map({ $0.dapps })
    }
}
