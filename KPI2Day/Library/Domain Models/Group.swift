//
//  Group.swift
//  KPI2Day
//
//  Created by Inquisitor on 04.08.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Group: Object, JSONAbleType {
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    
    static func fromJSON(_ data: Any) -> Group {
        let json = JSON(data)
        return Group(json: json)
    }
    
    convenience init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        name = json["name"].stringValue
    }
    
    convenience init(id: Int) {
        self.init()
        
        self.id = id
        self.name = ""
    }
}
