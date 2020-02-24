//
//  LFBaseNavigationController.swift
//  JTimeObserver
//
//  Created by 晋先森 on 16/12/19.
//  Copyright © 2016年 晋先森. All rights reserved.
//

import UIKit
import Hero
class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        if isIphoneX {
            hero.isEnabled = true
            hero.modalAnimationType = .autoReverse(presenting: .fade)
            hero.navigationAnimationType = .autoReverse(presenting: .slide(direction: .left))
            Hero.shared.containerColor = UIColor.white
        }

    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }

    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
 
