//
//  AppConfigManager.swift
//  AElfApp
//
//  Created by 晋先森 on 2020/2/24.
//  Copyright © 2020 AELF. All rights reserved.
//

import Foundation

class AppConfigManager: NSObject {
    
    static let shared = AppConfigManager()
    
    private(set) var config: AppConfig!
    
    private override init() {
        super.init()
        self.parseConfig()
    }
    
    func parseConfig() {
        let url = Bundle.main.url(forResource: "Configure", withExtension: "plist")!
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            config = try decoder.decode(AppConfig.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}


struct AppConfig: Codable {
    let pubKey: String
    let buglyId: String
    let uMengKey: String
    
}
