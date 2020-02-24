//
//  MyAccountViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/18.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class MyAccountViewModel: ViewModel {


}


extension MyAccountViewModel: ViewModelType {

    struct Input {
        let address: String
        let headerRefresh: Observable<Void>
    }

    struct Output {
        let userInfo = PublishRelay<IdentityInfo>()
    }

    func transform(input: MyAccountViewModel.Input) -> MyAccountViewModel.Output {

        let out = Output()
        input.headerRefresh.flatMapLatest { name -> Observable<IdentityInfo> in
            return self.getUserInfo(address: input.address)
            }.subscribe(onNext: { result in
                out.userInfo.accept(result)
        }).disposed(by: rx.disposeBag)
        
        return out
    }

}

extension MyAccountViewModel {

    func getUserInfo(address: String) -> Observable<IdentityInfo> {
        return userProvider
            .requestData(.getIdentity(address: address))
            .mapObject(IdentityInfo.self)
            .trackError(error)
            .trackActivity(loading)
    }

    func updateUserName(address: String,name: String? = nil,img: UIImage? = nil) -> Observable<VResult> {
        let data = img?.jpegData(compressionQuality: 0.5)
        return userProvider
            .requestData(.identityEdit(address: address, name: name, img: data))
            .trackError(error)
            .trackActivity(loading)
    }
}
