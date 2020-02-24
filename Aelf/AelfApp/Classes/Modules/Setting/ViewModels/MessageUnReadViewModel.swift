//
//  MessageUnReadViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/17.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class MessageUnReadViewModel:ViewModel {
    

}

extension MessageUnReadViewModel: ViewModelType {
    
    struct Input {
        let address:String
        let headerRefresh: Observable<Void>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<MessageUnReadModel>(value: MessageUnReadModel(JSON: [:])!)
    }
    
    func transform(input: MessageUnReadViewModel.Input) -> MessageUnReadViewModel.Output {
        
        let output = Output()
 
        input.headerRefresh.flatMapLatest {self.request(address: input.address)}
            .subscribe(onNext: { result in
                output.dataSource <= result
                
            }).disposed(by: rx.disposeBag)
        
        return output
    }


    func request(address: String) -> Observable<MessageUnReadModel> {
        return userProvider
            .requestData(.messageUnRead(address: address))
            .mapObject(MessageUnReadModel.self)
            .trackError(self.error)
            .trackActivity(self.loading)
    }
    
}
