//
//  String+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/29.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import CommonCrypto
import SwiftyRSA
extension String {
    
    static var appVersion: String {
        guard let ver = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return String()
        }
        return ver
    }
    
    static var appName: String {
        guard let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
            return String()
        }
        return name
    }
    
    static var bundleVersion: String {
        guard let ver = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "1"
        }
        return ver
    }
    
    static var bundleID: String {
        guard let name = Bundle.main.bundleIdentifier else {
            return String()
        }
        return name
    }
    
    static var getDBPath: String {
        
        let dbName = "aelf.db"
        let documentDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                  .userDomainMask, true).first!
        let manager = FileManager.default
        
        let dbPath = documentDirPath + "/\(dbName)"
        if !manager.fileExists(atPath: dbPath) {
            manager.createFile(atPath: dbPath, contents: nil, attributes: nil)
            logInfo("数据库已创建：\(dbPath)")
        }
        logInfo("数据库地址：\(dbPath)\n")
        
        return dbPath
    }
    
    //    func elfAddress() -> String {
    //        let address = "\(elfPrefix)_" + self + "_\(defaultChainID)" //主网 AELF
    //        return address
    //    }
    
    func elfAddress(_ chainID: String = Define.defaultChainID) -> String {
        let address = "\(Define.elfPrefix)_" + self + "_\(chainID)" //主网 AELF
        return address
    }
    
    func chainID() -> String? {
        let results = components(separatedBy: "_")
        return results.count == 3 ? results.last : nil
    }
    
    func removeChainID() -> String {
        let comps = components(separatedBy: "_")
        if comps.count == 3 {
            return comps[1] // 如果是拼接的地址，则取中间 address
        }
        return self
    }
    
    func removeSlash() -> String { // 
        if lastCharacterAsString == "/" {
            return self[0..<self.length - 1]
        }
        return self
    }
    
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    
    func aelfMd5() -> String {
        return "#*-OJBK\(self)(.)".md5()
    }
    
    func contains(regular:String) -> Bool {
        return self.range(of: regular, options: .regularExpression, range: nil, locale: nil) != nil
    }
    func match(_ regular: String) -> Bool {
        return self.contains(regular: regular)
    }
    
    var length: Int {
        return self.count//.characters.count
    }
    
    func subString(to index: Int) -> String {
        return String(self[..<self.index(self.startIndex, offsetBy: index)])
    }
    
    func subString(from index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)...])
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound, limitedBy: self.endIndex) ?? self.endIndex
        let end = self.index(self.startIndex, offsetBy: r.upperBound, limitedBy: self.endIndex) ?? self.endIndex
        return String(self[start..<end])
    }
    
    subscript (n:Int) -> String {
        return self[n..<n+1]
    }
    subscript (str:String) -> Range<Index>? {
        return self.range(of: str)
    }
    
    var hexColor: UIColor {
        
        let hexString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
    /// 移除 Emoji 表情
    ///
    /// - Returns: 返回不包含 Emoji 的字符串。
    func filterEmoji() -> String {
        return String(self.filter { !$0.isEmoji })
    }
    
    
    /// 限制设置为整数
    ///
    /// - Returns: 返回仅包含整数的字符串。
    func setDigits() -> String {
        return String(self.filter {
            if let t = $0.int, t >= 0 && t <= 9 {
                return true
            }
            return false
        })
    }
    
    /// 限制设置浮点数
    ///
    /// - Returns: 返回仅包含浮点数的字符串。
    func setFloat() -> String {
        var max = 0
        return String(self.filter {
            if let t = $0.int, t >= 0 && t <= 9 {
                return true
            }
            if $0 == "." { //
                if max == 1 {
                    return false
                }
                max = 1
                return true
            }
            return false
        })
    }
    
    /// 移除首尾空格
    ///
    /// - Returns:
    func setMnemonicFormatter() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
     
    
    func stringToJSON() -> String {
        // 计数tab的个数
        var tabNum: Int = 0
        var jsonFormat: String = ""

        var last = "";
        for i in self.indices {
            let c = self[i]
            if (c == "{") {
                tabNum += 1
                jsonFormat.append("\(c) \n")
                jsonFormat.append(getSpaceOrTab(tabNum: tabNum))
            }
            else if (c == "}") {
                tabNum -= 1
                jsonFormat.append("\n")
                jsonFormat.append(getSpaceOrTab(tabNum: tabNum))
                jsonFormat.append(c)
            }
            else if (c == ",") {
                jsonFormat.append("\n")
                jsonFormat.append(getSpaceOrTab(tabNum: tabNum))
            }
            else if (c == ":") {
                jsonFormat.append("\(c) ")
            }
            else if (c == "[") {
                tabNum += 1
                let next = self[self.index(i, offsetBy: 1)]
                if (next == "]") {
                    jsonFormat.append("\(c)")
                } else {
                    jsonFormat.append("\(c) \n")
                    jsonFormat.append(getSpaceOrTab(tabNum: tabNum))
                }
            }
            else if (c == "]") {
                tabNum -= 1
                if (last == "[") {
                    jsonFormat.append("\(c)")
                } else {
                    jsonFormat.append("\(getSpaceOrTab(tabNum: tabNum))\n \(c)")
                }
            }
            else {
                jsonFormat.append("\(c)")
            }
            last = "\(c)"
        }
        return jsonFormat;
    }


    func getSpaceOrTab(tabNum: Int) -> String {
        var sbTab = ""
        for _ in 0..<tabNum {
            sbTab.append("\t")
        }
        return sbTab
    }
    
    func isValidJSON() -> Bool {
        guard let jsonData = self.replacingOccurrences(of: "\n", with: "").data(using: String.Encoding.utf8) else {
            return false
        }
        let result = JSONSerialization.isValidJSONObject(jsonData)
        logInfo("是否为JSON: \(result)")
        return result
    }
    
}
