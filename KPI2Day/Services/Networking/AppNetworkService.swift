//
//  AppNetworkService.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 07.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import Foundation
import Moya
import RxSwift

let kServerURL = "https://api.rozklad.hub.kpi.ua/"

enum AppNetworkService {
    
    case loadSchedule(groupId: String)
    case loadFullSchedule(groupId: String)
    
    case loadTeacherSchedule(teacherId: Int)
    
    case loadGroup(name: String)
}

extension AppNetworkService: TargetType {
    
    var baseURL: URL {
        return URL(string:kServerURL)!
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        if let requestParameters = parameters {
            
            if  method == .get {
                return .requestParameters(parameters: requestParameters, encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: requestParameters, encoding: JSONEncoding.default)
            }
        }
        
        return .requestPlain
    }
    
    var path: String {
        switch self {
        case .loadSchedule:
            return "lessons"
        case .loadFullSchedule(let groupId):
            return "groups/\(groupId)/timetable/"
        case .loadTeacherSchedule:
            return "lessons"
        case .loadGroup:
            return "groups"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .loadSchedule(let groupId):
            return ["groups": groupId,
                    "limit": Constants.lessonsDefaultOffset]
        case .loadGroup(let name):
            return ["name": name]
        case .loadTeacherSchedule(let teacherId):
            return ["teachers": teacherId,
                    "limit": 100]
        default:
            return nil
        }
    }
}
