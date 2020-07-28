//
//  AssetViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/4.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class AssetViewModel: ViewModel {
    
}

extension AssetViewModel: ViewModelType {
    
    struct Input {
        let address: BehaviorRelay<String>
        let chainIDChanged: BehaviorRelay<Void>
        let headerRefresh: Observable<Void>
    }
    
    struct Output {
        var items = BehaviorRelay<[AssetItem]>(value: [])
        let total = PublishSubject<NSAttributedString>()
    }
    
    func transform(input: AssetViewModel.Input) -> AssetViewModel.Output {
        
        let output = Output()
        
//        Observable
//            .combineLatest(input.address.filter({ $0.length > 0}),
//                           input.chainIDChanged,
//                           input.headerRefresh)
//            .flatMapLatest { [weak self] (address,_,v) -> Observable<[AssetItem]> in
//                
//                
//                
//        }.subscribe(onNext: { [weak self] results in
//            guard let self  = self else { return }
//            output.total.onNext(self.totalPrice(assert(results)))
//            output.items.accept(results)
//        }).dispose(by: rx.disposeBag)

        
        // 头部刷新
        Observable
            .combineLatest(input.address.filter({ $0.length > 0 }),
                           input.chainIDChanged,
                           input.headerRefresh)
            .flatMapLatest { [weak self] (address,_,v) -> Observable<[AssetItem]> in
                guard let self = self else { return Observable.just([]) }
                return self.requestAssets(address: address)
                    .trackActivity(self.headerLoading)
                    .catchErrorJustComplete()
        }.subscribe(onNext: { [weak self] results in
            guard let self = self else { return }
            
//            output.total.onNext(self.totalPrice(assets: results))
//            output.items.accept(results)
           // let res = self.loadAssetItemPrices(items: results)
            self.loadAssetItemPrices(items: results).subscribe(onNext: { res in
                output.total.onNext(self.totalPrice(assets: res))
                output.items.accept(res)
//                output.items = res
            }).disposed(by: self.rx.disposeBag)
            
//            output.total.onNext(self.totalPrice(assets: res))
//            output.items.accept(res)
            
        }).disposed(by: rx.disposeBag)
        
        return output
    }
    
    func totalPrice(assets: [AssetItem]) -> NSAttributedString {
        
        func resultAttribute(total: String) -> NSAttributedString {
            
            let totalNum = classfuncdeleteInvalidNum(num: total)
            
            let totalAtt = totalNum.withFont(.systemFont(ofSize: 26,
                                                      weight: .semibold)).withTextColor(.white)
            let currencyAtt = (" " + App.currency).withFont(.systemFont(ofSize: 16,weight: .semibold)).withTextColor(.white)
            totalAtt.append(currencyAtt)
            return totalAtt
        }
        
        if App.isPrivateMode {
            return resultAttribute(total: "*****")
        }
        
        var total: Double = 0.00
        for i in assets {
            total += i.total()
        }

        return resultAttribute(total: total.format(maxDigits: 2, mixDigits: 2))
    }
    
    func classfuncdeleteInvalidNum(num: String) -> String {
        var outNumber = num
        var i = 1
        if num.contains(".") {
            while i < num.count {
                if outNumber.hasPrefix("0") {
                    outNumber.remove(at: outNumber.index(before: outNumber.endIndex))
                    i = i + 1
                } else {
                    break
                }
            }
            if outNumber.hasSuffix(".") {
                outNumber.remove(at: outNumber.index(before: outNumber.endIndex))
            }
            return outNumber
        } else {
            return num
        }
    }

    
    func requestAssets(address: String) -> Observable<[AssetItem]> {
        
        if App.assetMode == .chain {
            return Observable.create { observer in
                let t = assetProvider.rx.onCache(.home(address: address),
                                                 type: VResult.self) { (obj) in
                                                    if let ass = try? obj.mapObject(Asset.self) {
                                                        observer.onNext(ass.list)
                                                    }
                                                    logInfo("资产请求缓存：\(obj)")
                }.request()
                    .trackActivity(self.loading)
                    .mapObject(Asset.self)
                    .trackError(self.error)
                    .subscribe(onNext: { ass in
                        observer.onNext(ass.list)
                        observer.onCompleted()
                    })
                return Disposables.create {
                    t.dispose()
                }
            }
        } else {
            
            return Observable.create { observer in
                
                let t = assetProvider.rx.onCache(.allChains(address: App.address, type: 1),
                                                 type: VResult.self)
                { (obj) in
                    if let res = try? obj.mapObjects(AssetItem.self) {
                        observer.onNext(res)
                    }
                }.request()
                    .trackActivity(self.loading)
                    .mapObjects(AssetItem.self)
                    .trackError(self.error)
                    .subscribe(onNext: { result in
                        observer.onNext(result)
                        observer.onCompleted()
                    })
                return Disposables.create {
                    t.dispose()
                }
            }
        }
        
    }
    
    func loadAssetItemPrices(items:[AssetItem]) ->  Observable<[AssetItem]> {
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
                })
            return Disposables.create {
                t.dispose()
            }
        }
    }
    func noticeData() -> Observable<AssetNoticeList> {
        return assetProvider.requestData(.notice).mapObject(AssetNoticeList.self)
    }
    
    func requestUnRead(address: String) -> Observable<MessageUnReadModel> {
        return userProvider
            .requestData(.messageUnRead(address: address))
            .mapObject(MessageUnReadModel.self)
    }
    
    func requestUnconfirmTransaction(address: String) -> Observable<UnConfirmTransaction> {
        return assetProvider
            .requestData(.checkUnConfirmedTransaction(address: address))
            .mapObject(UnConfirmTransaction.self)
    }
    
    
}
