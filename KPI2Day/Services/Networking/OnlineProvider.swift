//
//  OnlineProvider.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Alamofire
import Reachability.Swift
import enum Result.Result
import SwiftyJSON

class OnlineProvider<Target> where Target: Moya.TargetType {
    
    fileprivate let provider: MoyaProvider<Target>
    
    init() {
        
        let manager = Manager(configuration: URLSessionConfiguration.default)
        
        let logging = NetworkLoggingPlugin.init(verbose: true,
                                                cURL: false,
                                                output: OnlineProvider.reversedPrint,
                                                requestDataFormatter: nil,
                                                responseDataFormatter: JSONResponseDataFormatter)
        provider = MoyaProvider.init(manager: manager, plugins: [HandleUnauthorizedPlugin(), logging])
    }
    
    func request(_ token: Target) -> Single<Any> {
        let actualRequest = provider.rx.request(token)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .utility))
            .filterSuccessfulStatusCodes().mapJSON()
        return actualRequest
    }
    
    static func reversedPrint(_ separator: String, terminator: String, items: Any...) {
        for item in items {
            print("[✈️]" + "\(item)" + "\n")
        }
    }
}

//struct Network {
//
//    static func saveUserData(json: Any) {
//
//        let jsonObject = JSON(json)
//        Defaults[.token] = jsonObject["token"].string
//    }
//}

final class HandleUnauthorizedPlugin: PluginType {
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        
        switch result {
        case let .success(response):
            
            if response.statusCode > 399 {
                let error = JSON(response.data)
                print(error)
            }
            
            if response.statusCode == 401 {
                AppRouter.prepareUserFlow()
            }
            
            if response.statusCode == -1009 {
                print(" 😇no internet")
            }
            
            print(response.statusCode)
        case let .failure(error):
            //            if response.statusCode == -1009 {
            print(" 😇 \(error)")
            
            switch error {
            case let .underlying(objError, response):
                print(response?.statusCode ?? -1)
                let err = objError as NSError
                print(err)
            default: break
            }
            //            }
        }
    }
}
