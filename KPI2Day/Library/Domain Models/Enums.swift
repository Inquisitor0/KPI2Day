//
//  Enums.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 22.04.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import UIKit

enum LessonType: Int {
    case lecture = 0
    case practice
    case laboratory
    // TODO: (alex) Implement Localizable.string for the project
    var localized: String {
        switch self {
        case .lecture:
            return "Лекция"
        case .practice:
            return "Практика"
        case .laboratory:
            return "Лабораторная"
        }
    }
}

enum WeekDay: Int {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var localized: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        }
    }
}
