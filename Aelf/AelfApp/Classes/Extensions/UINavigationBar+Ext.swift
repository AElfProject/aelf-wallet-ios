//
//  UINavigationBar+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/29.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension UINavigationBar {

    static func configAppearance() {

        let color = UIColor.white // 导航栏颜色
        appearance().shadowImage = UIImage()
//        appearance().tintColor = UIColor.white
//        appearance().barTintColor = color
        appearance().isTranslucent = false
        appearance().clipsToBounds = false
        appearance().backgroundColor = color
        appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)

    }

}
