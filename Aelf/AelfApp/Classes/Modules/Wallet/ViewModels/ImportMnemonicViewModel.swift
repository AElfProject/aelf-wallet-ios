//
//  ImportMnemonicViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/1.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import Validator

class ImportMnemonicViewModel: BaseWalletViewModel {

}

extension ImportMnemonicViewModel {

    struct Input {
        let pwd: Driver<String>
        let confirmPwd: Driver<String>
        let importTrigger: Driver<Void>
    }

    struct Output {
        let result = PublishSubject<ValidatorError>()
        let verifyOK = PublishSubject<()>()

    }

    func transform(input: ImportMnemonicViewModel.Input) -> ImportMnemonicViewModel.Output {

        let out = Output()

        let pwdValidate = BehaviorSubject<ValidationResult?>(value: nil)
        let eqPwdValidate = BehaviorSubject<ValidationResult?>(value: nil)
        let strongValidate = BehaviorSubject<ValidationResult?>(value: nil)

        input.pwd.asObservable().map{ $0.validate(rules: WalletValldate.pwdRules()) }.bind(to: pwdValidate).disposed(by: rx.disposeBag)

        Driver.combineLatest(input.pwd,input.confirmPwd).asObservable().map({ [weak self] v1,v2 -> ValidationResult in
            guard let self = self else { return ValidationResult.invalid([]) }
            return self.validatePwdResult(v1, confirmPwd: v2)
        }).bind(to: eqPwdValidate).disposed(by: rx.disposeBag)

        input.pwd.asObservable().map{ $0.validate(rule: WalletValldate.pwdStrongRule()) }.bind(to: strongValidate).disposed(by: rx.disposeBag)

        input.importTrigger.asObservable().subscribe(onNext: { _ in
            do {
                let values = [try pwdValidate.value(),
                              try eqPwdValidate.value(),
                              try strongValidate.value()]
                let valids = values.compactMap({ $0 }).filter({ !$0.isValid })
                if let f = valids.first {
                    switch f {
                    case .invalid(let err):
                        if let e = err.first as? ValidatorError {
                            out.result <= e
                            return
                        }
                    case .valid:
                        break
                    }
                }
            } catch {
                logInfo("\(error)")
            }
            out.verifyOK.onNext(()) // Valid successful!
        }).disposed(by: rx.disposeBag)

        return out

    }
}


extension ImportMnemonicViewModel {

    func validatePwdResult(_ pwd: String,confirmPwd: String) -> ValidationResult {
        return pwd.validate(rule: WalletValldate.confirmPwdRule(confirmPwd))
    }
}
