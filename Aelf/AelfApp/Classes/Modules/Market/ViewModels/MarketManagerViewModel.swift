//
//  MarketManagerViewModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/6.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation


class MarketManagerViewModel: ViewModel {

}

extension MarketManagerViewModel: ViewModelType {

    struct Input {
        let loadData: Observable<Void>
        let delete: Observable<MarketCoinModel>
        let top: Observable<MarketCoinModel>
        let drag: Observable<ItemMovedEvent>
    }

    struct Output { 
        let items = BehaviorRelay<[MarketCoinModel]>(value: [])
    }

    func transform(input: MarketManagerViewModel.Input) -> MarketManagerViewModel.Output {
        let output = Output()

        input.loadData
            .flatMapLatest({ self.loadAllFavourites()
                .trackActivity(self.headerLoading) })
            .bind(to: output.items)
            .disposed(by: rx.disposeBag)

        // 删除
        input.delete.subscribe(onNext: { item in

            var items = output.items.value
            items.removeFirst(where: { $0.name == item.name }) // 从数组中删除
            item.delete() // 从数据库删除
            output.items <= items // Reload Data

        }).disposed(by: rx.disposeBag)

        // 置顶
        input.top.subscribe(onNext: { item in

            var items = output.items.value
            items.removeFirst(where: { $0.name == item.name }) // 从数组中删除
            items.insert(item, at: 0) // 插入第一位

            for (idx,value) in items.enumerated() { // // 重新设置索引，倒序方式。
                value.updateFavouriteIndex(items.count - idx - 1)
            }
            output.items <= items // reload

        }).disposed(by: rx.disposeBag)

        // 拖拽
        input.drag.subscribe(onNext: { (sourceIdx,destIdx) in

            var items = output.items.value
            let item = items[sourceIdx.row] // 记录拖拽的 item
            items.remove(at: sourceIdx.row) // 将源 item 移除
            items.insert(item, at: destIdx.row) // 再插入到拖拽的位置

            for (idx,value) in items.enumerated() {
                value.updateFavouriteIndex(items.count - idx - 1)
            }
            output.items <= items // reload
        }).disposed(by: rx.disposeBag)
        return output
    }

}


extension MarketManagerViewModel {

    func loadAllFavourites() -> Observable<[MarketCoinModel]> {
        let items = allIcons()
        return Observable.just(items).trackActivity(loading).trackError(error)
    }

    func allIcons() -> [MarketCoinModel] {
        let items = MarketCoinModel.getCoins() ?? []
        return items
    }
}
