//
//  AboutUSViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/19.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class AboutUSViewModel: ViewModel {
    
    
}

extension AboutUSViewModel: ViewModelType {
    
    struct Input {
        let headerRefresh: Observable<Void>
    }
    
    struct Output {
        let items = PublishRelay<AppVersionUpdate>()
    }
    
    func transform(input: AboutUSViewModel.Input) -> AboutUSViewModel.Output {
        
        let output = Output()

        input
            .headerRefresh
            .flatMapLatest({ self.requestUpgrade() })
            .subscribe(onNext: { result in
            output.items <= result
        }).disposed(by: rx.disposeBag)
        
        return output
    }


    func requestUpgrade() -> Observable<AppVersionUpdate> {
        return userProvider.requestData(.appUpgrade)
            .mapObject(AppVersionUpdate.self)
            .trackError(error)
            .trackActivity(loading)
    }
}
