//
//  CreateWalletViewModel.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/31.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import Validator

class CreateWalletViewModel: BaseWalletViewModel {

}

extension CreateWalletViewModel: ViewModelType {

    struct Input {
        let userName: Driver<String>
        let pwd: Driver<String>
        let confirmPwd: Driver<String>
        let createTrigger: Driver<Void>
    }

    struct Output {
        let result = PublishSubject<ValidatorError>()
        let verifyOK = PublishSubject<()>()

    }

    // MARK: 转换。
    func transform(input: CreateWalletViewModel.Input) -> CreateWalletViewModel.Output {

        let out = Output()

        let nameValidate = BehaviorSubject<ValidationResult?>(value: nil)
        let pwdValidate = BehaviorSubject<ValidationResult?>(value: nil)
        let eqPwdValidate = BehaviorSubject<ValidationResult?>(value: nil)
        let strongValidate = BehaviorSubject<ValidationResult?>(value: nil)

        input.userName.asObservable().map({ $0.validate(rule: WalletValldate.userNameRule()) }).bind(to: nameValidate).disposed(by: rx.disposeBag)

        input.pwd.asObservable().map{ $0.validate(rules: WalletValldate.pwdRules()) }.bind(to: pwdValidate).disposed(by: rx.disposeBag)

        Driver.combineLatest(input.pwd,input.confirmPwd).asObservable().map({ [weak self] v1,v2 -> ValidationResult in
            guard let self = self else { return ValidationResult.invalid([]) }
            return self.validatePwdResult(v1, confirmPwd: v2)
        }).bind(to: eqPwdValidate).disposed(by: rx.disposeBag)

        input.pwd.asObservable().map{ $0.validate(rule: WalletValldate.pwdStrongRule()) }.bind(to: strongValidate).disposed(by: rx.disposeBag)

        input.createTrigger.asObservable().subscribe(onNext: { _ in
            do {
                let values = [try nameValidate.value(),
                              try pwdValidate.value(),
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

extension CreateWalletViewModel {

    func validatePwdResult(_ pwd: String,confirmPwd: String) -> ValidationResult {
        return pwd.validate(rule: WalletValldate.confirmPwdRule(confirmPwd))
    }
}
