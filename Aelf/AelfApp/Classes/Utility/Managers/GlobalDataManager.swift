//
//  GlobalDataManager.swift
//  AElfApp
//
//  Created by 晋先森 on 2019/12/12.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

class GlobalDataManager: NSObject {

    static let shared = GlobalDataManager()
 
    private override init() {

    }

    
    func checkAndUpdateData() {
        
        requestChains().subscribe(onNext: { items in
            
            if items.count > 0 {
                ChainItem.clearAndInsertNew(items: items)
            }
            
            logInfo("Items: \(ChainItem.getItems().count)")
            
        }).disposed(by: rx.disposeBag)
    }


    //
    func requestChains() -> Observable<[ChainItem]> {
        
        return assetProvider
            .requestData(.crossChains)
            .mapObjects(ChainItem.self)
    }
}
