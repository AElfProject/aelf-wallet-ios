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
        appearance().barTintColor = color
        appearance().isTranslucent = false
        appearance().clipsToBounds = false
        appearance().backgroundColor = color
        appearance().setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
    }
    
    public func configBackgroundImage(image: UIImage, titleColor: Color) {
         if #available(iOS 15.0, *) {
             let appearance = UINavigationBarAppearance()
             appearance.configureWithOpaqueBackground()
             appearance.shadowImage = UIImage.init()
             appearance.shadowColor = UIColor.clear
             appearance.titleTextAttributes = [.foregroundColor: titleColor]
             self.standardAppearance.backgroundImage = image
             self.scrollEdgeAppearance?.backgroundImage = image
             self.standardAppearance.titleTextAttributes = [.foregroundColor: titleColor]
             self.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: titleColor]
         } else {
             self.setBackgroundImage(image, for: .default)
             self.titleTextAttributes = [.foregroundColor: titleColor]
         }
     }
}
