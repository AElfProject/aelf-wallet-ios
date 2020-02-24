//
//  SectionItem.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/4.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation
import ObjectMapper
import RxDataSources

struct SectionItem<T: Mappable> {
    var items: [T]
}

extension SectionItem: SectionModelType {
    typealias Item = T

    init(original: SectionItem, items: [T]) {
        self = original
        self.items = items
    }
}
