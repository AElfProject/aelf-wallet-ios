//
//  NSAttributeString+Ext.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/6/11.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation

extension NSAttributedString {

    var mutableAttributed: NSMutableAttributedString {
        let att = NSMutableAttributedString(attributedString: self)
        return att
    }
}
