//
//  Localized+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/19.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension UILabel {
    
    @IBInspectable var localized: String? {
        get { return self.text }
        set { self.text = newValue?.localized() }
    }
}

extension UIButton {

    @IBInspectable var localized: String? {
        get { return self.currentTitle }
        set { self.setTitle(newValue?.localized(), for: .normal) }
    }
}

extension UITextField {
    
    @IBInspectable var localized: String? {
        get { return self.placeholder }
        set { self.placeholder = newValue?.localized() }
    }
}

extension UISearchBar {
    
    @IBInspectable var localized: String? {
        get { return self.placeholder }
        set { self.placeholder = newValue?.localized() }
    }
}



