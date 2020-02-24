//
//  WalletHomeController.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/23.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit
import Hero

class WalletHomeController: BaseController {

    @IBOutlet weak var createButton: UIButton!

    @IBOutlet weak var importButton: UIButton!

    @IBOutlet weak var howToUseButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        createButton.hero.id = "createID"
        importButton.hero.id = "importID"

    }

    override func languageChanged() {

        howToUseButton.setTitle("How to use ELF Wallet".localized(), for: .normal)
        createButton.setTitle("Create Wallet".localized(), for: .normal)
        importButton.setTitle("Import Wallet".localized(), for: .normal)

        self.languageButton.setTitle(App.languageName, for: .normal)
        self.languageButton.setTitlePosition(position: .left, spacing: 5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func howToUseButtonTapped(_ sender: UIButton) {
        let languageVC = UIStoryboard.loadStoryClass(className: HelpManagerController.className, storyType: .setting)
        push(controller: languageVC)
    }

    @IBAction func languageButtonTapped(_ sender: Any) {

        let languageVC = UIStoryboard.loadController(LanguageController.self, storyType: .setting)
        push(controller: languageVC)
    }
}

extension WalletHomeController {
     // 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let importVC = segue.destination as? ImportMnemonicController {
            logDebug(importVC)
        }
    }

}
