//
//  DiscoverViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class DiscoverViewModel: ViewModel {

}

extension DiscoverViewModel: ViewModelType {

    struct Input {
        let headerRefresh: Observable<Void>
    }

    struct Output {
        let discover = BehaviorRelay<Discover>(value: Discover(JSON: [:])!)
    }

    func transform(input: DiscoverViewModel.Input) -> DiscoverViewModel.Output {

        let output = Output()

        input.headerRefresh.flatMapLatest { [weak self] _ -> Observable<Discover> in
            guard let self = self else { return Observable.just(Discover.init(JSON: [:])!)}
            return self.request().trackActivity(self.headerLoading)
            }.subscribe(onNext: { result in
                output.discover.accept(result)
            }).disposed(by: rx.disposeBag)

        return output
    }
}

extension DiscoverViewModel {

    func request() -> Observable<Discover> {
        return discoverProvider
            .requestData(.home)
            .trackError(error)
            .trackActivity(loading)
            .mapObject(Discover.self)
    }
}
