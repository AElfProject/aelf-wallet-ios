//
//  DispatchQueue+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/3.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

/// 主线程执行
func asyncMain(_ block: (() -> Void)?) {
    DispatchQueue.main.async {
        block?()
    }
}

/// 主线程延迟执行,默认延迟 1秒
func asyncMainDelay(duration: TimeInterval = 1, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        block()
    }
}
