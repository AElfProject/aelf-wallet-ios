//
//  EditAssetViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/13.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

enum AssetSortType: Int {
    case byValueSmallestToLargest
    case byValueLargestToSmallest
    case byNameAToZ
    case byNameZToA

    var localized: String {
        switch self {
        case .byValueSmallestToLargest: return "by Value (Smallest to Largest)".localized()
        case .byValueLargestToSmallest: return "by Value (Largest To Smallest)".localized()
        case .byNameAToZ: return "by Name (A To Z)".localized()
        case .byNameZToA: return "by Name (Z To A)".localized()
        }
    }
}

class EditAssetViewModel: ViewModel {

}

extension EditAssetViewModel: ViewModelType {

    struct Input {
        let address: String
        let searchText: Driver<String>
        let sortType: BehaviorSubject<AssetSortType>
        let headerRefresh: Observable<Void>
        let unbindTrigger: Observable<AssetInfo>
        let addTrigger: Observable<AssetInfo>
    }

    struct Output {
        let results: BehaviorRelay<[AssetInfo]>
    }

    func transform(input: EditAssetViewModel.Input) -> EditAssetViewModel.Output {

        let results = BehaviorRelay<[AssetInfo]>(value: [AssetInfo]())
        var originList = [AssetInfo]()

        // Sort
        input.sortType.asObservable().subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            results.accept(self.sortAssets(type: type, origins: results.value))
        }).disposed(by: rx.disposeBag)

        // Search
        input.searchText.do(onNext: { text in
            if text.count == 0 {
                results.accept(originList) // if = 0,set origin list, return .
            }
        }).filter({ $0.count > 0 }).asObservable().subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            let filter = self.filterSymbol(text, from: originList)
            if filter.isEmpty {
                results.accept([])
                self.parseError.onNext(ResultError.noData)
            }else {
                results.accept(filter)
            }
        }).disposed(by: rx.disposeBag)
        
        // delete
        input.unbindTrigger.subscribe(onNext: { asset in
            var originResults = results.value
            originResults.removeFirst(where: { $0.isEqual(item: asset) })
            results.accept(originResults)
            
        }).disposed(by: rx.disposeBag)
        
        // add
        input.addTrigger.subscribe(onNext: { asset in
            var values = results.value
            values.append(asset)
            results.accept(values)
        }).disposed(by: rx.disposeBag)
        
        // Refresh
        input.headerRefresh.flatMapLatest { [weak self] () -> Observable<VResult> in
            guard let self = self else { return Observable.just(VResult(JSON: [:])!) }
            return self.request(address: input.address).trackActivity(self.headerLoading).catchErrorJustComplete()
            }.subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let sort = self.parseResult(result,type: try? input.sortType.value())
                results.accept(sort)
                originList = sort // save origin list
        }).disposed(by: rx.disposeBag)

        return Output(results: results)
    }

    func parseResult(_ result: VResult,type: AssetSortType?) -> [AssetInfo] {
        
        let chainID = App.assetMode == AssetDisplayMode.chain ? App.chainID:nil
        let v = AssetInfo.transformFromJSON(result.data)
        var infos = [AssetInfo]()
        if let chainID = chainID {
            let filter = v.filter{ $0.key.lowercased() == chainID.lowercased() }
            infos = filter.first?.value ?? []
        }else {
            v.map({ $0.value }).forEach{ infos.append(contentsOf: $0) }
        }
        
        let filterValues = self.filterAdded(values: infos)
        let typeValue = type ?? .byNameAToZ
        let sort = self.sortAssets(type: typeValue, origins: filterValues)
        return sort
    }
}


extension EditAssetViewModel {

    func request(address: String) -> Observable<VResult> {
        
//        return assetProvider
//            .requestData(.assetList(address: address))
//            .trackError(self.error)
//            .trackActivity(self.loading)
//
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
        
    }
    // cancel bind asset
    func cancelBind(address: String,contractAddress: String,symbol: String,chainID: String) -> Observable<VResult> {
        let provider = assetProvider.requestData(.assetBind(address: address,
                                                            contractAddress: contractAddress,
                                                            isBind: false,
                                                            symbol: symbol,
                                                            isBindAll: false,
                                                            chainID:chainID))
        return provider
    }

    // is added
    func filterAdded(values: [AssetInfo]) -> [AssetInfo] {
        let sort = Array(values).filter({ $0.aIn == 1 })
        return sort
    }

    // is search symbol
    func filterSymbol(_ searchKey: String, from values: [AssetInfo]) -> [AssetInfo] {
        let result = values.filter({
            let s = $0.symbol.lowercased()
            let chainID = $0.chainID.lowercased()
            return s.contains(searchKey.lowercased()) || chainID.contains(searchKey.lowercased())
        })
        return result
    }

    // sort by type
    func sortAssets(type: AssetSortType,origins: [AssetInfo]) -> [AssetInfo] {
        var sort = Array(origins)
        sort.sort(by: {
            switch type {
            case .byValueLargestToSmallest:
                if let a = $0.balance?.double(),let b = $1.balance?.double() {
                    return a > b
                }
            case .byValueSmallestToLargest:
                if let a = $0.balance?.double(),let b = $1.balance?.double() {
                    return a < b
                }
            case .byNameAToZ:
                return $0.symbol < $1.symbol
           
            case .byNameZToA:
                return $0.symbol > $1.symbol
            }
            return true
        })

        return sort
    }
}
