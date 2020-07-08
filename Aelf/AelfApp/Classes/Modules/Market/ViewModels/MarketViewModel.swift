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
        var items = BehaviorRelay<[MarketCoinModel]>(value: [])
    }
    
    func transform(input: MarketViewModel.Input) -> MarketViewModel.Output {
        
        let output = Output()
        // =0价格倒序 =1价格正序 =2涨幅倒序 =3跌幅正序
//        let sortTypeValue = input.sortType.value
        input.sortType.flatMapLatest { t -> Observable<[MarketCoinModel]> in
            self.page = 1
            SVProgressHUD.show()
            return self.request(sort: t)}.subscribe(onNext: { result in
                //对数据进行排序操作
                if input.sortType.value > 1 {
                    let array = result.sorted { (a, b) -> Bool in
                        if input.sortType.value == 2 {
                            return (a.increase! as NSString).doubleValue < (b.increase! as NSString).doubleValue
                        } else {
                            return (a.increase! as NSString).doubleValue > (b.increase! as NSString).doubleValue
                        }
                    }
                    output.items <= array
                } else {
                    output.items <= result
                }
                SVProgressHUD.dismiss()
            }, onError: { error in
                if let r = error as? ResultError {
                    SVProgressHUD.showError(withStatus: r.msg)
                }
            }).disposed(by: rx.disposeBag)

        input.headerRefresh.flatMapLatest { _ -> Observable<[MarketCoinModel]> in
            self.page = 1
            let sortType = input.sortType.value
            return self.request(sort: sortType)
                .trackActivity(self.headerLoading)
                .catchErrorJustComplete()
            }.subscribe(onNext: { result in
                if input.sortType.value > 1 {
                    let array = result.sorted { (a, b) -> Bool in
                        if input.sortType.value == 2 {
                            return (a.increase! as NSString).doubleValue < (b.increase! as NSString).doubleValue
                        } else {
                            return (a.increase! as NSString).doubleValue > (b.increase! as NSString).doubleValue
                        }
                    }
                    output.items <= array
                } else {
                    output.items <= result
                }
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest { _ -> Observable<[MarketCoinModel]> in
            self.page += 1
            let sortType = input.sortType.value
            return self.request(sort: sortType).trackActivity(self.footerLoading)
        }.subscribe(onNext: { result in
            //分页
//            output.items <=  output.items.value + result
            
//            let array = (output.items.value + result).sorted { (a, b) -> Bool in
//                return (a.increase! as NSString).doubleValue > (b.increase! as NSString).doubleValue
//            }
            
            if input.sortType.value > 1 {
                let array = (output.items.value + result).sorted { (a, b) -> Bool in
                    if input.sortType.value == 2 {
                        return (a.increase! as NSString).doubleValue < (b.increase! as NSString).doubleValue
                    } else {
                        return (a.increase! as NSString).doubleValue > (b.increase! as NSString).doubleValue
                    }
                }
                output.items <= array
            } else {
                output.items <= (output.items.value + result)
            }
            
        }).disposed(by: rx.disposeBag)
        return output
    }

}

extension MarketViewModel {
    func request(sort:Int) -> Observable<[MarketCoinModel]> {
        return marketProvider
            .requestData(.markList(currency: App.currency, ids:"", order:sort, perPage: 20, page: self.page))
            .mapObjects(MarketCoinModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
