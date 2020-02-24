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

        // controller 基类里改
//        let attr = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium),
//                    NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "09162D")!]
//        appearance().titleTextAttributes = attr

    }

}
