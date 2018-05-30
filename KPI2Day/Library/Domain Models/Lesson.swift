//
//  Lesson.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Realm

@objcMembers final class Lesson: Object, JSONAbleType {
    
    dynamic var id: Int = -1
    dynamic var day: Int = 0
    dynamic var weekNumber: Int = 0
    dynamic var type: LessonType = .lecture
    dynamic var discipline: Discipline? = nil
    dynamic var teachers = List<Teacher>()
    dynamic var rooms = List<Room>()
    
    static func fromJSON(_ data: Any) -> Lesson {
        let json = JSON(data)
        return Lesson(json: json)
    }
    
    convenience init(json: JSON) {          // For basic models (see loadSchedule() in AppNetworkService)
        self.init()
        
        id = json["id"].intValue
        day = json["day"].intValue
        weekNumber = json["week"].intValue
        type = LessonType(rawValue: json["type"].intValue) ?? LessonType.lecture
        discipline = Discipline(id: json["discipline"].intValue,
                                name: json["discipline_name"].stringValue)
        
        // Parse teachers
        
        var teachersModels: [Teacher] = []
        json["teachers"].arrayValue.forEach {
            teachersModels.append(Teacher(id: $0.intValue))
        }
        
        for item in json["teachers_short_names"].arrayValue.enumerated() {
            teachersModels[item.offset].shortName = item.element.stringValue
        }
        
        teachers.append(objectsIn: teachersModels)
        
        // Parse rooms
        
        var roomsModels: [Room] = []
        json["rooms"].arrayValue.forEach {
            roomsModels.append(Room(id: $0.intValue))
        }
        
        for item in json["rooms_full_names"].arrayValue.enumerated() {
            roomsModels[item.offset].fullName = item.element.stringValue
        }
        
        rooms.append(objectsIn: roomsModels)
    }
    
    convenience init(json: JSON, day: Int, week: Int) {
        self.init()
        
        id = json["id"].intValue
        self.day = day
        weekNumber = week
        type = LessonType(rawValue: json["type"].intValue) ?? LessonType.lecture
        discipline = Discipline(json: json["discipline"])
        
        var teachersModels: [Teacher] = []
        json["teachers"].arrayValue.forEach {
            teachersModels.append(Teacher(json: $0))
        }

        teachers.append(objectsIn: teachersModels)
        
        var roomsModels: [Room] = []
        json["rooms"].arrayValue.forEach {
            roomsModels.append(Room(json: $0, isFullBuildingModel: true))
        }

        rooms.append(objectsIn: roomsModels)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
