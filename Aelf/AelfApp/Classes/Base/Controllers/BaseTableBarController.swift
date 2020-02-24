//
//  BaseTableBarController.swift
//  AelfApp
//
//  Created by 晋先森 on 17/3/3.
//  Copyright © 2017年 晋先森. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import Hero

private let isShowDiscover = true

class BaseTableBarController: ESTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(languageChanged),
                                               name: NSNotification.language,
                                               object: nil)
    }
    
    @objc public func languageChanged() {
        
        resetSubViewItems()
    }
    
    func resetSubViewItems() {
        
        guard let items = tabBar.items else { return }
        
        var names = [String]()
        
        if isShowDiscover {
            names = ["Assets",
                     "Market",
                     "Discover" ,
                     "My"].map({ $0.localized() })
        } else {
            names = ["Assets",
                     "Market",
                     "My"].map({ $0.localized() })
        }
        
        for (idx,item) in items.enumerated() {
            item.title = names[idx]
        }
    }
    
    static func resetRootController() {
        let vc = loadTabBar()
        switchRootController(vc)
    }
    
    static func resetImportRootController() {
        let vc = UIStoryboard.loadController(BaseNavigationController.self, storyType: .wallet)
        switchRootController(vc)
    }
    
    
    private static func switchRootController(_ vc: UIViewController) {
        
        UIApplication.shared.keyWindow?.switchRootViewController(to: vc,
                                                                 animated: true,
                                                                 duration: 1,
                                                                 options: .transitionFlipFromLeft, {
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension BaseTableBarController {
    
    static func loadTabBar() -> BaseTableBarController {
        
        let tabBarVC = BaseTableBarController()
        
        let assetNav = UIStoryboard.loadController(BaseNavigationController.self, storyType: .assets)
        let marketNav = UIStoryboard.loadController(BaseNavigationController.self, storyType: .market)
        
        let settingNav = UIStoryboard.loadController(BaseNavigationController.self, storyType: .setting)
        
        assetNav.tabBarItem = ESTabBarItem(BouncesContentView(),
                                           title: "Assets".localized(),
                                           image: UIImage(named: "wallet")?.original,
                                           selectedImage: UIImage(named: "wallet-selected")?.original)
        marketNav.tabBarItem = ESTabBarItem(BouncesContentView(),
                                            title: "Market".localized(),
                                            image: UIImage(named: "market")?.original,
                                            selectedImage: UIImage(named: "market-selected")?.original)
        
        settingNav.tabBarItem = ESTabBarItem(BouncesContentView(),
                                             title: "My".localized(),
                                             image: UIImage(named: "user")?.original,
                                             selectedImage: UIImage(named: "user-selected")?.original)
        
        if isShowDiscover {
            let discoverNav = UIStoryboard.loadController(BaseNavigationController.self, storyType: .discover)
            discoverNav.tabBarItem = ESTabBarItem(BouncesContentView(),
                                                  title: "Discover".localized(),
                                                  image: UIImage(named: "discover")?.original,
                                                  selectedImage: UIImage(named: "discover-selected")?.original)
            tabBarVC.viewControllers = [assetNav,
                                        marketNav,
                                        discoverNav,
                                        settingNav]
        } else {
            tabBarVC.viewControllers = [assetNav,
                                        marketNav,
                                        settingNav]
        }
        
        
        return tabBarVC
    }
}
