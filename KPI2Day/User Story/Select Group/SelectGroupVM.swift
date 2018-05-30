//
//  SelectGroupVM.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import Moya
import CocoaLumberjack
import RxSwift
import SwiftyJSON

class SelectGroupVM {
    
    private let bag = DisposeBag()
    private let provider = OnlineProvider<AppNetworkService>()
    
    func loadGroup(name: String, completion: @escaping ((_ groupId: String?, _ errorDescription: String?) -> Void)) {
        provider.request(.loadGroup(name: name))
            .subscribe(onSuccess: { (response) in
                
                let json = JSON(response)
                let results = json["results"].arrayValue
                
                if results.isEmpty {
                    completion(nil, "Group not found")
                    return
                }
                
                if let groupId = results.first?["id"].int {
                    completion("\(groupId)", nil)
                    return
                }
                
                completion(nil, "Unknown error")
                
            }) { error in
                completion(nil, error.localizedDescription)
                return
            }
            .disposed(by: bag)
    }
}

