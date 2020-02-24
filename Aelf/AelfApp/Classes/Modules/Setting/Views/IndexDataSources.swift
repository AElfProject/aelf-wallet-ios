//
//  IndexDataSource.swift
//  TableViewIndex
//
//  Created by Makarov Yury on 28/05/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit
import MYTableViewIndex

class CollationIndexDataSource : NSObject, TableViewIndexDataSource {
    
    var collaction = [String]()
    
    let showsSearchItem: Bool
    
    init(hasSearchIndex: Bool) {
        showsSearchItem = hasSearchIndex
    }
    init(hasSearchIndex: Bool,indexs:[String]) {
        showsSearchItem = hasSearchIndex
        self.collaction = indexs
    }
    convenience override init() {
        self.init(hasSearchIndex: true)
    }
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        var items = collaction.map { title -> UIView in
            let item = StringItem(text: title)
            item.tintColor = .appPurple
            return item
        }
        if showsSearchItem {
            items.insert(SearchItem(), at: 0)
        }
        return items
    }
}

private func generateRandomNumber(from: UInt32, to: UInt32) -> UInt32 {
    return from + arc4random_uniform(to - from + 1)
}

extension UIColor {
    
    func my_shiftHue(_ shift: CGFloat) -> UIColor? {
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        if !getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return nil
        }
        return UIColor(hue: (hue + shift).truncatingRemainder(dividingBy: 1.0),
                       saturation: saturation,
                       brightness: brightness,
                       alpha: alpha)
    }
    
    func my_shiftHueRandomlyWithGradation(_ gradation: Int) -> UIColor {
        let rand = generateRandomNumber(from: 1, to: UInt32(gradation))
        let hueShift: CGFloat = 1.0 / CGFloat(rand)
        if let c = my_shiftHue(hueShift) {
            return c
        }
        return self
    }
}


