//
//  CrossChainsViewModel.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/9/25.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class CrossChainsViewModel: ViewModel {
    
    private var origins = [AssetItem]()
    
}

extension CrossChainsViewModel: ViewModelType {
    
    struct Input {
        let search: Driver<String>
        let symbol: String?
        let headerRefresh: Observable<()>
    }
    
    struct Output {
        let items = BehaviorRelay<[AssetItem]>(value: [])
        let totalAmount = PublishSubject<String>()
        let totalPrice = PublishSubject<String>()
    }
    
    func transform(input: CrossChainsViewModel.Input) -> CrossChainsViewModel.Output {
        
        let out = Output()
        input.search.throttle(0.3).distinctUntilChanged().map({ [weak self] value -> [AssetItem] in
            guard let self = self else { return [] }
            return self.filterSearchResult(value)
        }).asObservable().bind(to: out.items).disposed(by: rx.disposeBag)
        
        
        input.headerRefresh.flatMapLatest({ [weak self] _ -> Observable<[AssetItem]> in
            guard let self = self else { return Observable.just([]) }
            return self.requestChains()
                .trackActivity(self.headerLoading)
                .catchErrorJustComplete()
        }).subscribe(onNext: { [weak self] items in
            guard let self = self else { return }
            
            //var results = items
            self.loadAssetItemPrices(items: items).subscribe(onNext: {[weak self] items in
                var result = items
                if let symbol = input.symbol, !symbol.isEmpty { // 如果有 symbol，则过滤取 == symbol 的数据。
                    result = items.filter{ $0.symbol == symbol }
                }
                
                let amount = result.reduce(0, { $0 + $1.balanceDouble() })
                let price = result.reduce(0, { $0 + $1.total() })
                out.totalAmount.onNext("\(amount.format())")
                out.totalPrice.onNext(String(format: "%.2f \(App.currency)", price))
                
                if App.assetMode == .chain { // 按链
                    var items = [AssetItem]()
                    result.forEach({ c in
                        if c.isMain() { //
                            var item = c
                            let filters = result.filter({ c.chainID == $0.chainID })
                            let amount = filters.reduce(0, { $0 + $1.balanceDouble() })
                            let price = filters.reduce(0, { $0 + $1.total() })
                            item.totalAmount = Double(amount)
                            item.totalPrice = price
                            items.append(item)
                        }
                    })
                    result = items
                }
                
                self?.origins = result.sorted(by: { $0.chainID < $1.chainID }) // 排序
                out.items.accept(result)
                
            }).disposed(by: self.rx.disposeBag)
            
            }, onError: {error in
                logError(error)
        }) .disposed(by: rx.disposeBag)
        
        return out
    }
    
    func filterSearchResult(_ text: String?) -> [AssetItem] {
        guard let text = text,text.length > 0 else { return origins }
        return origins.filter({ $0.chainID.contains(text, caseSensitive: false) || $0.symbol.contains(text, caseSensitive: false) }) // 不区分大小写
    }
    func loadAssetItemPrices(items:[AssetItem]) -> Observable<[AssetItem]> {
        //let items = AssetItem ?? []
        
        // 多个 coin name 以逗号拼接
        // let ids = items.map({ $0.symbol.lowercased() }).compactMap({ $0 }).joined(separator: ",")
        var items = items
        let ids = "aelf";
        return Observable.create { observer in
            let t = marketProvider
                .requestData(.markList(currency: App.currency, ids: ids, order: 0, perPage: 10, page: self.page))
                .mapObjects(MarketCoinModel.self).subscribe(onNext: { result in
                    
                    for i in 0 ..< items.count {
                        var item = items[i]
                        for coin in result {
                            if item.symbol.lowercased() == coin.symbol?.lowercased() {
                                item.rate?.price = coin.lastPrice ?? "0"
                                items[i] = item
                            }
                        }
                    }
                    observer.onNext(items)
                    observer.onCompleted()
                    // return items
                })
            return Disposables.create {
                t.dispose()
            }
        }
        
    }
    
//    func requestKLine(input: Input) -> Observable<MarketTradeModel> {
//        return marketProvider.requestData(.tradeKline(id: input.name, currency: input.currency, days:String(try! input.time.value())))
//            .mapObject(MarketTradeModel.self)
//            .trackActivity(self.loading)
//            .trackError(self.error)
//    }
    
    func requestChains() -> Observable<[AssetItem]> {
        
        return Observable.create { observer in
            let t = assetProvider.requestData(.allChains(address: App.address, type: 0))
                .mapObjects(AssetItem.self)
            .subscribe(onNext: {results in
                observer.onNext(results)
                observer.onCompleted()
            }, onError: {error in
                observer.onError(error)
                observer.onCompleted()
                logError(error)
            })
            return Disposables.create {
                t.dispose()
            }
        }
        
//        return Observable.create { observer in
//            let t = assetProvider.requestData(.allChains(address: App.address, type: 0))
//                .mapObjects(AssetItem.self)
//                .subscribe(onNext: {results in
////                    guard let self = self else { return }
//                    observer.onNext(results)
//                    observer.onCompleted()
//                })
//            return Disposables.create {
//                t.dispose()
//            }
//        }
            
           
        
//        return Observable.create { observer in
//            let t = assetProvider.rx.onCache(.allChains(address: App.address, type: 0),
//                                             type: VResult.self)
//            { (obj) in
//                if let res = try? obj.mapObjects(AssetItem.self) {
//                    observer.onNext(res)
//                }
//            }.request()
//                .trackActivity(self.loading)
//                .mapObjects(AssetItem.self)
//                .trackError(self.error)
//                .subscribe(onNext: { [weak self] results in
//                    //  guard let self = self else { return }
//                    observer.onNext(results)
//                    observer.onCompleted()
//
//                })
//            return Disposables.create {
//                t.dispose()
//            }
//        }
    }
    
}
