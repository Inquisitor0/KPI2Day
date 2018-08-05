//
//  AppDataManager.swift
//  KPI2Day
//
//  Created by Alexander Kravchenko on 13.05.2018.
//  Copyright © 2018 Alexander Kravchenko. All rights reserved.
//

import RxSwift
import UIKit
import SwiftyUserDefaults
import RealmSwift

class AppDataManager {
    
    static let shared = AppDataManager()
    
    private init() {
        currentGroupName = Defaults[.groupName]
        currentGroupId.value = Defaults[.groupId]
        isGridViewEnabled.value = Defaults[.gridViewEnabled]
    }
    
    var currentGroupId = Variable<String?>(nil)
    var currentGroupName: String?
    
    var isGridViewEnabled = Variable<Bool>(false)
    
    func updateGroup(name: String, id: String) {
        currentGroupName = name
        currentGroupId.value = id
        Defaults[.groupId] = id
        Defaults[.groupName] = name
    }
 
    func saveLessons(_ lessons: [Lesson], _ completion: (() -> Void)? = nil) {
        RealmService.save(lessons) {
            completion?()
        }
    }
    
    private func clearLessons() {
        RealmService.clearLessons()
    }
    
    func flush() {
        clearLessons()
        UserDefaults.reset()
        currentGroupName = nil
        currentGroupId.value = nil
    }
}
