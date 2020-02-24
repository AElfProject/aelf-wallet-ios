//
//  ImportKeystoreViewModel.swift
//  AElfApp
//
//  Created by jinxiansen on 2019/8/5.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import Validator

class ImportKeystoreViewModel: BaseWalletViewModel {

}

extension ImportKeystoreViewModel: ViewModelType {

    struct Input {
        let pwd: Driver<String>
        let importTrigger: Driver<Void>
    }

    struct Output {
        let result = PublishSubject<ValidatorError>()
        let verifyOK = PublishSubject<()>()

    }

    func transform(input: ImportKeystoreViewModel.Input) -> ImportKeystoreViewModel.Output {

        let out = Output()
//        let pwdValidate = BehaviorSubject<ValidationResult?>(value: nil)
//        let strongValidate = BehaviorSubject<ValidationResult?>(value: nil)
//
//        input.pwd.asObservable().map{ $0.validate(rules: WalletValldate.pwdRules()) }.bind(to: pwdValidate).disposed(by: rx.disposeBag)
//        input.pwd.asObservable().map{ $0.validate(rule: WalletValldate.pwdStrongRule()) }.bind(to: strongValidate).disposed(by: rx.disposeBag)
//
//        input.importTrigger.asObservable().subscribe(onNext: { _ in
//
//            do {
//                let values = [try pwdValidate.value(),
//                              try strongValidate.value()]
//                let valids = values.compactMap({ $0 }).filter({ !$0.isValid })
//                if let f = valids.first {
//                    switch f {
//                    case .invalid(let err):
//                        if let e = err.first as? ValidatorError {
//                            out.result <= e
//                            return
//                        }
//                    case .valid:
//                        break
//                    }
//                }
//            } catch {
//                logInfo("\(error)")
//            }
//            out.verifyOK.onNext(()) //
//        }).disposed(by: rx.disposeBag)

        return out
    }
}
