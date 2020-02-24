//
//  AddAssetViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/9.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import ObjectMapper
import Moya_ObjectMapper

class AddAssetViewModel: ViewModel {

}

extension AddAssetViewModel: ViewModelType {

    struct Input {
        let headerRefresh: Observable<Void>
        let unbindTrigger: Observable<AssetInfo>
        let searchText: Driver<String>
        let address: String
    }

    struct Output {
        let results: BehaviorRelay<[AssetInfo]>
    }

    func transform(input: AddAssetViewModel.Input) -> AddAssetViewModel.Output {

        var originList = [AssetInfo]()
        let results = BehaviorRelay<[AssetInfo]>(value: [AssetInfo]())

        input.headerRefresh.flatMapLatest { _ in
            return self.request(address: input.address)
                .trackActivity(self.headerLoading)
                .catchErrorJustComplete()
            }.subscribe(onNext: { result in

              let chainID = App.assetMode == AssetDisplayMode.chain ? App.chainID:nil
                
                let v = AssetInfo.transformFromJSON(result.data)
                var infos = [AssetInfo]()
                if let chainID = chainID {
                    let filter = v.filter{ $0.key.lowercased() == chainID.lowercased() }
                    infos = filter.first?.value ?? []
                }else {
                    v.map({ $0.value }).forEach{ infos.append(contentsOf: $0) }
                }
        
                let filterResult = self.filtetrIsAdded(values: infos)
                originList = filterResult // save origin list
                results.accept(filterResult)

            }).disposed(by: rx.disposeBag)

        input.searchText.do(onNext: { text in
            if text.isEmpty {
                results.accept(originList) // if = 0,set origin list, return .
            }
        }).filter({ $0.count > 0}).asObservable()
            .flatMapLatest { return Observable.just($0) }
            .subscribe(onNext: { result in
                let filter = self.filterSymbol(result, from: originList)
                results.accept(filter)
            }).disposed(by: rx.disposeBag)
        
        input.unbindTrigger.subscribe(onNext: { asset in
            
            var values = [AssetInfo]()
            for v in results.value {
                var item = v
                if item.isEqual(item: asset) {
                    item.aIn = 0
                }
                values.append(item)
            }
            results.accept(values)
            
        }).disposed(by: rx.disposeBag)

        return Output(results: results)
    }

    func request(address: String) -> Observable<VResult> {
        
        return Observable.create { observer in
            let t = assetProvider.rx.onCache(.assetList(address: address),
                                             type: VResult.self)
            { (obj) in
                observer.onNext(obj)
            }.request()
                .trackActivity(self.loading)
                .trackError(self.error)
                .subscribe(onNext: { result in
                    observer.onNext(result)
                    observer.onCompleted()
                })
            return Disposables.create {
                t.dispose()
            }
        }
        
//        return assetProvider
//            .requestData(.assetList(address: address))
//            .trackActivity(loading)
//            .trackError(error)
    }
    
}

extension AddAssetViewModel {

    // cancel bind asset
    func assetBind(address: String,contractAddress: String,symbol: String,chainID: String) -> Observable<VResult> {
        return assetProvider.requestData(.assetBind(address: address,
                                                    contractAddress: contractAddress,
                                                    isBind: true,
                                                    symbol: symbol,
                                                    isBindAll: false,chainID: chainID))
            .trackError(error)
            .trackActivity(loading)
    }

    func filtetrIsAdded(values: [AssetInfo]) -> [AssetInfo] {

        var sort = Array(values)
        sort.sort(by: {
            if let a = $0.aIn,let b = $1.aIn {
                return a > b
            }
            return false
        })
        return sort
    }

    func filterSymbol(_ searchKey: String, from values: [AssetInfo]) -> [AssetInfo] {
        
        let result = values.filter({
            let s = $0.symbol.lowercased()
            let chainID = $0.chainID.lowercased()
            return s.contains(searchKey.lowercased()) || chainID.contains(searchKey.lowercased())
        })
        return result
    }
}
