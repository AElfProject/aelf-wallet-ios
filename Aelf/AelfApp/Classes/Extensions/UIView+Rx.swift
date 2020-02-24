//
//  UIView+Rx.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/16.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

extension Reactive where Base: UIView {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { view, value in
            view.isHidden = value
        }
    }

}
