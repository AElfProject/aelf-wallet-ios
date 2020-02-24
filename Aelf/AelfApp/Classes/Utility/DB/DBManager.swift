//
//  DBManager.swift
//
//
//  Created by jinxiansen on 2019/7/31.
//  Copyright © 2019 aelf. All rights reserved.
//

import Foundation
import WCDBSwift

//使用参考： https://github.com/Tencent/wcdb/wiki/Swift-增删查改

class DBManager {

    fileprivate static let shared = DBManager()

    private let dataBase = Database(withPath: dbPath)

    private init() {

    }

    /// 创建表。
    ///
    /// - Parameters:
    ///   - table: 表名。
    ///   - type: 类型。
    static func createTable<T: TableDecodable>(table: String, of type:T.Type) {
        do {
            try shared.dataBase.create(table: table, of:type)
        } catch {
            debugPrint("create table error \(error.localizedDescription)")
        }
    }

    /// 插入一条数据。
    ///
    /// - Parameter object: 插入对象。
    /// - Returns: 操作失败则返回 Error。
    @discardableResult
    static func insert<T: TableEncodable>(object: T) -> Swift.Error? {
        return insert(objects: [object])
    }

    /// 插入一组数据。
    ///
    /// - Parameter objects: 插入数组对象。
    /// - Returns: 操作失败则返回 Error。
    @discardableResult
    static func insert<T: TableEncodable>(objects: [T]) -> Swift.Error? {
        do {
            try shared.dataBase.insert(objects: objects, intoTable: T.className)
        } catch {
            debugPrint(" insert obj error \(error.localizedDescription)")
            return error
        }
        return nil
    }

    ///修改
    static func update<T: TableEncodable>(table: String,
                                          on propertys:[PropertyConvertible],
                                          with object:T,
                                          where condition: Condition? = nil) -> Swift.Error? {
        do {
            try shared.dataBase.update(table: table, on: propertys, with: object,where: condition)
        } catch {
            debugPrint(" update obj error \(error.localizedDescription)")
            return error
        }
        return nil
    }


    /// 删除表数据。
    ///
    /// - Parameters:
    ///   - table: 表名
    ///   - condition: 删除条件
    /// - Returns: 返回操作结果
    @discardableResult
    static func delete(table: String,
                       where condition: Condition? = nil) -> Swift.Error? {
        do {
            try shared.dataBase.delete(fromTable: table, where:condition)
        } catch {
            debugPrint("delete error \(error.localizedDescription)")
            return error
        }
        return nil
    }



    /// 获取多条数据。
    ///
    /// - Parameters:
    ///   - table: 表名。
    ///   - condition: 条件。
    ///   - orderList: 排序方式。
    ///   - limit: 获取数量。
    ///   - offset: 从第几条开始。
    /// - Returns: 返回结果。
    static func getObjects<T: TableDecodable>(table: String,
                                              where condition: Condition? = nil,
                                              orderBy orderList:[OrderBy]? = nil,limit: Limit? = nil,offset: Offset? = nil) -> [T]? {
        do {
            let allObjects: [T] = try shared.dataBase.getObjects(on: T.Properties.all,
                                                                 fromTable: table,
                                                                 where: condition,
                                                                 orderBy: orderList,limit: limit, offset: offset)
            return allObjects
        } catch {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return nil
    }

    /// 删除数据表。
    ///
    /// - Parameter table: 表名。
    /// - Returns: 操作失败则返回 Error。
    static func dropTable(table: String) -> Swift.Error? {
        do {
            try shared.dataBase.drop(table: table)
        } catch {
            debugPrint("drop table error \(error)")
            return error
        }
        return nil
    }

    /// 删除数据库文件。
    ///
    /// - Returns: 操作失败则返回 Error。
    static func removeDBFile() -> Swift.Error? {
        do {
            try shared.dataBase.close(onClosed: {
                try shared.dataBase.removeFiles()
            })
        } catch {
            debugPrint("not close db \(error)")
            return error
        }
        return nil
    }
}


extension DBManager {

    static var dbPath: String {

        let dbName = "AElf.db"
        let documentDirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                  .userDomainMask, true).first!
        let manager = FileManager.default

        let dbPath = documentDirPath.appendingPathComponent("db").appendingPathComponent(dbName)
        if !manager.fileExists(atPath: dbPath) {
            manager.createFile(atPath: dbPath, contents: nil, attributes: nil)
        }
        logInfo("数据库地址：\(dbPath)\n")

        return dbPath
    }
}
