//
//  MarketViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

import ObjectMapper

class MarketViewModel:ViewModel {
}

extension MarketViewModel: ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let sortType: BehaviorRelay<Int>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<MarketModel>(value: MarketModel(JSON: [:])!)
        let items = BehaviorRelay<[MarketCoinModel]>(value: [])
    }
    
    func transform(input: MarketViewModel.Input) -> MarketViewModel.Output {
        
        let output = Output()

        input.sortType.flatMapLatest { t -> Observable<MarketModel> in
            self.page = 1
            SVProgressHUD.show()
            
            return self.request(sort: t)}.subscribe(onNext: { result in
                output.items <= result.list
                output.dataSource.accept(result)
                SVProgressHUD.dismiss()
            }, onError: { error in
                if let r = error as? ResultError {
                    SVProgressHUD.showError(withStatus: r.msg)
                }
                logDebug(error)
            }).disposed(by: rx.disposeBag)

        input.headerRefresh.flatMapLatest { _ -> Observable<MarketModel> in
            self.page = 1
            let sortType = input.sortType.value
            return self.request(sort: sortType)
                .trackActivity(self.headerLoading)
                .catchErrorJustComplete()
            }.subscribe(onNext: { result in
                output.items <= result.list
                output.dataSource.accept(result)
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest { _ -> Observable<MarketModel> in
            self.page += 1
            let sortType = input.sortType.value
            return self.request(sort: sortType).trackActivity(self.footerLoading)
            }.subscribe(onNext: { result in
                output.dataSource.value.list += result.list
                output.items <=  output.dataSource.value.list
            }).disposed(by: rx.disposeBag)

        return output
    }

}

extension MarketViewModel {
    func request(sort:Int) -> Observable<MarketModel> {
        return marketProvider
            .requestData(.markList(currency: "usd", ids: "", perPage: 20, page: self.page, sparkLine: false, priceChangePercentage: ""))
            .mapObject(MarketModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
