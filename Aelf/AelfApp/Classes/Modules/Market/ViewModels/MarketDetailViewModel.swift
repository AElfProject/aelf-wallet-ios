//
//  MarketDetailViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit
import ObjectMapper

class MarketDetailViewModel: ViewModel {
    var input: Input?
    var output: Output?
}
extension MarketDetailViewModel: ViewModelType {
    
    struct Input {
        let currency: String
        let name: String
        let type: Int
        let time: BehaviorSubject<Int>
        let loadKLine: Observable<Void>
        let loadData: Observable<Void>
    }
    
    struct Output {

        let dataSource = BehaviorRelay<MarketDetailModel>(value: MarketDetailModel(JSON: [:])!)
        let items = PublishSubject<[MarketSiteModel]>()

        let numberOfSection = BehaviorRelay<Int>(value: 0)
        let numberSectionOfRow =  BehaviorRelay<Int>(value: 0)
        let klineSource = PublishRelay<MarketTradeModel>()
    }
    
    func transform(input: MarketDetailViewModel.Input) -> MarketDetailViewModel.Output {
        
        let output = Output()

        Observable
            .combineLatest(input.loadKLine,input.time)
            .flatMapLatest({ [weak self] _ -> Observable<MarketTradeModel> in
                guard let self = self else { return Observable.just(MarketTradeModel(JSON: [:])!)}
                return self.requestKLine(input: input)
            })
            .bind(to: output.klineSource)
            .disposed(by: rx.disposeBag)

        input.loadData
            .flatMapLatest({ [weak self] _ -> Observable<MarketDetailModel> in
                guard let self = self else { return Observable.just(MarketDetailModel(JSON: [:])!)}
                return self.requestData(input: input)
            })
            .subscribe(onNext: { result in
                output.numberOfSection <= 1
                let sizeTotal = 2
                output.numberSectionOfRow <= sizeTotal + 2
                output.items <= result.site
                output.dataSource.accept(result)
            }).disposed(by: rx.disposeBag)

        return output
    }
}


extension MarketDetailViewModel {

    func requestKLine(input: Input) -> Observable<MarketTradeModel> {
        return marketProvider.requestData(.tradeKline(id: input.name, currency: input.currency, days:String(try! input.time.value())))
            .mapObject(MarketTradeModel.self)
            .trackActivity(self.loading)
            .trackError(self.error)
    }

    func requestData(input: Input) -> Observable<MarketDetailModel> {
        return marketProvider
            .requestData(.coinDetail(id: input.name))
            .mapObject(MarketDetailModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
