//
//  NotificationViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/20.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

class NotificationViewModel: ViewModel {


}

extension NotificationViewModel: ViewModelType {

    struct Input {
        let address: String
        let fetchAllUnRead: Observable<Void> /// 获取所有消息
        let clearAllTransactionUnRead: Observable<Void> // 清除所有交易未读消息
        let clearAllSystemUnRead: Observable<Void> // 清除所有系统未读消息
    }

    struct Output {
        let unReadModel = PublishSubject<MessageUnReadModel>()
        let clearAllTransactionMessageResult = PublishSubject<Bool>()
        let clearAllSystemMessageResult = PublishSubject<Bool>()
    }

    func transform(input: NotificationViewModel.Input) -> NotificationViewModel.Output {

        let out = Output()

        // 获取全部的两种未读消息
        input
            .fetchAllUnRead
            .flatMapLatest({ self.requestAllUnRead(address: input.address) })
            .bind(to: out.unReadModel)
            .disposed(by: rx.disposeBag)

        // 清除全部的交易未读信息
        input
            .clearAllTransactionUnRead
            .flatMapLatest({ self.clearAllTransaction(address: input.address) })
            .map({ $0.isOk })
            .filter({ !$0 })
            .bind(to: out.clearAllTransactionMessageResult)
            .disposed(by: rx.disposeBag)

        // 清除全部的系统未读信息
        input.clearAllSystemUnRead
            .flatMapLatest({ self.clearAllSystemMessage(address: input.address) })
            .map({ $0.isOk })
            .filter({ !$0 })
            .bind(to: out.clearAllSystemMessageResult)
            .disposed(by: rx.disposeBag)


        return out
    }

}


extension NotificationViewModel {

    /// 获取总消息未读数
    func requestAllUnRead(address: String) -> Observable<MessageUnReadModel> {
        return userProvider
            .requestData(.messageUnRead(address: address))
            .mapObject(MessageUnReadModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }

    // Transaction
    func clearAllTransaction(address: String) -> Observable<VResult> {
        return userProvider.requestData(.clearTransactionNotice(address: address))
            .mapObject(VResult.self).trackError(error)
    }

    // Message
    func clearAllSystemMessage(address: String) -> Observable<VResult> {
        return userProvider.requestData(.clearMessageNote(address: address))
            .mapObject(VResult.self)
    }

}
