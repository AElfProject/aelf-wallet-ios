//
//  UIStoryboard+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/29.
//  Copyright © 2019 晋先森. All rights reserved.
//

import Foundation

enum StoryType: String {
    case wallet = "Wallet"
    case assets = "Assets"
    case market = "Market"
    case discover = "Discover"
    case setting = "Setting"
    case main = "Main"
}

extension UIStoryboard {

    static func loadController<T: UIViewController>(_ controller: T.Type,storyType: StoryType) -> T {
        guard let vc = UIStoryboard(name: storyType.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: controller)) as? T else {
            fatalError("请检查 \(storyType.rawValue).storyboard 中对应的此 Controller 是否设置了 `Storyboard ID` 。")
        }
        return vc
    }

    static func loadStoryClass(className:String,storyType:StoryType) -> UIViewController {
        let vc = UIStoryboard(name: storyType.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: className as String)
        return vc
    }

}
