//
//  TransationViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/10.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import ObjectMapper

class TransationViewModel:ViewModel {
    
}

extension TransationViewModel: ViewModelType {
    
    struct Input {
        let address:String
        let headerRefresh: Observable<Void>
        let footerRefresh: Observable<Void>
        let readMessage: Observable<String>
        let removeAll: Observable<Void>
    }
    
    struct Output {
        let items = BehaviorRelay<[AssetHistory]>(value: [])
        let clearResult = PublishSubject<Bool>()
    }
    
    func transform(input: TransationViewModel.Input) -> TransationViewModel.Output {
        
        let output = Output()
        
        input
            .readMessage
            .flatMapLatest({ [weak self] value -> Observable<VResult> in
                guard let self = self else { return Observable.just(VResult(JSON: [:])!)}
                return self.setReadTransactionMessage(address: input.address, mid: value)
            })
            .map({ $0.isOk })
            .filter({ !$0 }) // 过滤掉失败结果
            .bind(to: output.clearResult).disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { [weak self] _ -> Observable<TransationNoteModel> in
            guard let self = self else { return Observable.just(TransationNoteModel(JSON: [:])!)}
            self.page = 1
            return self.request(address: input.address).trackActivity(self.headerLoading)
        }.subscribe(onNext: { result in
            output.items <= result.list
        }).disposed(by: rx.disposeBag)
        
        input.footerRefresh.flatMapLatest { [weak self] _ -> Observable<TransationNoteModel> in
            guard let self = self else { return Observable.just(TransationNoteModel(JSON: [:])!)}
            self.page += 1
            return self.request(address: input.address).trackActivity(self.footerLoading)
        }.subscribe(onNext: { result in
            output.items <= output.items.value + result.list
        }).disposed(by: rx.disposeBag)
        
        input.removeAll.subscribe(onNext: { _ in
            output.items <= []
        }).disposed(by: rx.disposeBag)
        
        return output
    }
    
    func request(address: String) -> Observable<TransationNoteModel> {
        return userProvider
            .requestData(.transactionNotice(address: address, p: self.page))
            .mapObject(TransationNoteModel.self)
            .trackError(error)
            .trackActivity(loading)
    }
    
    func setReadTransactionMessage(address: String,mid:String) -> Observable<VResult> {
        // 设置交易消息已读用这个接口，别问我为什么没跟系统消息已读是1个接口... 我也很无奈。
        return userProvider.requestData(.setNoticeRead(address: address, id: mid))
            .mapObject(VResult.self).trackError(error)
    }
}
