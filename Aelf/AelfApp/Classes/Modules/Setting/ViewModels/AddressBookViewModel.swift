//
//  AddressBookViewModel.swift
//  AelfApp
//
//  Created by MacKun on 2019/6/18.
//  Copyright © 2019 legenddigital. All rights reserved.
//

import UIKit

class AddressBookViewModel:ViewModel{
    
}

extension AddressBookViewModel : ViewModelType{
    
    struct Input {
        let address:String = App.address
        let keyword:BehaviorRelay<String>
        let delIndexPath:BehaviorRelay<IndexPath>
        let headerRefresh: Observable<Void>
    }
    
    struct Output {
        let items = BehaviorRelay<[AddressBookItemModel]>(value: [])
        let delSucess = BehaviorRelay<Bool>(value: false)
        let sections = BehaviorRelay<[[AddressBookItemModel]]>(value: [[]])
        let indexDataSource = BehaviorRelay<[String]>(value:[])
        
        
    }
    
    func transform(input: AddressBookViewModel.Input) -> AddressBookViewModel.Output {
        let output = Output()

        input.delIndexPath.filter({ (indexPath) -> Bool in
            return indexPath.section >= 0
        }).subscribe(onNext: { [weak self](indexPath) in
            var  sections = output.sections.value
            let items:[AddressBookItemModel] = sections[indexPath.section]
            let item:AddressBookItemModel = items[indexPath.row]
            
            sections[indexPath.section].remove(at: indexPath.row)

            if sections[indexPath.section].count == 0 {
                sections.remove(at: indexPath.section)
            }
            
            output.sections <= sections
            if item.address != "" {
                self?.delRequest(fromAddress: input.address, toAddress: item.address ?? "").subscribe(onNext: { result in
                    if result.isOk {
                    } else {
                        // output.delSucess <= false
                    }
                }).disposed(by: (self?.rx.disposeBag)!)
            }
           
        }).disposed(by: rx.disposeBag)
        //.filter({ $0.length > 0})
        input.keyword.subscribe(onNext: { [weak self](keyword) in
            self?.request(address: input.address, keyWord: keyword).subscribe(onNext: { (result) in
                output.items.accept(result.list)
                var sections = [[AddressBookItemModel]]()
                var section = [AddressBookItemModel]()
                var indexArray = [String](arrayLiteral: "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
                let sectionIndex = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                var tempObj = result.list.first
                if (tempObj != nil) {
                    section.append(tempObj!)
                    for i in 1..<result.list.count {
                        let bookItem = result.list[i]
                        if tempObj!.fc == bookItem.fc {
                            section.append(bookItem)
                        } else {
                            sections.append(section)
                            
                            if !sectionIndex.contains(tempObj?.fc ?? "") {
                                 indexArray.append(tempObj?.fc ?? "#")
                            }
                           
                            section = [AddressBookItemModel]()
                            section.append(bookItem)
                            tempObj = bookItem
                        }
                    }
                }
                
                if !section.isEmpty {
                    sections.append(section)
                    if !sectionIndex.contains(tempObj?.fc ?? "") {
                        indexArray.append(tempObj?.fc ?? "#")
                    }
                }
                output.sections.accept(sections)
                output.indexDataSource <= indexArray
            }).disposed(by: (self?.rx.disposeBag)!)
            
        }).disposed(by: rx.disposeBag)
        
//        let zip = Observable.combineLatest(input.keyword,input.headerRefresh)
//        zip.flatMapLatest { (key,refresh) -> Observable<AddressBookModel> in
//            return self.request(address: input.address, keyWord: key)
//            }.subscribe(onNext: { model in
//                logDebug(model)
//            }).disposed(by: rx.disposeBag)
        
        input.headerRefresh.flatMapLatest { _ -> Observable<AddressBookModel> in
            return self.request(address: input.address, keyWord: "").trackActivity(self.headerLoading)
            }.subscribe(onNext: { result in
                
                output.items.accept(result.list)
                var sections = [[AddressBookItemModel]]()
                
                var section = [AddressBookItemModel]()
                var indexArray = [String](arrayLiteral: "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
                let sectionIndex = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                var tempObj = result.list.first
                if (tempObj != nil) {
                    section.append(tempObj!)
                    for i in 1..<result.list.count {
                        let bookItem = result.list[i]
                        if tempObj!.fc == bookItem.fc {
                            section.append(bookItem)
                        } else {
                            sections.append(section)
                            if !sectionIndex.contains(tempObj?.fc ?? "") {
                                indexArray.append(tempObj?.fc ?? "#")
                            }
                            section = [AddressBookItemModel]()
                            section.append(bookItem)
                            tempObj = bookItem
                        }
                    }
                }
              
                if !section.isEmpty {
                    sections.append(section)
                    if !sectionIndex.contains(tempObj?.fc ?? "") {
                        indexArray.append(tempObj?.fc ?? "#")
                    }
                }
                output.sections.accept(sections)
                output.indexDataSource <= indexArray
                
                if sections.isEmpty {
                    self.parseError.onNext(ResultError.parseError("Temporary no cotacts".localized()))
                }
                
            }).disposed(by: rx.disposeBag)
        
        return output
    }
    
    func request(address:String, keyWord:String) -> Observable<AddressBookModel> {
        return userProvider.requestData(.getAddressBook(address: address, keyword: keyWord))
            .mapObject(AddressBookModel.self)
            .trackActivity(self.loading)
            .trackError(self.error)
    }
    
    func delRequest(fromAddress:String , toAddress:String) -> Observable<VResult> {
        return userProvider.requestData(.delContact(fromAddress: fromAddress, toAddress: toAddress))
            .mapObject(VResult.self)
            .trackActivity(self.loading)
//            .trackError(self.error)
    }
    
    
}
