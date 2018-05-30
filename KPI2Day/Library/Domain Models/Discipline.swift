//
//  Discipline.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Discipline: Object, JSONAbleType {
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var fullName: String = ""
    
    static func fromJSON(_ data: Any) -> Discipline {
        let json = JSON(data)
        return Discipline(json: json)
    }
    
    convenience init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        name = json["name"].stringValue
        fullName = json["full_name"].stringValue
    }
    
    convenience init(id: Int, name: String) {
        self.init()
        
        self.id = id
        self.name = name
        fullName = ""
    }
    
    func isFullyLoaded() -> Bool {
        return fullName != ""
    }
}
