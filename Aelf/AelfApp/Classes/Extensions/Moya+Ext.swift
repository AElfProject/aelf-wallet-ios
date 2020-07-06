//
//  Moya+Ext.swift
//  RxExamples
//
//  Created by 晋先森 on 2019/5/28.
//  Copyright © 2019 AELF. All rights reserved.
//

import Foundation
import Moya
import Moya_ObjectMapper

typealias ResultCompletion = (_ result:VResult) -> Void

extension MoyaProvider {
    
    func requestData(_ target: Target) -> Observable<VResult> {
        
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(target) { [weak self] result in
                switch result {
                case .success(let value):
                    if (target is MarktAPI){
                        var result1 = VResult.init(JSON: [:])
                        result1?.status = value.statusCode
                        result1?.data = self?.nsdataToJSON(data: value.data)
                        observer.onNext(result1!)
                        observer.onCompleted()
                        break;
                    } else {
                        observer.onNext(value.toResult())
                        observer.onCompleted()
                        break;
                    }
                case .failure(let error):
                    if (target is MarktAPI){
                        
                        break;
                    }
                    logInfo("请求出错：\(error)\n")
                    observer.onError(ResultError.error(type: .networkError))
                    // break
                }
            }
            
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
    func nsdataToJSON(data: Data) -> AnyObject? {
        do {
            let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(jsonStr as Any)
            return try JSONSerialization.jsonObject(with: data, options: .init()) as AnyObject
//             return try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as AnyObject
        } catch {
            print("error!")
        }
        
        return nil
    }
    
    class func JSONEndpointMapping(_ target: Target) -> Endpoint {
        
        let url = target.baseURL.appendingPathComponent(target.path).absoluteString.replacingOccurrences(of: "%3F", with: "?")
        return Endpoint(
            url: url,
            sampleResponseClosure: {
                .networkResponse(200, target.sampleData)
        },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
}

// Cache
extension MoyaProvider {
    
    //    func requestCacheData(_ target: Target) -> Observable<VResult> {
    //        return cacheObject(target, type: VResult.self)
    //    }
}
