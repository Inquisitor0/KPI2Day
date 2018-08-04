//
//  Teacher.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Teacher: Object, JSONAbleType {
    
    dynamic var id: Int = -1
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var middleName: String = ""
    dynamic var fullName: String = ""
    dynamic var degree: String = ""
    dynamic var shortName: String = ""
    dynamic var shortNameWithDegree: String = ""
    
    dynamic var scheduleWasLoaded: Bool = false
    
    static func fromJSON(_ data: Any) -> Teacher {
        let json = JSON(data)
        return Teacher(json: json)
    }
    
    convenience init(json: JSON) {
        self.init()
        
        id = json["id"].intValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        middleName = json["middle_name"].stringValue
        fullName = json["full_name"].stringValue
        degree = json["degree"].stringValue
        shortName = json["short_name"].stringValue
        shortNameWithDegree = json["short_name_with_degree"].stringValue
    }
    
    convenience init(id: Int) {
        self.init()
        
        self.id = id
        firstName = ""
        lastName = ""
        middleName = ""
        fullName = ""
        degree = ""
        shortName = ""
        shortNameWithDegree = ""
    }
    
    func isFullyLoaded() -> Bool {
        return firstName != "" && lastName != ""
    }
}
