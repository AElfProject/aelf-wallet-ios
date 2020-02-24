//
//  TableDataSources.swift
//  MYTableViewIndex
//
//  Created by Makarov Yury on 09/07/16.
//  Copyright © 2016 Makarov Yury. All rights reserved.
//

import UIKit

protocol Item {}

protocol DataSource {
    
    func numberOfSections() -> Int
    
    func numberOfItemsInSection(_ section: Int) -> Int
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> AddressBookItem?
    mutating func itemRemoveAtIndexPath(_ indexPath: IndexPath)

    func titleForHeaderInSection(_ section: Int) -> String?
}

extension AddressBookItem : Item {}

struct AddressBookDataSource : DataSource {
    func titleForHeaderInSection(_ section: Int) -> String? {
        return sections[section].first?.fc
    }
    
    
    var sections =  [[AddressBookItem]]()
    
    mutating func itemRemoveAtIndexPath(_ indexPath: IndexPath) {
     //  print("before Items = " + String(sections[indexPath.section].count))
        if sections.count > indexPath.section  {
            if sections[indexPath.section].count > indexPath.row {
                  sections[indexPath.section].remove(at: indexPath.row)
            }
        }
        if sections[indexPath.section].count == 0 {
            sections.remove(at: indexPath.section)
        }
      // print("after Items = " + String(sections[indexPath.section].count))
    }
    
    fileprivate let collaction = UILocalizedIndexedCollation.current()
    
    init() {
      //  sections = split()
    }
    
    fileprivate func loadCountryNames() -> [String] {
        return Locale.isoRegionCodes.map { (code) -> String in
            return Locale.current.localizedString(forRegionCode: code)!
        }
    }
    
//    fileprivate func split() -> [[AddressBookItem]] {
//        let items = []
////        guard let items = collation.sortedArray(from: items,
////                                                collationStringSelector: #selector(NSObject.description)) as? [String] else {
////                                                    return []
////        }
//        
//        return [items]
//    }
//    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return sections[section].count
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> AddressBookItem? {
        return sections[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]
    }
//
//    func titleForHeaderInSection(_ section: Int) -> String? {
//
//        return collaction.sectionTitles[section]
//    }
}

//extension UIColor : Item {}

//struct CompoundDataSource : DataSource {
//    func itemRemoveAtIndexPath(_ indexPath: IndexPath) {
////        var array = countryDataSource[indexPath.section]
////
////        array.remove(at: indexPath.row)
//    }
//
//    fileprivate let colorsSection = [UIColor.lightGray, UIColor.gray, UIColor.darkGray]
//
//    fileprivate let countryDataSource = CountryDataSource()
//
//    func numberOfSections() -> Int {
//        return countryDataSource.numberOfSections() + 1
//    }
//
//    func numberOfItemsInSection(_ section: Int) -> Int {
//        return section == 0 ? colorsSection.count : countryDataSource.numberOfItemsInSection(section - 1)
//    }
//
//    func itemAtIndexPath(_ indexPath: IndexPath) -> Item? {
//        if (indexPath as NSIndexPath).section == 0 {
//            return colorsSection[(indexPath as NSIndexPath).item]
//        } else {
//            return countryDataSource.itemAtIndexPath(IndexPath(item: (indexPath as NSIndexPath).item,
//                                                               section: (indexPath as NSIndexPath).section - 1))
//        }
//    }
//
//    func titleForHeaderInSection(_ section: Int) -> String? {
//        return section == 0 ? nil : countryDataSource.titleForHeaderInSection(section - 1)
//    }
//}
