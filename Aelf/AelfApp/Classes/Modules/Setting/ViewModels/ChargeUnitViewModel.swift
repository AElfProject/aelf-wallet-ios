//
//  ChargeUnitViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/14.
//  Copyright © 2019 AELF. All rights reserved.
//

import UIKit

class ChargeUnitViewModel:ViewModel {
    
}

extension ChargeUnitViewModel: ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<CurrencyModel>(value: CurrencyModel(JSON: [:])!)
        let items = BehaviorRelay<[CurrencyItemModel]>(value: [])
    }
    
    func transform(input: ChargeUnitViewModel.Input) -> ChargeUnitViewModel.Output {
        
        let output = Output()
        
        input.headerRefresh.flatMapLatest { [weak self] _ -> Observable<CurrencyModel> in
            guard let self = self else { return Observable.just(CurrencyModel(JSON: [:])!)}
            return self.request().trackActivity(self.headerLoading)
        }.subscribe(onNext: { result in
            output.items <= result.list
            output.dataSource.accept(result)
        }).disposed(by: rx.disposeBag)
        
        return output
    }
    
    func request() -> Observable<CurrencyModel> {
        return userProvider.requestData(.getCurrencies)
            .mapObject(CurrencyModel.self)
            .trackActivity(self.loading)
            .trackError(self.error)
    }
    
}
