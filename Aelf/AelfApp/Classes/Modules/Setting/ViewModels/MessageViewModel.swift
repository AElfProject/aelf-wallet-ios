//
//  MessageViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/11.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import ObjectMapper

class MessageViewModel:ViewModel {

}

extension MessageViewModel: ViewModelType {
    
    struct Input {
        let address:String
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let readMessage: Observable<String>
        let removeAll: Observable<Void>
    }
    
    struct Output {
        let items = BehaviorRelay<[MessageDetaiModel]>(value: [])
        let clearResult = PublishSubject<Bool>()
    }
    
    func transform(input: MessageViewModel.Input) -> MessageViewModel.Output {
        
        let output = Output()

        input
            .readMessage
            .flatMapLatest({ self.setReadSystemMessage(address: input.address, mid: $0)})
            .map({ $0.isOk })
            .filter({ !$0 }) // 过滤掉失败结果
            .bind(to: output.clearResult).disposed(by: rx.disposeBag)

        // Header
        input.headerRefresh.flatMapLatest { [weak self] _ -> Observable<SystemMessageModel> in
            guard let self = self else { return Observable.just(SystemMessageModel(JSON: [:])!)}
            self.page = 1
            return self.request(address: input.address).trackActivity(self.headerLoading)
            }.subscribe(onNext: { result in
                output.items <= result.list
            }).disposed(by: rx.disposeBag)

        input.footerRefresh.flatMapLatest { [weak self] _ -> Observable<SystemMessageModel> in
            guard let self = self else { return Observable.just(SystemMessageModel(JSON: [:])!)}
            self.page += 1
            return self.request(address: input.address).trackActivity(self.footerLoading)
            }.subscribe(onNext: { result in
                output.items <=  output.items.value + result.list
            }).disposed(by: rx.disposeBag)

        input.removeAll.subscribe(onNext: { _ in
            output.items <= []
        }).disposed(by: rx.disposeBag)
        
        return output
    }


    func request(address: String) -> Observable<SystemMessageModel> {
        return userProvider.requestData(.systemMessage(address: address,
                                                       type: 1,
                                                       p: self.page))
            .mapObject(SystemMessageModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }

    func setReadSystemMessage(address: String,mid:String) -> Observable<VResult> {
        // 系统消息type = 1 以后可能扩展其他类型消息。
        return userProvider.requestData(.setMessageRead(address: address, type: 1, mid: mid))
            .mapObject(VResult.self)
    }

}
