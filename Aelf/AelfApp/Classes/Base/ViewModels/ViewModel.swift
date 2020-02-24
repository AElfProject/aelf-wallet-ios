//
//  ViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class ViewModel: NSObject {

    let error = ErrorTracker()
    let parseError = PublishSubject<ResultError>()

    let loading = ActivityIndicator() //
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let disposeBag = DisposeBag()
    var page = 1

    override init() {
        super.init()

        error.asObservable().map { error -> ResultError? in
            if let errResponse = error as? ResultError {
                return errResponse
            }
            return nil
            }.filterNil().bind(to: parseError).disposed(by: rx.disposeBag)

        error.asDriver().drive(onNext: { [weak self] error in
            guard let self = self else { return }
            logError(" \(type(of: self).className) Response Failed：\(error)")
        }).disposed(by: rx.disposeBag)
    }

    deinit {
        logDebug("释放VM：\(self.className)\n")
    }

}
