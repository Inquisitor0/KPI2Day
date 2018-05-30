//
//  Room.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Room: Object, JSONAbleType {
    
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var fullName: String = ""
    dynamic var building: Building? = nil
    
    static func fromJSON(_ data: Any) -> Room {
        let json = JSON(data)
        return Room(json: json)
    }
    
    convenience init(json: JSON, isFullBuildingModel: Bool = false) {
        self.init()
        
        id = json["id"].intValue
        name = json["name"].stringValue
        fullName = json["full_name"].stringValue
        
        let tmpBuilding: Building
        
        if isFullBuildingModel {
            tmpBuilding = Building(json:json["building"])
        } else {
            tmpBuilding = Building(id: json["building"].intValue)
        }
        fullName = "\(json["name"].stringValue)-\(tmpBuilding.name)"
        building = tmpBuilding
    }
    
    convenience init(id: Int) {
        self.init()
        
        self.id = id
        name = ""
        fullName = ""
        building = nil
    }
    
    func isFullyLoaded() -> Bool {
        return building != nil
                && name != ""
                && fullName != ""
    }
}
