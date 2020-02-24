//
//  VersionLogViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class VersionLogViewModel: ViewModel {

}

extension VersionLogViewModel: ViewModelType {

    struct Input {
        let headerRefresh: Observable<Void>
    }

    struct Output {
        let items = BehaviorRelay<[AppVersionLog]>(value: [])
    }

    func transform(input: VersionLogViewModel.Input) -> VersionLogViewModel.Output {

        let output = Output()

        input
            .headerRefresh
            .flatMapLatest({ self.requestVersionLog().trackActivity(self.headerLoading) })
            .subscribe(onNext: { result in
                output.items <= result
            }).disposed(by: rx.disposeBag)

        return output
    }


    func requestVersionLog() -> Observable<[AppVersionLog]> {
        return userProvider.requestData(.versionLog)
            .mapObject(AppVersionList.self)
            .map({ $0.list ?? [] })
            .trackError(error)
            .trackActivity(loading)
    }
}

