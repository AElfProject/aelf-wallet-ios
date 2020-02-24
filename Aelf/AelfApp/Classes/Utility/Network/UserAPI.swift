//
//  API.swift
//  AelfApp
//
//  Created by 晋先森 on 2019/5/24.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import Foundation

import Moya

let userProvider = MoyaProvider<UserAPI>(endpointClosure:MoyaProvider.JSONEndpointMapping,
                                         manager: BaseConfig.manager,
                                         plugins: [NetworkLoggerPlugin(verbose: true,
                                                                       responseDataFormatter: BaseConfig.jsonFormatter),
                                                   BaseConfig.networkActivityPlugin])

enum UserAPI {
    case getIdentity(address:String)
    case identityEdit(address:String,name:String?,img:Data?)
    case appUpgrade
    case versionLog
    case addContact(fromAddress:String,toAddress:String,name:String,remark:String)
    case delContact(fromAddress:String,toAddress:String)
    case getAddressBook(address:String,keyword:String)
    case systemMessage(address:String,type:Int,p:Int)
    case transactionNotice(address:String,p:Int)
    case clearMessageNote(address:String)
    case clearTransactionNotice(address:String)
    case setMessageRead(address:String,type:Int,mid:String)
    case setNoticeRead(address:String,id:String)
    case getLangs
    case getCurrencies
    case messageUnRead(address:String)
    case feedback(address:String,title:String,email:String,desc:String)
    case updateDeviceToken(address:String,parent:String,iosNoticeToken:String)

}

extension UserAPI: TargetType {

    var baseURL: URL {
        return BaseConfig.BaseURL
    }

    var path: String {

        var path = ""
        switch self {
        case .getIdentity:
            path = "app/user/identity"
        case .identityEdit:
            path = "app/user/identity_edit"
        case .appUpgrade:
            path = "app/user/upgrade"
        case .versionLog:
            path = "app/user/version_log"
        case .addContact:
            path = "app/user/add_contact"
        case .delContact:
            path = "app/user/del_contact"
        case .getAddressBook:
            path = "app/user/address_book"
        case .systemMessage:
            path = "app/user/message"
        case .setMessageRead:
            path = "app/user/set_message_read"
        case .setNoticeRead:
            path = "app/user/set_notice_read"
        case .transactionNotice:
            path = "app/user/transaction_notice"
        case .clearMessageNote:
            path = "app/user/empty_message"
        case .clearTransactionNotice:
            path = "app/user/empty_notice"
        case .getCurrencies:
            path = "app/settings/get_currencies"
        case .getLangs:
            path = "app/settings/get_langs"
        case .messageUnRead:
            path = "app/user/unread"
        case .feedback:
            path = "app/user/feedback"
        case .updateDeviceToken:
            path = "app/com_addr"
        }
        path += "?lang=\(App.languageID ?? "")"
        return path
    }

    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }

    var sampleData: Data { // 单元测试用
        return Data()
    }

    var task: Task {
        var parameters = [String:String]()
        switch self {
        case let .getIdentity(address):
            parameters = ["address":address]
        case let .identityEdit(address, name, img):
            parameters["address"] = address
            if let name = name {
                parameters["name"] = name
            }

            if let img = img { // 图片上传

                parameters.rsaEncode()
                parameters.addIfNotExist(dict: BaseConfig.baseParameters())

                var multipart = [MultipartFormData]()
                let imgData = MultipartFormData(provider: .data(img),
                                                name: "img",
                                                fileName: "avatar.png",
                                                mimeType: "image/jpeg")
                multipart.append(imgData)

                for (key,value) in parameters {
                    if let data = value.data(using: .utf8) {
                        let data = MultipartFormData(provider: .data(data), name: key)
                        multipart.append(data)
                    }
                }
                return .uploadMultipart(multipart)
            }

        case .appUpgrade:
            parameters = [:]
        case .versionLog:
            parameters = [:]
        case let .addContact(fromAddress, toAddress, name, remark):
            parameters = ["address":fromAddress,"name":name,"contact_address":toAddress,"note":remark]
        case let .delContact(fromAddress, toAddress):
            parameters = ["address":fromAddress,"contact_address":toAddress]
        case let .getAddressBook(address, keyword):
            parameters = ["address":address,"keyword":keyword]
        case let .systemMessage(address, type, p):
            parameters = ["address":address,"type":type.string,"p":p.string]
        case let .transactionNotice(address, p):
            parameters = ["address":address,"p":p.string]
        case let .clearMessageNote(address):
            parameters = ["address":address,"type":"1"] // 1 系统消息
        case let .clearTransactionNotice(address):
            parameters = ["address":address]
        case let .setNoticeRead(address, id):
            parameters = ["address":address,"id":id]
        case let .setMessageRead(address, type, mid):
            parameters = ["address":address,"type":type.string,"mid":mid]
        case let .messageUnRead(address):
            parameters = ["address":address]
        case let .feedback(address, title, email, desc):
            parameters = ["address":address,"title":title,"email":email,"desc":desc]
        case let .updateDeviceToken(address, parent, iosNoticeToken):
            let phoneVersion = UIDevice.current.systemVersion
            let phoneModel =  UIDevice.current.value(forKey: "name") as? String ?? ""
            let deviceInfo = "Phone Model:" + phoneModel + ",OSVersion:" + phoneVersion
            parameters = ["address":address,"parent":parent,"iosNoticeToken":iosNoticeToken,"deviceInfo":deviceInfo]

        default:
            parameters = [:]
        }

        logInfo("\n \(self.path)\n请求参数：\(parameters)\n")
        parameters.rsaEncode()

        parameters.addIfNotExist(dict: BaseConfig.baseParameters())

        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }

    var headers: [String : String]? {
        return BaseConfig.headers
    }

}
