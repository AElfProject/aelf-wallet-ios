//
//  SettingViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/18.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class SettingViewModel: ViewModel {


}

extension SettingViewModel: ViewModelType {

    struct Input {
        let address:String
        let headerRefresh: Observable<Void>
        let updateUserInfo: Observable<Void>
    }

    struct Output {
        let unRead = PublishSubject<MessageUnReadModel>()
        let userInfo = PublishSubject<IdentityInfo>()
    }

    func transform(input: SettingViewModel.Input) -> SettingViewModel.Output {

        let output = Output()

        input.headerRefresh.flatMapLatest({ self.requestUnReade(address: input.address) }).bind(to: output.unRead).disposed(by: rx.disposeBag)
        input.updateUserInfo.flatMapLatest({ self.requestUserInfo(address: input.address) }).bind(to: output.userInfo).disposed(by: rx.disposeBag)

        return output
    }

    func requestUserInfo(address: String) -> Observable<IdentityInfo> {
        return userProvider
            .requestData(.getIdentity(address: address))
            .mapObject(IdentityInfo.self)
            .trackError(error)
            .trackActivity(loading)
    }

    func requestUnReade(address: String) -> Observable<MessageUnReadModel> {
        return userProvider
            .requestData(.messageUnRead(address: address))
            .mapObject(MessageUnReadModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
}
