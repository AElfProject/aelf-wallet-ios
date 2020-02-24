//
//  Dictionary+Ext.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/4.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

extension Dictionary where Key == String,Value == String  {
    
    mutating func addIfNotExist(dict: Dictionary) {
        dict.forEach { (key,value) in
            if self[key] == nil {
                self[key] = value
            }
        }
    }
    
}
