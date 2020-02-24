//
//  WalletValidate.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import Validator

struct WalletInputLimit {
    // 如果 nameRange = Range(1...20)， 则打印 nameRange 的 lowerBound - upperBound 是 1 - 21，故使用 upperBound 时候需要 - 1
    static let nameRange = Range(1...20)
    static let pwdRange = Range(12...36)
    static let hintRange = Range(0...20)
}

let pwdLengthMin = WalletInputLimit.pwdRange.lowerBound
let pwdLengthMax = WalletInputLimit.pwdRange.upperBound - 1

struct WalletValldate {

//    static let uppers = (11...36).map { String($0 - 1, radix: $0,uppercase: true) }
//    static let lowers = (11...36).map { String($0 - 1, radix: $0,uppercase: false) }
//    static let numbers = (0...9).map { $0.string }

    static func userNameRule() -> ValidationRuleLength {
        
        let min = WalletInputLimit.nameRange.lowerBound
        let max = WalletInputLimit.nameRange.upperBound - 1
        let valid = ValidationRuleLength(min: min,
                                         max: max,
                                         error: ValidatorError(message: "Wallet name %d~%d characters".localizedFormat(min,max)))
        return valid                
    }

    static func pwdRules(isconfirm: Bool = false) -> ValidationRuleSet<String> {
        let localized = "please enter %d-%d characters password rule".localizedFormat(pwdLengthMin,pwdLengthMax)
        var rules = ValidationRuleSet<String>()
        let valid = ValidationRuleLength(min: pwdLengthMin,
                                         max: pwdLengthMax,
                                         error: ValidatorError(message: localized))
        rules.add(rule: valid)
        return rules
    }

    static func pwdStrongRule() -> ValidationRulePattern {

        let localized = "The password did not conform with the rules".localized()
        let digitRule = ValidationRulePattern(pattern: PwdParttern(), error: ValidatorError(message: localized))
        return digitRule
    }

    static func confirmPwdRule(_ confirmPwd: String) -> ValidationRuleEquality<String> {
        let valid = ValidationRuleEquality(target: confirmPwd, error: ValidatorError(message: "Two input password must be consistent".localized()))
        return valid
    }

}


fileprivate struct PwdParttern: ValidationPattern {

    // 必须 xx 位，包含大小写，字符加数字。
    var pattern: String { // https://www.html.cn/archives/8100
        return "^(?=.*?[A-Z])(?=(.*[a-z]){1,})(?=(.*[\\d]){1,})(?=(.*[\\W]){1,})(?!.*\\s).{\(pwdLengthMin),\(pwdLengthMax)}$"
    }
}
