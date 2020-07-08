//
//  FilePathUtils.swift
//  AelfApp
//
//  Created by yuguo on 2020/7/7.
//  Copyright © 2020 legenddigital. All rights reserved.
//

import Foundation

enum AppDirectories {
    case documents
    case library
    case libraryCaches
    case temp
    case customPath(path:FilePathProtocol)
}

protocol FilePathProtocol {
    func filePathUrl() -> URL
    func stringPath() -> String
}

//// MARK: - Get Path
//// - Returns: URL
struct FilePathUtils {

    static func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func libraryDirectoryURL() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first!
    }

    static func tempDirectoryURL() -> URL {
        if #available(iOS 10.0, *) {
            return FileManager.default.temporaryDirectory
        } else {
            return URL.init(string: "a")!
        }
    }

    static func librayCachesURL() -> URL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask).first!
    }

    static func setupFilePath(directory: AppDirectories, name: String) -> URL {
        return getURL(for: directory).appendingPathComponent(name)
    }

    private static func getURL(for directory: AppDirectories) -> URL {
        switch directory {
        case .documents:
            return documentsDirectoryURL()
        case .libraryCaches:
            return librayCachesURL()
        case .library:
            return libraryDirectoryURL()
        case .temp:
            return tempDirectoryURL()
        case .customPath(let path):
            return path.filePathUrl()
        }
    }
}

// MARK: - Follow multiple protocols use
// - Returns: String Bool
struct FileUtils {

    // MARK: - create a file
    // - Parameter content: write content  path: type  name : fileName
    // - Returns: Created successfully(true) or failed(false)
    static func createFolder(basePath: AppDirectories, folderName:String, createIntermediates: Bool = true, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        let filePath = FilePathUtils.setupFilePath(directory: basePath, name: folderName)
        let  fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath:filePath.path, withIntermediateDirectories: createIntermediates, attributes: attributes)
            return true
        } catch {
            return false
        }
    }

    // MARK: - writeFile
    // - Parameter content: write content  path: type  name : fileName
    // - Returns: writeFile successfully(true) or failed(false)
    static func writeFile(content: Data, filePath: FilePathProtocol, options: Data.WritingOptions = []) -> Bool {
        do {
            try content.write(to: filePath.filePathUrl(), options: options)
            return true
        } catch {
            return false
        }
    }

    // MARK: - readFile
    // - Parameter path: read path name: fileName
    // - Returns: file data
    static func readFile(filePath: FilePathProtocol) -> Data? {
        let fileContents = FileManager.default.contents(atPath: filePath.filePathUrl().path)
        if fileContents?.isEmpty == false {
            return fileContents
        } else {
            return nil
        }
    }

    // MARK: - deleteFile
    // - Parameter path: filePath name: fileName
    // - Returns: deleteFile successfully(true) or failed(false)
    static func deleteFile(filePath: FilePathProtocol) -> Bool {
        do {
            try FileManager.default.removeItem(at: filePath.filePathUrl())
            return true
        } catch {
            return false
        }
    }

    // MARK: - renameFile
    // - Parameter  path: filePath oldName: oldFilePath newName:newFilePath
    // - Returns: renameFile successfully(true) or failed(false)
    static func renameFile(path: AppDirectories, oldName: String, newName: String) -> Bool {
        let oldPath = FilePathUtils.setupFilePath(directory: path, name: oldName)
        let newPath = FilePathUtils.setupFilePath(directory: path, name: newName)
        do {
            try FileManager.default.moveItem(at: oldPath, to: newPath)
            return true
        } catch {
            return false
        }
    }

    // MARK: - moveFile
    // - Parameter name: fileName inDirectory : FilePath  toDirectory: moveToPath
    // - Returns: moveFile successfully(true) or failed(false)
    static func moveFile(fileName: String, fromDirectory: String, toDirectory: String) -> Bool {
        let originURL = FilePathUtils.setupFilePath(directory: .customPath(path: fromDirectory), name: fileName)
        let destinationURL = FilePathUtils.setupFilePath(directory: .customPath(path: toDirectory), name: fileName)
        // warning: constant 'success' inferred to have type '()', which may be unexpected
        do {
            try FileManager.default.moveItem(at: originURL, to: destinationURL)
            return true
        } catch {
            return false
        }
    }

    // MARK: - copyFile
    // - Parameter name: fileName inDirectory : FilePath  toDirectory: moveToPath
    // - Returns: copyFile successfully(true) or failed(false)
    static func copyFile(fileName: String, fromDirectory: String, toDirectory: String) throws {
        let originURL = FilePathUtils.setupFilePath(directory: .customPath(path: fromDirectory), name: fileName)
        let destinationURL = FilePathUtils.setupFilePath(directory: .customPath(path: toDirectory), name: fileName)
        return try FileManager.default.copyItem(at: originURL, to: destinationURL)
    }

    // MARK: - isWritable
    // - Parameter file:filePath
    // - Returns: isWritable successfully(true) or failed(false)
    static func isWritable(fileURL: FilePathProtocol) -> Bool {
        if FileManager.default.isWritableFile(atPath: fileURL.stringPath()) {
            return true
        } else {
            return false
        }
    }

    // MARK: - isReadable
    // - Parameter file:filePath
    // - Returns: isReadable successfully(true) or failed(false)
    static func isReadable(filePath: FilePathProtocol) -> Bool {
        if FileManager.default.isReadableFile(atPath: filePath.stringPath()) {
            return true
        } else {
            return false
        }
    }

    // MARK: - exists
    // - Parameter file:filePath
    // - Returns: exists successfully(true) or failed(false)
    func exists(filePath: FilePathProtocol) -> Bool {
        if FileManager.default.fileExists(atPath: filePath.stringPath()) {
            return true
        } else {
            return false
        }
    }

    // MARK: - get File List In Folder With Path
    // - Parameter path: folderPath
    // - Returns: getFileListInFolderWithPath successfully(true) or failed(false)
    static func getFilePathList(folderPath: FilePathProtocol) -> [String] {
        let fileManager = FileManager.default
        let fileList = try? fileManager.contentsOfDirectory(atPath: folderPath.stringPath())
        return fileList ?? []
    }

}
