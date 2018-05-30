//
//  Building.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Building: Object, JSONAbleType {
    
    dynamic var id: Int = -1
    dynamic var name: String = ""
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0

    static func fromJSON(_ data: Any) -> Building {
        let json = JSON(data)
        return Building(json: json)
    }
    
    convenience init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        name = json["name"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
    }
    
    convenience init(id: Int) {
        self.init()
        
        self.id = id
        name = ""
        latitude = 0.0
        longitude = 0.0
    }
    
    func isFullyLoaded() -> Bool {
        return !name.isEmpty
    }
}
