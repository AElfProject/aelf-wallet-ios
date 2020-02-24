//
//  UITextView+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/31.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension UITextView {
    func asDriver() -> Driver<String> {
        return rx.text.orEmpty.asDriver()
    }
}
