//
//  Operation.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/30.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import RxSwift
import RxCocoa

func <= <T>(lhs: BehaviorSubject<T>, rhs: T) {  // BehaviorSubject

    lhs.onNext(rhs)
}

func <= <T>(lhs: BehaviorRelay<T>, rhs: T) { // BehaviorRelay

    lhs.accept(rhs)
}

func <= <T>(lhs: PublishSubject<T>, rhs: T) { // PublishSubject

    lhs.onNext(rhs)
}

func <= <T>(lhs: PublishRelay<T>, rhs: T) { // PublishRelay

    lhs.accept(rhs)
}


extension BehaviorRelay where Element: RangeReplaceableCollection {

    func append(_ subElement: Element.Element) {
        append([subElement])
    }

    func append(_ elements: [Element.Element]) {
        var newValue = value
        newValue.append(contentsOf: elements)
        accept(newValue)
    }
}

